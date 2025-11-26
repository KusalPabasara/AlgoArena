class LeoId {
  final String id;
  final String leoId;
  final String email;
  final String? fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeoId({
    required this.id,
    required this.leoId,
    required this.email,
    this.fullName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeoId.fromJson(Map<String, dynamic> json) {
    return LeoId(
      id: json['_id'] ?? json['id'] ?? '',
      leoId: json['leoId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'leoId': leoId,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

