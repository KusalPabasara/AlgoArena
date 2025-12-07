import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/environment.dart';

class ApiService {
  // API URL is now configured via Environment
  // To switch between dev/prod, update Environment.init() in main.dart
  // For production: set your deployed URL in lib/config/environment.dart
  static String get baseUrl => Environment.apiBaseUrl;
  
  final _storage = const FlutterSecureStorage();
  
  // Get auth token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // Delete auth token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Get headers with auth token
  Future<Map<String, String>> getHeaders({bool withAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool withAuth = false,
    Duration? timeout, // Optional custom timeout
  }) async {
    try {
      final timeoutDuration = timeout ?? const Duration(seconds: 30); // Default 30 seconds
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(withAuth: withAuth),
        body: json.encode(data),
      ).timeout(
        timeoutDuration,
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection and try again.');
        },
      );
      
      return _handleResponse(response);
    } catch (e) {
      // If it's already an Exception (from _handleResponse or timeout), rethrow it
      if (e is Exception) {
        rethrow;
      }
      // Only wrap network errors (connection issues, etc.)
      throw Exception('Network error: $e');
    }
  }
  
  // GET request
  Future<dynamic> get(
    String endpoint, {
    bool withAuth = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(withAuth: withAuth),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool withAuth = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(withAuth: withAuth),
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool withAuth = false,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(withAuth: withAuth),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Handle API response
  dynamic _handleResponse(http.Response response) {
    // Check if response is HTML (common for 404 or server errors)
    if (response.body.trim().startsWith('<!DOCTYPE') || 
        response.body.trim().startsWith('<html') ||
        response.headers['content-type']?.contains('text/html') == true) {
      throw Exception('Server returned HTML instead of JSON. This usually means the endpoint does not exist (404) or there is a server configuration issue.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        // Return as dynamic to handle both Map and List responses
        return decoded;
      } catch (e) {
        throw Exception('Invalid JSON response from server: ${e.toString()}');
      }
    } else {
      // Handle error response
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 
                            errorBody['error'] ?? 
                            'An error occurred';
        throw Exception(errorMessage);
      } catch (e) {
        // If it's already an Exception with the message, rethrow it
        if (e is Exception) {
          rethrow;
        }
        // If response body is not valid JSON (e.g., HTML error page)
        final errorText = response.body.length > 100 
            ? response.body.substring(0, 100) 
            : response.body;
        throw Exception('Server error (${response.statusCode}): $errorText');
      }
    }
  }
}
