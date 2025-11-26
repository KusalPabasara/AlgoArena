import '../models/leo_id.dart';
import '../services/api_service.dart';

class LeoIdRepository {
  final ApiService _apiService = ApiService();

  // Get all Leo IDs
  Future<List<LeoId>> getAllLeoIds() async {
    try {
      final response = await _apiService.get('/admin/leo-ids', withAuth: true);
      final List<dynamic> data = response['leoIds'] ?? [];
      return data.map((json) => LeoId.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get Leo IDs: $e');
    }
  }

  // Add Leo ID
  Future<LeoId> addLeoId({
    required String leoId,
    required String email,
    String? fullName,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/leo-ids',
        {
          'leoId': leoId,
          'email': email,
          if (fullName != null) 'fullName': fullName,
        },
        withAuth: true,
      );
      return LeoId.fromJson(response['leoId']);
    } catch (e) {
      throw Exception('Failed to add Leo ID: $e');
    }
  }

  // Delete Leo ID
  Future<void> deleteLeoId(String leoIdId) async {
    try {
      await _apiService.delete('/admin/leo-ids/$leoIdId', withAuth: true);
    } catch (e) {
      throw Exception('Failed to delete Leo ID: $e');
    }
  }

  // Get user by Leo ID
  Future<Map<String, dynamic>?> getUserByLeoId(String leoId) async {
    try {
      final response = await _apiService.get('/admin/leo-ids/lookup/$leoId', withAuth: true);
      return response['user'];
    } catch (e) {
      return null;
    }
  }
}

