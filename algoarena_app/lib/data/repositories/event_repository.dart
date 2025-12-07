import 'dart:async';
import '../models/event.dart';
import '../services/api_service.dart';

class EventRepository {
  final ApiService _apiService = ApiService();

  // Get all events from backend
  Future<List<Event>> getAllEvents({String? currentUserId}) async {
    try {
      // Check if we have a token (super admin might not have one)
      final token = await _apiService.getToken();
      if (token == null) {
        // Super admin or not authenticated - return empty list
        return [];
      }
      
      final response = await _apiService.get('/events', withAuth: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      print('📦 EventRepository.getAllEvents: Response type: ${response.runtimeType}');
      print('📦 EventRepository.getAllEvents: Response: $response');
      
      final List<dynamic> data = response is List ? response : (response['events'] ?? []);
      print('📦 EventRepository.getAllEvents: Extracted ${data.length} events, currentUserId: $currentUserId');
      
      return data.map((json) {
        // Create a mutable copy to avoid modifying the original
        final eventJson = Map<String, dynamic>.from(json);
        // Add current user ID to determine if joined
        if (currentUserId != null) {
          eventJson['_currentUserId'] = currentUserId;
          // Debug: Log participant data for events with participants
          if (eventJson['participants'] != null && (eventJson['participants'] as List).isNotEmpty) {
            print('   🔍 Event ${eventJson['_id'] ?? eventJson['id']}: ${(eventJson['participants'] as List).length} participants');
            final firstParticipant = (eventJson['participants'] as List)[0];
            if (firstParticipant is Map) {
              print('      First participant keys: ${firstParticipant.keys.toList()}');
              print('      First participant userId: ${firstParticipant['userId']}, id: ${firstParticipant['id']}');
            } else {
              print('      First participant (String): $firstParticipant');
            }
          }
        }
        final event = Event.fromJson(eventJson);
        return event;
      }).toList();
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
      throw Exception('Failed to load events: $e');
    }
  }

  // Get event by ID
  Future<Event> getEventById(String id, {String? currentUserId}) async {
    try {
      final response = await _apiService.get('/events/$id', withAuth: true);
      final eventData = response['event'] ?? response;
      
      // Add current user ID to determine if joined
      if (currentUserId != null) {
        eventData['_currentUserId'] = currentUserId;
      }
      
      return Event.fromJson(eventData);
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }

  // Get joined events
  Future<List<Event>> getJoinedEvents() async {
    try {
      final events = await getAllEvents();
      return events.where((event) => event.isJoined).toList();
    } catch (e) {
      throw Exception('Failed to load joined events: $e');
    }
  }

  // Toggle join/leave event
  Future<Event> toggleJoinEvent(
    String eventId,
    bool isJoined, {
    String? name,
    String? email,
    String? phone,
    String? notes,
    String? currentUserId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (isJoined && name != null) data['name'] = name;
      if (isJoined && email != null) data['email'] = email;
      if (isJoined && phone != null) data['phone'] = phone;
      if (isJoined && notes != null) data['notes'] = notes;
      
      final response = await _apiService.put(
        '/events/$eventId/participate',
        data,
        withAuth: true,
      );
      
      // Get updated event with current user ID to determine isJoined status
      final updatedEvent = await getEventById(eventId, currentUserId: currentUserId);
      return updatedEvent.copyWith(isJoined: response['isParticipant'] ?? isJoined);
    } catch (e) {
      throw Exception('Failed to update event participation: $e');
    }
  }

  // Get event participants (for webmasters)
  Future<List<Map<String, dynamic>>> getEventParticipants(String eventId) async {
    try {
      final response = await _apiService.get('/events/$eventId/participants', withAuth: true);
      return List<Map<String, dynamic>>.from(response['participants'] ?? []);
    } catch (e) {
      throw Exception('Failed to load participants: $e');
    }
  }

  // Update event
  Future<Event> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/events/$eventId', updates, withAuth: true);
      return Event.fromJson(response['event'] ?? response);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _apiService.delete('/events/$eventId', withAuth: true);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
