const firestoreService = require('../services/firestore.service');
const storageService = require('../services/storage.service');

// @desc    Get feed posts
// @route   GET /api/posts/feed
// @access  Private
exports.getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const result = await firestoreService.getPosts(page, limit);

    // Populate author data for each post
    const postsWithAuthors = await Promise.all(
      result.posts.map(async (post) => {
        const author = await firestoreService.getById('users', post.authorId);
        
        // Get comments with author data
        const comments = await firestoreService.getComments(post.id);
        const commentsWithAuthors = await Promise.all(
          comments.map(async (comment) => {
            const commentAuthor = await firestoreService.getById('users', comment.authorId);
            return {
              id: comment.id,
              user: {
                _id: comment.authorId,
                fullName: commentAuthor?.fullName || 'Unknown User',
                profilePhoto: commentAuthor?.profilePhoto || null
              },
              text: comment.text,
              createdAt: comment.createdAt?._seconds 
                ? new Date(comment.createdAt._seconds * 1000).toISOString()
                : new Date().toISOString()
            };
          })
        );

        return {
          _id: post.id,
          id: post.id,
          author: {
            _id: post.authorId,
            fullName: author?.fullName || 'Unknown User',
            profilePhoto: author?.profilePhoto || null
          },
          content: post.content,
          images: post.images || [],
          likes: post.likes || [],
          comments: commentsWithAuthors,
          createdAt: post.createdAt?._seconds 
            ? new Date(post.createdAt._seconds * 1000).toISOString()
            : new Date().toISOString(),
          updatedAt: post.updatedAt?._seconds
            ? new Date(post.updatedAt._seconds * 1000).toISOString()
            : new Date().toISOString()
        };
      })
    );

    res.json({
      posts: postsWithAuthors,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      totalPosts: result.totalPosts
    });
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create post
// @route   POST /api/posts
// @access  Private
exports.createPost = async (req, res) => {
  try {
    const { content } = req.body;
    let imageUrls = [];

    // Upload images to Firebase Storage if any
    if (req.files && req.files.length > 0) {
      const uploadResults = await storageService.uploadFiles(req.files, 'posts');
      imageUrls = uploadResults.map(result => result.url);
    }

    const postData = {
      authorId: req.user.id,
      content,
      images: imageUrls,
      likes: [],
      likesCount: 0,
      commentsCount: 0
    };

    const post = await firestoreService.create('posts', postData);

    // Get author data
    const author = await firestoreService.getById('users', req.user.id);

    res.status(201).json({
      _id: post.id,
      id: post.id,
      author: {
        _id: req.user.id,
        fullName: author.fullName || 'Unknown User',
        profilePhoto: author.profilePhoto || null
      },
      content: post.content,
      images: post.images || [],
      likes: post.likes || [],
      comments: [],
      createdAt: post.createdAt?._seconds 
        ? new Date(post.createdAt._seconds * 1000).toISOString()
        : new Date().toISOString(),
      updatedAt: post.updatedAt?._seconds
        ? new Date(post.updatedAt._seconds * 1000).toISOString()
        : new Date().toISOString()
    });
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Toggle like on post
// @route   PUT /api/posts/:id/like
// @access  Private
exports.toggleLike = async (req, res) => {
  try {
    const result = await firestoreService.toggleLike(req.params.id, req.user.id);

    res.json({ 
      likes: result.liked ? [req.user.id] : [],
      likesCount: result.likesCount 
    });
  } catch (error) {
    console.error('Toggle like error:', error);
    if (error.message.includes('not found')) {
      return res.status(404).json({ message: 'Post not found' });
    }
    res.status(500).json({ message: error.message });
  }
};

// @desc    Add comment to post
// @route   POST /api/posts/:id/comments
// @access  Private
exports.addComment = async (req, res) => {
  try {
    const { text } = req.body;

    // Check if post exists
    const post = await firestoreService.getById('posts', req.params.id);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const commentData = {
      authorId: req.user.id,
      text
    };

    await firestoreService.addComment(req.params.id, commentData);

    // Get all comments with author data
    const comments = await firestoreService.getComments(req.params.id);
    const commentsWithAuthors = await Promise.all(
      comments.map(async (comment) => {
        const author = await firestoreService.getById('users', comment.authorId);
        return {
          ...comment,
          author: {
            id: comment.authorId,
            fullName: author?.fullName,
            profilePhoto: author?.profilePhoto
          }
        };
      })
    );

    res.status(201).json(commentsWithAuthors);
  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete post
// @route   DELETE /api/posts/:id
// @access  Private
exports.deletePost = async (req, res) => {
  try {
    const post = await firestoreService.getById('posts', req.params.id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Check if user is post author or admin
    if (post.authorId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this post' });
    }

    // Delete images from storage
    if (post.images && post.images.length > 0) {
      const fileNames = post.images.map(url => storageService.extractFileNameFromUrl(url)).filter(Boolean);
      if (fileNames.length > 0) {
        await storageService.deleteFiles(fileNames).catch(err => {
          console.error('Error deleting images:', err);
        });
      }
    }

    await firestoreService.delete('posts', req.params.id);

    res.json({ message: 'Post deleted successfully' });
  } catch (error) {
    console.error('Delete post error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user posts
// @route   GET /api/posts/user/:userId
// @access  Private
exports.getUserPosts = async (req, res) => {
  try {
    const posts = await firestoreService.getUserPosts(req.params.userId);

    // Populate author data for each post
    const postsWithAuthors = await Promise.all(
      posts.map(async (post) => {
        const author = await firestoreService.getById('users', post.authorId);
        
        // Get comments with author data
        const comments = await firestoreService.getComments(post.id);
        const commentsWithAuthors = await Promise.all(
          comments.map(async (comment) => {
            const commentAuthor = await firestoreService.getById('users', comment.authorId);
            return {
              ...comment,
              author: {
                id: comment.authorId,
                fullName: commentAuthor?.fullName,
                profilePhoto: commentAuthor?.profilePhoto
              }
            };
          })
        );

        return {
          ...post,
          author: {
            id: post.authorId,
            fullName: author?.fullName,
            email: author?.email,
            profilePhoto: author?.profilePhoto
          },
          comments: commentsWithAuthors
        };
      })
    );

    res.json(postsWithAuthors);
  } catch (error) {
    console.error('Get user posts error:', error);
    res.status(500).json({ message: error.message });
  }
};
