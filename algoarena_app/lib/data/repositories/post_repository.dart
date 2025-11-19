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
  
  // Create new post
  Future<Post> createPost({
    required String content,
    List<String>? imagePaths,
  }) async {
    try {
      final response = await _apiService.post(
        '/posts',
        {
          'content': content,
          if (imagePaths != null) 'images': imagePaths,
        },
        withAuth: true,
      );
      
      return Post.fromJson(response['post']);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
  
  // Like/Unlike post
  Future<void> toggleLike(String postId) async {
    try {
      await _apiService.post('/posts/$postId/like', {}, withAuth: true);
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }
  
  // Add comment to post
  Future<Comment> addComment(String postId, String text) async {
    try {
      final response = await _apiService.post(
        '/posts/$postId/comment',
        {'text': text},
        withAuth: true,
      );
      
      return Comment.fromJson(response['comment']);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
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
