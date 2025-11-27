import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../data/services/api_service.dart';

/// Service for club and district page posts
class PagePostService {
  static final ApiService _apiService = ApiService();
  static String get _baseUrl => Environment.apiBaseUrl;
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get posts for a specific club
  static Future<List<Map<String, dynamic>>> getClubPosts(String clubId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/club/$clubId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching club posts: $e');
      return [];
    }
  }

  /// Get posts for a specific district
  static Future<List<Map<String, dynamic>>> getDistrictPosts(String districtId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/district/$districtId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching district posts: $e');
      return [];
    }
  }

  /// Create a post for a club
  static Future<Map<String, dynamic>?> createClubPost({
    required String clubId,
    required String content,
    List<File>? images,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$_baseUrl/posts');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      request.fields['clubId'] = clubId;

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            images[i].path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create post: ${response.statusCode}');
    } catch (e) {
      print('Error creating club post: $e');
      rethrow;
    }
  }

  /// Create a post for a district
  static Future<Map<String, dynamic>?> createDistrictPost({
    required String districtId,
    required String content,
    List<File>? images,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$_baseUrl/posts');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      request.fields['districtId'] = districtId;

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            images[i].path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create post: ${response.statusCode}');
    } catch (e) {
      print('Error creating district post: $e');
      rethrow;
    }
  }

  /// Like/unlike a post
  static Future<Map<String, dynamic>?> toggleLike(String postId) async {
    try {
      final response = await _apiService.put('/posts/$postId/like', {}, withAuth: true);
      return response;
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  /// Add comment to a post
  static Future<Map<String, dynamic>?> addComment(String postId, String text) async {
    try {
      final response = await _apiService.post(
        '/posts/$postId/comments',
        {'text': text},
        withAuth: true,
      );
      return response;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Delete a post
  static Future<bool> deletePost(String postId) async {
    try {
      await _apiService.delete('/posts/$postId', withAuth: true);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }
}
