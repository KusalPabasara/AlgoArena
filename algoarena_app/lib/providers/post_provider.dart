import 'package:flutter/foundation.dart';
import '../data/models/post.dart';
import '../data/repositories/post_repository.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load feed posts
  Future<void> loadFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _posts.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPosts = await _postRepository.getFeed(page: _currentPage);
      
      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }
      
      if (newPosts.isEmpty || newPosts.length < 10) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create post
  Future<bool> createPost({
    required String content,
    List<String>? imagePaths,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final post = await _postRepository.createPost(
        content: content,
        imagePaths: imagePaths,
      );
      
      _posts.insert(0, post);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle like
  Future<void> toggleLike(String postId) async {
    try {
      await _postRepository.toggleLike(postId);
      
      // Update post in list
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final updatedPost = await _postRepository.getPostById(postId);
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Add comment
  Future<bool> addComment(String postId, String text) async {
    try {
      await _postRepository.addComment(postId, text);
      
      // Update post in list
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final updatedPost = await _postRepository.getPostById(postId);
        _posts[index] = updatedPost;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
