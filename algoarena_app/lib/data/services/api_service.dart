import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change this to your backend URL when deployed
  // For Android Emulator: http://10.0.2.2:5000/api
  // For Physical Device: http://YOUR_IP:5000/api
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(withAuth: withAuth),
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // GET request
  Future<Map<String, dynamic>> get(
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
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Debug: Print response details
    print('📡 API Response:');
    print('   Status: ${response.statusCode}');
    print('   URL: ${response.request?.url}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        print('   Success: ${decoded.containsKey('token') ? 'Token received' : 'No token'}');
        return decoded;
      } catch (e) {
        print('   ❌ JSON decode error: $e');
        print('   Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        throw Exception('Invalid JSON response from server: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        final errorMessage = error['message'] ?? 'An error occurred';
        print('   ❌ Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        // If response body is not valid JSON (e.g., HTML error page)
        final errorBody = response.body.length > 200 
            ? response.body.substring(0, 200) 
            : response.body;
        print('   ❌ Server error (${response.statusCode}): $errorBody');
        throw Exception('Server error (${response.statusCode}): $errorBody');
      }
    }
  }
}
