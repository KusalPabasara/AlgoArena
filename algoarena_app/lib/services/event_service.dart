import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../data/services/api_service.dart';

/// Event Service - Handles all event-related API calls
class EventService {
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

  /// Get all events
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events'),
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
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Get events by club ID
  static Future<List<Map<String, dynamic>>> getEventsByClub(String clubId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events/club/$clubId'),
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
      print('Error fetching club events: $e');
      return [];
    }
  }

  /// Get events by district ID
  static Future<List<Map<String, dynamic>>> getEventsByDistrict(String districtId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events/district/$districtId'),
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
      print('Error fetching district events: $e');
      return [];
    }
  }

  /// Get single event by ID
  static Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final response = await _apiService.get('/events/$eventId', withAuth: true);
      return response;
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  /// Create new event (webmaster only)
  static Future<Map<String, dynamic>?> createEvent({
    required String title,
    required String eventDate,
    String? description,
    String? eventTime,
    String? location,
    String? clubId,
    String? districtId,
    String? bannerImage,
    String? category,
    int? maxParticipants,
  }) async {
    try {
      final data = {
        'title': title,
        'eventDate': eventDate,
        if (description != null) 'description': description,
        if (eventTime != null) 'eventTime': eventTime,
        if (location != null) 'location': location,
        if (clubId != null) 'clubId': clubId,
        if (districtId != null) 'districtId': districtId,
        if (bannerImage != null) 'bannerImage': bannerImage,
        if (category != null) 'category': category,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
      };

      final response = await _apiService.post('/events', data, withAuth: true);
      return response;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Update event
  static Future<Map<String, dynamic>?> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put('/events/$eventId', updates, withAuth: true);
      return response;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Delete event
  static Future<bool> deleteEvent(String eventId) async {
    try {
      await _apiService.delete('/events/$eventId', withAuth: true);
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  /// Join or leave event
  static Future<Map<String, dynamic>?> toggleParticipation(String eventId) async {
    try {
      final response = await _apiService.put('/events/$eventId/participate', {}, withAuth: true);
      return response;
    } catch (e) {
      print('Error toggling participation: $e');
      rethrow;
    }
  }

  /// Upload event banner image and return URL
  static Future<String?> uploadBannerImage(File imageFile) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$_baseUrl/events/upload-banner');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('banner', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading banner: $e');
      return null;
    }
  }
}
