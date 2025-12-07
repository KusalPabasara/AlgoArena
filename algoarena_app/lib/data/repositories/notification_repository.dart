import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  // Get all notifications for current user
  Future<List<Notification>> getAllNotifications() async {
    try {
      final response = await _apiService.get('/notifications', withAuth: true);
      final List<dynamic> data = response is List 
          ? response 
          : (response['notifications'] ?? []);
      
      return data.map((json) => Notification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '/notifications/$notificationId/read',
        {},
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put(
        '/notifications/read-all',
        {},
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/notifications/unread-count',
        withAuth: true,
      );
      return response['count'] ?? 0;
    } catch (e) {
      return 0; // Return 0 on error to avoid breaking the UI
    }
  }
}


