import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/page.dart';
import '../services/api_service.dart';

class PageRepository {
  final ApiService _apiService = ApiService();

  // Get all pages
  Future<List<Page>> getAllPages() async {
    try {
      print('🔍 PageRepository.getAllPages: Starting...');
      // Check if we have a token (super admin might not have one)
      final token = await _apiService.getToken();
      if (token == null) {
        print('⚠️ PageRepository.getAllPages: No token found');
        // Super admin or not authenticated - return empty list
        return [];
      }
      
      print('🔍 PageRepository.getAllPages: Making API call to /pages');
      final response = await _apiService.get('/pages', withAuth: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ PageRepository.getAllPages: Request timeout');
          throw Exception('Request timeout');
        },
      );
      
      print('📦 PageRepository.getAllPages: Response received: ${response.runtimeType}');
      print('📦 PageRepository.getAllPages: Response keys: ${response.keys.toList()}');
      
      // Backend returns { pages: [...] } format
      final List<dynamic> data = response['pages'] ?? [];
      
      print('📦 PageRepository.getAllPages: Extracted ${data.length} pages from response');
      
      final pages = data.map((json) {
        try {
          return Page.fromJson(json);
        } catch (e) {
          print('❌ PageRepository.getAllPages: Error parsing page: $e');
          print('   JSON: $json');
          rethrow;
        }
      }).toList();
      
      print('✅ PageRepository.getAllPages: Successfully parsed ${pages.length} pages');
      return pages;
    } catch (e, stackTrace) {
      print('❌ PageRepository.getAllPages: Error: $e');
      print('📚 Stack trace: $stackTrace');
      
      // For super admin or missing token, return empty list instead of throwing
      final token = await _apiService.getToken();
      if (token == null) {
        print('⚠️ PageRepository.getAllPages: No token, returning empty list');
        return [];
      }
      // Check if it's an auth error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('401') || errorStr.contains('403')) {
        print('⚠️ PageRepository.getAllPages: Auth error, returning empty list');
        return [];
      }
      print('❌ PageRepository.getAllPages: Re-throwing error');
      throw Exception('Failed to get pages: $e');
    }
  }

  // Create page
  Future<Page> createPage({
    required String name,
    required String type,
    String? description,
    String? logo,
    String? coverPhoto,
    String? clubId,
    String? districtId,
    required List<String> webmasterIds,
    File? logoFile,
    File? mapImageFile, // Map image for district pages
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/pages');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      request.fields['name'] = name;
      request.fields['type'] = type;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (logo != null) {
        request.fields['logo'] = logo;
      }
      if (coverPhoto != null) {
        request.fields['coverPhoto'] = coverPhoto;
      }
      if (clubId != null) {
        request.fields['clubId'] = clubId;
      }
      if (districtId != null) {
        request.fields['districtId'] = districtId;
      }
      request.fields['webmasterIds'] = json.encode(webmasterIds);

      // Add logo file if provided
      if (logoFile != null) {
        final logoExtension = path.extension(logoFile.path).toLowerCase().replaceFirst('.', '');
        final logoContentType = _getContentType(logoExtension);
        final logoFileName = path.basename(logoFile.path);
        final logoMultipart = await http.MultipartFile.fromPath(
          'logo',
          logoFile.path,
          filename: logoFileName,
          contentType: logoContentType,
        );
        request.files.add(logoMultipart);
      }

      // Add map image file if provided (for district pages)
      if (mapImageFile != null) {
        final mapImageExtension = path.extension(mapImageFile.path).toLowerCase().replaceFirst('.', '');
        final mapImageContentType = _getContentType(mapImageExtension);
        final mapImageFileName = path.basename(mapImageFile.path);
        final mapImageMultipart = await http.MultipartFile.fromPath(
          'mapImage',
          mapImageFile.path,
          filename: mapImageFileName,
          contentType: mapImageContentType,
        );
        request.files.add(mapImageMultipart);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return Page.fromJson(responseData['page']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create page');
      }
    } catch (e) {
      throw Exception('Failed to create page: $e');
    }
  }

  // Update page (for webmasters to edit)
  Future<Page> updatePage({
    required String pageId,
    String? name,
    String? description,
    File? logoFile,
    String? logoUrl, // If updating with existing URL
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/pages/$pageId');
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      if (name != null) {
        request.fields['name'] = name;
      }
      if (description != null) {
        request.fields['description'] = description;
      }
      if (logoUrl != null) {
        request.fields['logo'] = logoUrl;
      }

      // Add logo file if provided
      if (logoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('logo', logoFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return Page.fromJson(responseData['page']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update page');
      }
    } catch (e) {
      throw Exception('Failed to update page: $e');
    }
  }

  // Get page by ID
  Future<Page> getPageById(String pageId) async {
    try {
      final response = await _apiService.get('/pages/$pageId', withAuth: true);
      return Page.fromJson(response['page']);
    } catch (e) {
      throw Exception('Failed to get page: $e');
    }
  }

  // Check if user is webmaster of a page
  Future<bool> isWebmaster(String pageId, String leoId) async {
    try {
      final response = await _apiService.get(
        '/pages/$pageId/webmaster/$leoId',
        withAuth: true,
      );
      return response['isWebmaster'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get pages where current user is a webmaster
  Future<List<Page>> getMyPages() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        return [];
      }
      
      final response = await _apiService.get('/pages/my-pages', withAuth: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      final List<dynamic> data = response is List 
          ? response 
          : (response['pages'] ?? []);
      return data.map((json) => Page.fromJson(json)).toList();
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('401') || errorStr.contains('403')) {
        return [];
      }
      throw Exception('Failed to get my pages: $e');
    }
  }

  // Follow/Unfollow a page
  Future<Map<String, dynamic>> toggleFollow(String pageId) async {
    try {
      final response = await _apiService.post(
        '/pages/$pageId/follow',
        {},
        withAuth: true,
      ).timeout(
        const Duration(seconds: 15), // 15 second timeout for follow
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection and try again.');
        },
      );
      return response;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('timeout') || errorMessage.contains('Timeout')) {
        throw Exception('Request timeout. Please check your internet connection and try again.');
      }
      throw Exception('Failed to toggle follow: $errorMessage');
    }
  }

  // Get follow status
  Future<bool> getFollowStatus(String pageId) async {
    try {
      final response = await _apiService.get(
        '/pages/$pageId/follow-status',
        withAuth: true,
      ).timeout(
        const Duration(seconds: 10),
      );
      return response['isFollowing'] ?? false;
    } catch (e) {
      // Return false on timeout or any error
      return false;
    }
  }

  // Get page stats
  Future<Map<String, dynamic>> getPageStats(String pageId) async {
    try {
      final response = await _apiService.get(
        '/pages/$pageId/stats',
        withAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Return default stats on timeout
          return {
            'followersCount': 0,
            'postsCount': 0,
            'eventsCount': 0,
          };
        },
      );
      return response;
    } catch (e) {
      // Return default stats on error instead of throwing
      return {
        'followersCount': 0,
        'postsCount': 0,
        'eventsCount': 0,
      };
    }
  }

  // Delete page (Super Admin only)
  Future<void> deletePage(String pageId) async {
    try {
      await _apiService.delete('/pages/$pageId', withAuth: true);
    } catch (e) {
      throw Exception('Failed to delete page: $e');
    }
  }

  // Helper method to get content type from file extension
  http.MediaType? _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return http.MediaType('image', 'jpeg');
      case 'png':
        return http.MediaType('image', 'png');
      case 'gif':
        return http.MediaType('image', 'gif');
      case 'webp':
        return http.MediaType('image', 'webp');
      default:
        return null; // Let the system determine
    }
  }
}

