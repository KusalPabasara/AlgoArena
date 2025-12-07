class LeoId {
  final String id;
  final String leoId;
  final String email;
  final String? fullName;
  final bool isUsed; // Whether the Leo ID has been verified
  final DateTime createdAt;
  final DateTime updatedAt;

  // Helper function to parse Firestore timestamps
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    
    // If it's already a string (ISO format)
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // If it's a Map with _seconds (Firestore timestamp format)
    if (timestamp is Map) {
      if (timestamp['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          (timestamp['_seconds'] as int) * 1000,
        );
      }
      // Try to parse as ISO string if it's in the map
      if (timestamp['seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          (timestamp['seconds'] as int) * 1000,
        );
      }
    }
    
    // Fallback to current time
    return DateTime.now();
  }

  LeoId({
    required this.id,
    required this.leoId,
    required this.email,
    this.fullName,
    this.isUsed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeoId.fromJson(Map<String, dynamic> json) {
    return LeoId(
      id: json['_id'] ?? json['id'] ?? '',
      leoId: json['leoId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      isUsed: json['isUsed'] ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'leoId': leoId,
      'email': email,
      'fullName': fullName,
      'isUsed': isUsed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

