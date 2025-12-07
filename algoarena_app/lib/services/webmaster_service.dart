import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';

/// Service for webmaster management (Super Admin only)
class WebmasterService {
  static String get _baseUrl => Environment.apiBaseUrl;
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    print('WebmasterService - Token retrieved: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NULL"}');
    return token;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('WebmasterService - Headers: ${headers.keys.toList()}');
    return headers;
  }

  /// Get all registered users (for super admin to select webmasters)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('WebmasterService - Fetching users from: $_baseUrl/webmasters/users');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/webmasters/users'),
        headers: headers,
      );
      print('WebmasterService - Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  /// Get all webmasters
  static Future<List<Map<String, dynamic>>> getWebmasters() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/webmasters'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error fetching webmasters: $e');
      return [];
    }
  }

  /// Get all Leo IDs
  static Future<List<Map<String, dynamic>>> getAllLeoIds() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/webmasters/leo-ids'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error fetching Leo IDs: $e');
      return [];
    }
  }

  /// Create Leo ID for a user (assign webmaster role)
  static Future<Map<String, dynamic>> createLeoId({
    required String userId,
    String? clubId,
    String? clubName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/webmasters/create-leo-id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': userId,
          'clubId': clubId ?? 'leo-club-colombo',
          'clubName': clubName ?? 'Leo Club of Colombo',
        }),
      );
      
      final decoded = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return decoded;
      }
      throw Exception(decoded['message'] ?? 'Failed to create Leo ID');
    } catch (e) {
      print('Error creating Leo ID: $e');
      rethrow;
    }
  }

  /// Verify Leo ID (for users who received a Leo ID)
  static Future<Map<String, dynamic>> verifyLeoId(String leoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/webmasters/verify-leo-id'),
        headers: await _getHeaders(),
        body: jsonEncode({'leoId': leoId}),
      );
      
      final decoded = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return decoded;
      }
      throw Exception(decoded['message'] ?? 'Failed to verify Leo ID');
    } catch (e) {
      print('Error verifying Leo ID: $e');
      rethrow;
    }
  }

  /// Revoke webmaster status
  static Future<void> revokeWebmaster(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/webmasters/$userId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Failed to revoke webmaster');
      }
    } catch (e) {
      print('Error revoking webmaster: $e');
      rethrow;
    }
  }
}
