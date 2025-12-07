class Page {
  final String id;
  final String name;
  final String type; // 'club' or 'district'
  final String? description;
  final String? logo;
  final String? mapImage; // Map image for district pages
  final String? coverPhoto;
  final String? clubId;
  final String? districtId;
  final List<String> webmasterIds; // Leo IDs of webmasters
  final int followersCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Page({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.logo,
    this.mapImage,
    this.coverPhoto,
    this.clubId,
    this.districtId,
    required this.webmasterIds,
    this.followersCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    // Handle date parsing - backend might return Firestore timestamp or ISO string
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      // Handle Firestore timestamp format {_seconds: ..., _nanoseconds: ...}
      if (dateValue is Map && dateValue['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          (dateValue['_seconds'] as int) * 1000,
        );
      }
      return DateTime.now();
    }

    return Page(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'club',
      description: json['description'],
      logo: json['logo'],
      mapImage: json['mapImage'],
      coverPhoto: json['coverPhoto'],
      clubId: json['clubId'],
      districtId: json['districtId'],
      webmasterIds: List<String>.from(json['webmasterIds'] ?? []),
      followersCount: json['followersCount'] ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'description': description,
      'logo': logo,
      'mapImage': mapImage,
      'coverPhoto': coverPhoto,
      'clubId': clubId,
      'districtId': districtId,
      'webmasterIds': webmasterIds,
      'followersCount': followersCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

