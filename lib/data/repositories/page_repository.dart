import '../models/page.dart';
import '../services/api_service.dart';

class PageRepository {
  final ApiService _apiService = ApiService();

  // Get all pages
  Future<List<Page>> getAllPages() async {
    try {
      final response = await _apiService.get('/pages', withAuth: true);
      final List<dynamic> data = response['pages'] ?? [];
      return data.map((json) => Page.fromJson(json)).toList();
    } catch (e) {
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
  }) async {
    try {
      final response = await _apiService.post(
        '/pages',
        {
          'name': name,
          'type': type,
          if (description != null) 'description': description,
          if (logo != null) 'logo': logo,
          if (coverPhoto != null) 'coverPhoto': coverPhoto,
          if (clubId != null) 'clubId': clubId,
          if (districtId != null) 'districtId': districtId,
          'webmasterIds': webmasterIds,
        },
        withAuth: true,
      );
      return Page.fromJson(response['page']);
    } catch (e) {
      throw Exception('Failed to create page: $e');
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
}

