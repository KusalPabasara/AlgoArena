class Notification {
  final String id;
  final String type; // 'page_created', 'event_created', 'event_closing', 'event_expired'
  final String title;
  final String message;
  final String? iconUrl; // URL to icon image
  final String? pageId; // Related page ID (if applicable)
  final String? eventId; // Related event ID (if applicable)
  final DateTime createdAt;
  final bool isRead;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.iconUrl,
    this.pageId,
    this.eventId,
    required this.createdAt,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Map && json['createdAt']['_seconds'] != null) {
        // Firestore timestamp format
        createdAt = DateTime.fromMillisecondsSinceEpoch(
          json['createdAt']['_seconds'] * 1000,
        );
      } else if (json['createdAt'] is String) {
        // ISO string format
        createdAt = DateTime.parse(json['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    return Notification(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? json['text'] ?? '',
      iconUrl: json['iconUrl'] ?? json['icon'] ?? json['imageUrl'],
      pageId: json['pageId'],
      eventId: json['eventId'],
      createdAt: createdAt,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'iconUrl': iconUrl,
      'pageId': pageId,
      'eventId': eventId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Get default icon based on notification type
  String getDefaultIconPath() {
    switch (type) {
      case 'page_created':
        return 'assets/images/notifications/page_created.png';
      case 'event_created':
        return 'assets/images/notifications/event_created.png';
      case 'event_closing':
        return 'assets/images/notifications/event_closing.png';
      case 'event_expired':
        return 'assets/images/notifications/event_expired.png';
      default:
        return 'assets/images/notifications/default.png';
    }
  }
}


