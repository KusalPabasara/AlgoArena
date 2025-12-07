import '../models/post.dart';
import '../services/api_service.dart';

class PostRepository {
  final ApiService _apiService = ApiService();
  
  // Get feed posts
  Future<List<Post>> getFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/posts?page=$page&limit=$limit',
        withAuth: true,
      );
      
      final posts = (response['posts'] as List)
          .map((post) => Post.fromJson(post))
          .toList();
      
      return posts;
    } catch (e) {
      throw Exception('Failed to load feed: $e');
    }
  }

  // Get posts by page ID
  Future<List<Post>> getPostsByPage(String pageId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/posts/page/$pageId?page=$page&limit=$limit',
        withAuth: true,
      );
      
      final posts = (response['posts'] as List)
          .map((post) => Post.fromJson(post))
          .toList();
      
      return posts;
    } catch (e) {
      throw Exception('Failed to load page posts: $e');
    }
  }
  
  // Create new post
  Future<Post> createPost({
    required String content,
    List<String>? imagePaths,
    String? pageId, // Optional page ID for page-specific posts
  }) async {
    try {
      final response = await _apiService.post(
        '/posts',
        {
          'content': content,
          if (imagePaths != null) 'images': imagePaths,
          if (pageId != null) 'pageId': pageId,
        },
        withAuth: true,
      );
      
      return Post.fromJson(response['post'] ?? response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Update existing post (content and images)
  Future<Post> updatePost({
    required String postId,
    required String content,
    List<String>? imagePaths,
  }) async {
    try {
      final response = await _apiService.put(
        '/posts/$postId',
        {
          'content': content,
          if (imagePaths != null) 'images': imagePaths,
        },
        withAuth: true,
      );

      // Backend returns { message, post: {...} }
      final data = response['post'] ?? response;
      return Post.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }
  
  // Like/Unlike post
  Future<Map<String, dynamic>?> toggleLike(String postId) async {
    try {
      final response = await _apiService.put('/posts/$postId/like', {}, withAuth: true);
      // Backend returns { likes: [...], likesCount: number }
      return response as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }
  
  // Add comment to post
  Future<Comment> addComment(String postId, String text) async {
    try {
      final response = await _apiService.post(
        '/posts/$postId/comments',
        {'text': text},
        withAuth: true,
      );
      
      // Backend returns the comment directly with this structure:
      // {
      //   id: string,
      //   user: { _id: string, fullName: string, profilePhoto: string },
      //   text: string,
      //   createdAt: string (ISO format)
      // }
      
      // Handle different response formats
      Map<String, dynamic> commentData;
      
      try {
        if (response['comment'] != null) {
          commentData = Map<String, dynamic>.from(response['comment']);
        } else if (response['id'] != null || response['user'] != null) {
          // It's the comment object directly
          commentData = Map<String, dynamic>.from(response);
        } else if (response is List && response.isNotEmpty) {
          // Fallback: if backend still returns a list, get the last one
          final lastItem = response[response.length - 1];
          commentData = lastItem is Map<String, dynamic> 
              ? lastItem 
              : Map<String, dynamic>.from(lastItem);
        } else {
          // Log the actual response for debugging
          print('Unexpected response format: $response');
          throw Exception('Invalid response format from server');
        }
      } catch (e) {
        print('Error parsing comment response: $e');
        print('Response was: $response');
        rethrow;
      }
      
      // Ensure createdAt is a valid ISO string
      if (commentData['createdAt'] == null) {
        commentData['createdAt'] = DateTime.now().toIso8601String();
      } else if (commentData['createdAt'] is! String) {
        // If it's not a string, try to convert it
        try {
          final date = commentData['createdAt'];
          if (date is Map && date['_seconds'] != null) {
            // Firestore Timestamp format
            commentData['createdAt'] = DateTime.fromMillisecondsSinceEpoch(
              (date['_seconds'] as int) * 1000
            ).toIso8601String();
          } else {
            commentData['createdAt'] = DateTime.now().toIso8601String();
          }
        } catch (e) {
          commentData['createdAt'] = DateTime.now().toIso8601String();
        }
      }
      
      // Ensure user object exists and has required fields
      if (commentData['user'] == null) {
        throw Exception('Comment response missing user data');
      }
      
      // Ensure user is a Map
      if (commentData['user'] is! Map) {
        throw Exception('Comment response user field is not an object');
      }
      
      // Validate required fields
      final user = commentData['user'] as Map<String, dynamic>;
      if (user['_id'] == null && user['id'] == null) {
        throw Exception('Comment response missing user ID');
      }
      
      return Comment.fromJson(commentData);
    } catch (e) {
      // Provide more helpful error messages
      final errorMessage = e.toString();
      if (errorMessage.contains('Invalid JSON') || errorMessage.contains('Invalid response')) {
        throw Exception('Invalid JSON response from server. Please try again.');
      }
      if (errorMessage.contains('Network error')) {
        throw Exception('Network error. Please check your connection and try again.');
      }
      // Re-throw the original error with context
      throw Exception('Failed to add comment: ${errorMessage.replaceAll('Exception: ', '')}');
    }
  }
  
  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _apiService.delete('/posts/$postId', withAuth: true);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
  
  // Get user posts
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await _apiService.get(
        '/posts/user/$userId',
        withAuth: true,
      );
      
      final posts = (response['posts'] as List)
          .map((post) => Post.fromJson(post))
          .toList();
      
      return posts;
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }
  
  // Get post by ID
  Future<Post> getPostById(String postId) async {
    try {
      final response = await _apiService.get(
        '/posts/$postId',
        withAuth: true,
      );
      
      return Post.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }
}
