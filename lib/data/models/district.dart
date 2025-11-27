class District {
  final String id;
  final String name;
  final String? logo;
  final String description;
  final List<String> clubs;
  final String adminId;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  District({
    required this.id,
    required this.name,
    this.logo,
    required this.description,
    required this.clubs,
    required this.adminId,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'] ?? '',
      clubs: List<String>.from(json['clubs'] ?? []),
      adminId: json['admin']?['_id'] ?? json['admin'] ?? '',
      location: json['location'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'clubs': clubs,
      'admin': adminId,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get clubsCount => clubs.length;
}
