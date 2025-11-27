class Page {
  final String id;
  final String name;
  final String type; // 'club' or 'district'
  final String? description;
  final String? logo;
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
    this.coverPhoto,
    this.clubId,
    this.districtId,
    required this.webmasterIds,
    this.followersCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'club',
      description: json['description'],
      logo: json['logo'],
      coverPhoto: json['coverPhoto'],
      clubId: json['clubId'],
      districtId: json['districtId'],
      webmasterIds: List<String>.from(json['webmasterIds'] ?? []),
      followersCount: json['followersCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'description': description,
      'logo': logo,
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

