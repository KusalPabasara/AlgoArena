class User {
  final String id;
  final String fullName;
  final String email;
  final String? profilePhoto;
  final String? bio;
  final String? phoneNumber;
  final String? leoClubId;
  final String? districtId;
  final String role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePhoto,
    this.bio,
    this.phoneNumber,
    this.leoClubId,
    this.districtId,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profilePhoto: json['profilePhoto'],
      bio: json['bio'],
      phoneNumber: json['phoneNumber'],
      leoClubId: json['leoClub'],
      districtId: json['district'],
      role: json['role'] ?? 'member',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profilePhoto': profilePhoto,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'leoClub': leoClubId,
      'district': districtId,
      'role': role,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profilePhoto,
    String? bio,
    String? phoneNumber,
    String? leoClubId,
    String? districtId,
    String? role,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      leoClubId: leoClubId ?? this.leoClubId,
      districtId: districtId ?? this.districtId,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Role helper getters
  bool get isSuperAdmin => role.toLowerCase() == 'superadmin' || role.toLowerCase() == 'super_admin';
  bool get isWebmaster => role.toLowerCase() == 'webmaster' || isSuperAdmin;
  bool get isAdmin => role.toLowerCase() == 'admin' || isWebmaster;
  bool get canCreatePages => isSuperAdmin;
  bool get canCreatePosts => isAdmin || isWebmaster || isSuperAdmin;

  // Display role for UI
  String get displayRole {
    if (isSuperAdmin) return 'Super Admin';
    if (isWebmaster) return 'Webmaster';
    if (isAdmin) return 'Admin';
    return role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : 'Member';
  }
}
