import 'dart:async';
import '../models/leo_id.dart';
import '../services/api_service.dart';

class LeoIdRepository {
  final ApiService _apiService = ApiService();

  // Get all Leo IDs
  Future<List<LeoId>> getAllLeoIds() async {
    try {
      // Check if we have a token (super admin might not have one)
      final token = await _apiService.getToken();
      if (token == null) {
        // Super admin or not authenticated - return empty list
        return [];
      }
      
      final response = await _apiService.get('/admin/leo-ids', withAuth: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      final List<dynamic> data = response['leoIds'] ?? [];
      return data.map((json) => LeoId.fromJson(json)).toList();
    } catch (e) {
      // For super admin or missing token, return empty list instead of throwing
      final token = await _apiService.getToken();
      if (token == null) {
        return [];
      }
      // Check if it's an auth error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('401') || errorStr.contains('403')) {
        return [];
      }
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

  // Create Leo ID by email (Super Admin only)
  Future<Map<String, dynamic>> createLeoIdByEmail(String email) async {
    try {
      // Check if we have a token (super admin might not have one)
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated. The super admin account may not exist in the backend. Please contact the system administrator to create the super admin account in Firebase Auth, or log out and log in again.');
      }
      
      final response = await _apiService.post(
        '/admin/create-leo-id-by-email',
        {'email': email},
        withAuth: true,
      ).timeout(
        const Duration(seconds: 60), // Increased timeout for email sending
        onTimeout: () {
          throw Exception('Request timeout. The server may be processing your request. Please check your internet connection and try again.');
        },
      );
      return response;
    } catch (e) {
      // Extract the actual error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Request timeout. Please check your internet connection and try again.';
      } else if (errorMessage.contains('401') || errorMessage.contains('Not authorized')) {
        errorMessage = 'Authentication failed. Please log out and log in again.';
      } else if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
        errorMessage = 'Access denied. Only super admin can create Leo IDs.';
      }
      throw Exception('Failed to create Leo ID: $errorMessage');
    }
  }
}

