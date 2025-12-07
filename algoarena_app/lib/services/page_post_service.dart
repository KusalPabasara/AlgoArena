import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
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

  /// Create a post for a page (using pageId)
  static Future<Map<String, dynamic>?> createPagePost({
    required String pageId,
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
      request.fields['pageId'] = pageId;

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final fileName = path.basename(file.path);
          final fileExtension = path.extension(fileName).toLowerCase();
          
          // Determine content type based on file extension
          String contentType = 'image/jpeg'; // Default
          if (fileExtension == '.png') {
            contentType = 'image/png';
          } else if (fileExtension == '.gif') {
            contentType = 'image/gif';
          } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
            contentType = 'image/jpeg';
          }
          
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            file.path,
            filename: fileName,
            contentType: http.MediaType.parse(contentType),
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
      print('Error creating page post: $e');
      rethrow;
    }
  }

  /// Create a post for a club (deprecated - use createPagePost with pageId)
  static Future<Map<String, dynamic>?> createClubPost({
    required String clubId,
    required String content,
    List<File>? images,
  }) async {
    // For backward compatibility, try to find page by clubId
    // This is a fallback - ideally use createPagePost with pageId
    return createPagePost(
      pageId: clubId, // Treat clubId as pageId
      content: content,
      images: images,
    );
  }

  /// Create a post for a district (deprecated - use createPagePost with pageId)
  static Future<Map<String, dynamic>?> createDistrictPost({
    required String districtId,
    required String content,
    List<File>? images,
  }) async {
    // For backward compatibility, try to find page by districtId
    // This is a fallback - ideally use createPagePost with pageId
    return createPagePost(
      pageId: districtId, // Treat districtId as pageId
      content: content,
      images: images,
    );
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
