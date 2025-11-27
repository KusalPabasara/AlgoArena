import 'post_model.dart';
import 'user_model.dart';

/// Like and Comment Manager
/// 
/// Manages frontend-only like and comment state
/// No backend calls - all state is local
class LikeCommentManager {
  // Local state for likes
  final Map<String, bool> _likedPosts = {}; // postId -> isLiked
  final Map<String, int> _postLikesCount = {}; // postId -> likesCount
  
  // Local state for comments
  final Map<String, List<Map<String, dynamic>>> _postComments = {}; // postId -> comments list

  /// Initialize like state from backend data
  void initializeLikes(List<Post> posts, User? user) {
    for (var post in posts) {
      if (post.id.isNotEmpty && user != null && user.id.isNotEmpty) {
        if (post.isLikedBy(user.id)) {
          _likedPosts[post.id] = true;
        } else if (!_likedPosts.containsKey(post.id)) {
          _likedPosts[post.id] = false;
        }
        if (!_postLikesCount.containsKey(post.id)) {
          _postLikesCount[post.id] = post.likesCount;
        }
      }
    }
  }

  /// Handle like toggle (frontend only)
  void handleLike(Post post, User? currentUser) {
    if (post.id.isEmpty) return;
    
    // Check current like status - prioritize local state
    bool isCurrentlyLiked;
    if (_likedPosts.containsKey(post.id)) {
      isCurrentlyLiked = _likedPosts[post.id] ?? false;
    } else {
      // Check backend state if local state doesn't exist
      final userId = currentUser?.id ?? '';
      isCurrentlyLiked = userId.isNotEmpty ? post.isLikedBy(userId) : false;
    }
    
    // Get current likes count
    final currentLikesCount = _postLikesCount[post.id] ?? post.likesCount;
    
    // Toggle like state
    if (isCurrentlyLiked) {
      // Unlike
      _likedPosts[post.id] = false;
      _postLikesCount[post.id] = (currentLikesCount > 0) ? currentLikesCount - 1 : 0;
    } else {
      // Like
      _likedPosts[post.id] = true;
      _postLikesCount[post.id] = currentLikesCount + 1;
    }
  }

  /// Check if post is liked (frontend state takes priority)
  bool isPostLiked(Post post, User? currentUser) {
    if (post.id.isEmpty) return false;
    
    // Check local state first
    if (_likedPosts.containsKey(post.id)) {
      return _likedPosts[post.id] ?? false;
    }
    
    // Fall back to backend state
    final userId = currentUser?.id ?? '';
    if (userId.isEmpty) return false;
    return post.isLikedBy(userId);
  }

  /// Get likes count (frontend state takes priority)
  int getPostLikesCount(Post post) {
    if (_postLikesCount.containsKey(post.id)) {
      return _postLikesCount[post.id] ?? post.likesCount;
    }
    return post.likesCount;
  }

  /// Get comments count (frontend state takes priority)
  int getPostCommentsCount(Post post) {
    if (_postComments.containsKey(post.id)) {
      return _postComments[post.id]?.length ?? post.commentsCount;
    }
    return post.commentsCount;
  }

  /// Add comment (frontend only)
  void addComment(String postId, Map<String, dynamic> comment) {
    if (!_postComments.containsKey(postId)) {
      _postComments[postId] = [];
    }
    _postComments[postId]!.add(comment);
  }

  /// Get comments for a post
  List<Map<String, dynamic>> getComments(String postId) {
    return _postComments[postId] ?? [];
  }

  /// Clear all state (useful for logout)
  void clear() {
    _likedPosts.clear();
    _postLikesCount.clear();
    _postComments.clear();
  }
}

