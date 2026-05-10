class ProfileModel {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? phone;
  final String? cnic;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String? region;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? updatedAt;

  const ProfileModel({
    required this.id,
    this.role = 'citizen',
    required this.fullName,
    required this.email,
    this.phone,
    this.cnic,
    this.dateOfBirth,
    this.avatarUrl,
    this.region,
    this.city,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String get lastName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.skip(1).join(' ') : '';
  }

  String get displayName => fullName.trim().isNotEmpty ? fullName : email;

  bool get isCitizen => role == 'citizen';
  bool get isGovOfficial => role == 'gov_official';
  bool get isAidWorker => role == 'aid_worker';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'citizen',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      cnic: json['cnic'] as String?,
      dateOfBirth: json['date_of_birth']?.toString(),
      avatarUrl: json['avatar_url'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'date_of_birth': dateOfBirth,
      'avatar_url': avatarUrl,
      'region': region,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? role,
    String? fullName,
    String? email,
    String? phone,
    String? cnic,
    String? dateOfBirth,
    String? avatarUrl,
    String? region,
    String? city,
    double? latitude,
    double? longitude,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      region: region ?? this.region,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
