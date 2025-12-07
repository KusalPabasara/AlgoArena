const firestoreService = require('../services/firestore.service');
const storageService = require('../services/storage.service');

// @desc    Get posts by page ID
// @route   GET /api/posts/page/:pageId
// @access  Private
exports.getPostsByPage = async (req, res) => {
  try {
    const pageId = req.params.pageId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    // Get all posts for this page
    const allPosts = await firestoreService.query('posts', 'pageId', '==', pageId);
    
    // Sort by createdAt descending (newest first)
    allPosts.sort((a, b) => {
      const dateA = a.createdAt?._seconds ? new Date(a.createdAt._seconds * 1000) : new Date(0);
      const dateB = b.createdAt?._seconds ? new Date(b.createdAt._seconds * 1000) : new Date(0);
      return dateB.getTime() - dateA.getTime();
    });

    // Paginate
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedPosts = allPosts.slice(startIndex, endIndex);

    // Get page info
    const pageData = await firestoreService.getById('pages', pageId);
    if (!pageData) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Populate posts with comments
    const postsWithData = await Promise.all(
      paginatedPosts.map(async (post) => {
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
            _id: pageData.id,
            fullName: pageData.name,
            profilePhoto: pageData.logo || null
          },
          pageId: pageData.id,
          pageName: pageData.name,
          pageLogo: pageData.logo || null,
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
      posts: postsWithData,
      currentPage: page,
      totalPages: Math.ceil(allPosts.length / limit),
      totalPosts: allPosts.length
    });
  } catch (error) {
    console.error('Get posts by page error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get feed posts
// @route   GET /api/posts/feed
// @access  Private
exports.getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    // Get all posts and filter out dummy posts (posts without pageId)
    // Note: Firestore doesn't support != null queries directly, so we fetch all and filter
    const allPosts = await firestoreService.getAll('posts', {
      orderBy: ['createdAt', 'desc']
    });
    
    // Define dummy post patterns to filter out
    const dummyPatterns = [
      'YOUR TURN TO LEAD',
      'YOUR TURN',
      'TO LEAD',
      'Join the',
      'Leo Club of Colombo',
      'Excited to be part of Leo Club',
      'Welcome to AlgoArena',
      'Just completed an amazing beach cleanup',
      'Thank you to everyone who participated in our food drive',
      'City lights and urban nights',
      'Making difference in our community',
      'Making difference',
      'leo_colombo',
      'Build skills',
      'Make friends',
      'Serve with pride',
      'SERVING COMMUNITY & GROOMING LEADERS'
    ];
    
    // Filter out dummy posts:
    // 1. Posts without pageId
    // 2. Posts with dummy content patterns
    // 3. Posts with images containing QR codes (check image URLs)
    const validPosts = allPosts.filter(post => {
      // Must have a pageId
      if (!post.pageId || post.pageId === '') {
        return false;
      }
      
      // Check if content matches dummy patterns
      const content = (post.content || '').toLowerCase();
      const hasDummyPattern = dummyPatterns.some(pattern => 
        content.includes(pattern.toLowerCase())
      );
      
      if (hasDummyPattern) {
        return false;
      }
      
      // Check if images contain QR code indicators (common in promotional posts)
      if (post.images && post.images.length > 0) {
        const imageUrls = post.images.map(img => (img || '').toLowerCase()).join(' ');
        // Filter out posts with promotional images (QR codes, promotional banners)
        // This is a heuristic - adjust as needed
        if (imageUrls.includes('qr') || imageUrls.includes('promo') || imageUrls.includes('banner')) {
          return false;
        }
      }
      
      return true;
    });
    
    // Sort by createdAt descending (newest first) - already sorted by getAll, but ensure consistency
    validPosts.sort((a, b) => {
      const dateA = a.createdAt?._seconds ? new Date(a.createdAt._seconds * 1000) : new Date(0);
      const dateB = b.createdAt?._seconds ? new Date(b.createdAt._seconds * 1000) : new Date(0);
      return dateB.getTime() - dateA.getTime();
    });
    
    // Paginate
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedPosts = validPosts.slice(startIndex, endIndex);
    
    const totalPosts = validPosts.length;
    const totalPages = Math.ceil(totalPosts / limit);

    // Populate author/page data for each post
    const postsWithAuthors = await Promise.all(
      paginatedPosts.map(async (post) => {
        // If post is from a page, use page info instead of author info
        if (post.pageId) {
          const page = await firestoreService.getById('pages', post.pageId);
          if (page) {
            // Additional check: filter out posts from pages with dummy names
            const pageName = (page.name || '').toLowerCase();
            if (pageName.includes('dummy') || pageName.includes('test') || pageName.includes('sample')) {
              return null; // Skip this post
            }
            
            // Filter out posts from "Leo Club of Colombo" if they contain promotional content
            if (pageName.includes('colombo') && pageName.includes('leo')) {
              const postContent = (post.content || '').toLowerCase();
              if (postContent.includes('city lights') || 
                  postContent.includes('urban nights') ||
                  postContent.includes('making difference')) {
                return null; // Skip promotional posts from Leo Club of Colombo
              }
            }
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
                _id: page.id, // Use page ID
                fullName: page.name, // Use page name
                profilePhoto: page.logo || null // Use page logo
              },
              pageId: page.id,
              pageName: page.name,
              pageLogo: page.logo || null,
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
          }
        }

        // For posts without pageId (shouldn't happen now, but keep for backward compatibility)
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

    // Filter out null posts (dummy posts that were filtered)
    const filteredPosts = postsWithAuthors.filter(post => post !== null);

    res.json({
      posts: filteredPosts,
      currentPage: page,
      totalPages: totalPages,
      totalPosts: totalPosts
    });
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create post
// @route   POST /api/posts
// @access  Private (Webmaster only)
exports.createPost = async (req, res) => {
  try {
    // Debug: Log request body and files
    console.log('📝 Create Post Request:');
    console.log('  - body:', req.body);
    console.log('  - files:', req.files ? `${req.files.length} files` : 'no files');
    console.log('  - file:', req.file ? 'single file' : 'no single file');
    
    const { content, pageId } = req.body;
    let imageUrls = [];

    // Require pageId - posts can only be created from pages
    if (!pageId) {
      return res.status(400).json({ 
        message: 'Page ID is required. Posts can only be created from club/district pages.' 
      });
    }

    // Get the page
    const page = await firestoreService.getById('pages', pageId);
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Get user's Leo ID
    const userData = await firestoreService.getById('users', req.user.id);
    const userLeoId = userData?.leoId;

    // Check if user is webmaster of this page or super admin
    const isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    if (!isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ 
        message: 'Only webmasters of this page can create posts. You must be assigned as a webmaster for this page.' 
      });
    }

    // Upload images to Firebase Storage if any
    if (req.files && req.files.length > 0) {
      console.log(`  - Uploading ${req.files.length} image(s)...`);
      try {
        const uploadResults = await storageService.uploadFiles(req.files, 'posts');
        imageUrls = uploadResults.map(result => result.url);
        console.log(`  - Successfully uploaded ${imageUrls.length} image(s)`);
      } catch (uploadError) {
        console.error('  - Image upload error:', uploadError);
        const errorMessage = uploadError.message || uploadError.toString();
        
        // Return error message but allow post creation without images
        console.warn('  - Image upload failed, continuing without images:', errorMessage);
        imageUrls = []; // Continue without images
        // Don't return error - allow post creation without images
      }
    }

    const postData = {
      authorId: req.user.id,
      content,
      images: imageUrls,
      pageId: pageId || null,
      likes: [],
      likesCount: 0,
      commentsCount: 0
    };

    const post = await firestoreService.create('posts', postData);

    console.log('  - Post created with content:', post.content);
    console.log('  - Post data:', JSON.stringify(postData, null, 2));

    // Return page name instead of author name when post is from a page
    const response = {
      _id: post.id,
      id: post.id,
      author: {
        _id: page.id, // Use page ID as author ID
        fullName: page.name, // Use page name instead of user name
        profilePhoto: page.logo || null // Use page logo instead of user photo
      },
      pageId: page.id,
      pageName: page.name,
      pageLogo: page.logo || null,
      content: post.content || content || '', // Ensure content is included
      images: post.images || [],
      likes: post.likes || [],
      comments: [],
      createdAt: post.createdAt?._seconds 
        ? new Date(post.createdAt._seconds * 1000).toISOString()
        : new Date().toISOString(),
      updatedAt: post.updatedAt?._seconds
        ? new Date(post.updatedAt._seconds * 1000).toISOString()
        : new Date().toISOString()
    };
    
    console.log('  - Response content:', response.content);
    res.status(201).json(response);
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

    // Add comment and get the newly created comment
    const newComment = await firestoreService.addComment(req.params.id, commentData);

    // Get author data for the new comment
    const author = await firestoreService.getById('users', req.user.id);
    
    // Format createdAt properly - handle Firestore Timestamp objects
    let createdAtString;
    try {
      if (newComment.createdAt) {
        // Check if it's a Firestore Timestamp object
        if (newComment.createdAt.constructor && newComment.createdAt.constructor.name === 'Timestamp') {
          // Use toDate() method if available
          if (typeof newComment.createdAt.toDate === 'function') {
            createdAtString = newComment.createdAt.toDate().toISOString();
          } else if (newComment.createdAt._seconds) {
            // Fallback to _seconds property
            createdAtString = new Date(newComment.createdAt._seconds * 1000).toISOString();
          } else {
            createdAtString = new Date().toISOString();
          }
        } else if (newComment.createdAt._seconds !== undefined) {
          // Firestore Timestamp format with _seconds
          createdAtString = new Date(newComment.createdAt._seconds * 1000).toISOString();
        } else if (newComment.createdAt instanceof Date) {
          // Already a Date object
          createdAtString = newComment.createdAt.toISOString();
        } else if (typeof newComment.createdAt === 'string') {
          // Already a string
          createdAtString = newComment.createdAt;
        } else {
          // Fallback to current time
          createdAtString = new Date().toISOString();
        }
      } else {
        createdAtString = new Date().toISOString();
      }
    } catch (error) {
      console.error('Error formatting createdAt:', error);
      createdAtString = new Date().toISOString();
    }
    
    // Format the newly added comment - ensure all fields are JSON-serializable
    const commentWithAuthor = {
      id: String(newComment.id || ''),
      user: {
        _id: String(req.user.id || ''),
        fullName: String(author?.fullName || req.user.fullName || 'Unknown User'),
        profilePhoto: author?.profilePhoto || req.user.profilePhoto || null
      },
      text: String(newComment.text || ''),
      createdAt: String(createdAtString)
    };

    // Return the newly added comment (frontend expects this)
    res.status(201).json(commentWithAuthor);
  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update comment
// @route   PUT /api/posts/:postId/comments/:commentId
// @access  Private (Comment owner or post owner)
exports.updateComment = async (req, res) => {
  try {
    const { postId, commentId } = req.params;
    const { text } = req.body;

    // Check if post exists
    const post = await firestoreService.getById('posts', postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Get the comment
    const comments = await firestoreService.getComments(postId);
    const comment = comments.find(c => c.id === commentId);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Check permissions: comment owner or post owner (webmaster)
    const isCommentOwner = comment.authorId === req.user.id;
    const isPostOwner = post.authorId === req.user.id;
    
    // Check if user is webmaster of the page
    let isWebmaster = false;
    if (post.pageId) {
      const page = await firestoreService.getById('pages', post.pageId);
      if (page) {
        const userData = await firestoreService.getById('users', req.user.id);
        const userLeoId = userData?.leoId;
        isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
      }
    }
    
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    if (!isCommentOwner && !isPostOwner && !isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ message: 'Not authorized to edit this comment' });
    }

    await firestoreService.updateComment(postId, commentId, text);

    // Get updated comment with author data
    const updatedComments = await firestoreService.getComments(postId);
    const updatedComment = updatedComments.find(c => c.id === commentId);
    const author = await firestoreService.getById('users', updatedComment.authorId);

    res.json({
      id: updatedComment.id,
      user: {
        _id: updatedComment.authorId,
        fullName: author?.fullName || 'Unknown User',
        profilePhoto: author?.profilePhoto || null
      },
      text: updatedComment.text,
      createdAt: updatedComment.createdAt?._seconds 
        ? new Date(updatedComment.createdAt._seconds * 1000).toISOString()
        : new Date().toISOString()
    });
  } catch (error) {
    console.error('Update comment error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete comment
// @route   DELETE /api/posts/:postId/comments/:commentId
// @access  Private (Comment owner or post owner)
exports.deleteComment = async (req, res) => {
  try {
    const { postId, commentId } = req.params;

    // Check if post exists
    const post = await firestoreService.getById('posts', postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Get the comment
    const comments = await firestoreService.getComments(postId);
    const comment = comments.find(c => c.id === commentId);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Check permissions: comment owner or post owner (webmaster)
    const isCommentOwner = comment.authorId === req.user.id;
    const isPostOwner = post.authorId === req.user.id;
    
    // Check if user is webmaster of the page
    let isWebmaster = false;
    if (post.pageId) {
      const page = await firestoreService.getById('pages', post.pageId);
      if (page) {
        const userData = await firestoreService.getById('users', req.user.id);
        const userLeoId = userData?.leoId;
        isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
      }
    }
    
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    if (!isCommentOwner && !isPostOwner && !isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ message: 'Not authorized to delete this comment' });
    }

    await firestoreService.deleteComment(postId, commentId);

    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Delete comment error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update post (content only for now)
// @route   PUT /api/posts/:id
// @access  Private (Webmaster of page or super admin)
exports.updatePost = async (req, res) => {
  try {
    const postId = req.params.id;
    const { content } = req.body;

    const post = await firestoreService.getById('posts', postId);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Get page if this is a page post
    let page = null;
    if (post.pageId) {
      page = await firestoreService.getById('pages', post.pageId);
    }

    // Determine permissions
    const isAuthor = post.authorId === req.user.id;
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    let isWebmaster = false;
    if (page) {
      const userData = await firestoreService.getById('users', req.user.id);
      const userLeoId = userData?.leoId;
      isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
    }

    if (!isAuthor && !isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ message: 'Not authorized to edit this post' });
    }

    const updates = {
      updatedAt: new Date()
    };

    if (typeof content === 'string') {
      updates.content = content;
    }

    await firestoreService.update('posts', postId, updates);

    const updatedPost = await firestoreService.getById('posts', postId);

    res.json({
      message: 'Post updated successfully',
      post: {
        id: postId,
        ...updatedPost
      }
    });
  } catch (error) {
    console.error('Update post error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete post
// @route   DELETE /api/posts/:id
// @access  Private (Webmaster of page or super admin)
exports.deletePost = async (req, res) => {
  try {
    const post = await firestoreService.getById('posts', req.params.id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Get page if this is a page post
    let page = null;
    if (post.pageId) {
      page = await firestoreService.getById('pages', post.pageId);
    }

    // Determine permissions
    const isAuthor = post.authorId === req.user.id;
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    let isWebmaster = false;
    if (page) {
      const userData = await firestoreService.getById('users', req.user.id);
      const userLeoId = userData?.leoId;
      isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
    }

    if (!isAuthor && !isWebmaster && !isSuperAdmin) {
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
