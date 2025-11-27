class Club {
  final String id;
  final String name;
  final String? logo;
  final String description;
  final String districtId;
  final String? districtName;
  final List<String> members;
  final String adminId;
  final Location location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? mutualCount;
  final bool? isFollowing;

  Club({
    required this.id,
    required this.name,
    this.logo,
    required this.description,
    required this.districtId,
    this.districtName,
    required this.members,
    required this.adminId,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.mutualCount,
    this.isFollowing,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'] ?? '',
      districtId: json['district']?['_id'] ?? json['district'] ?? '',
      districtName: json['district']?['name'],
      members: List<String>.from(json['members'] ?? []),
      adminId: json['admin']?['_id'] ?? json['admin'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
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
      'district': districtId,
      'members': members,
      'admin': adminId,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get membersCount => members.length;
  
  String? get imageUrl => logo;
  
  Club copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    String? districtId,
    String? districtName,
    List<String>? members,
    String? adminId,
    Location? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? mutualCount,
    bool? isFollowing,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      members: members ?? this.members,
      adminId: adminId ?? this.adminId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mutualCount: mutualCount ?? this.mutualCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class Location {
  final String country;
  final String city;

  Location({
    required this.country,
    required this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
    };
  }

  String get fullLocation => '$city, $country';
}
