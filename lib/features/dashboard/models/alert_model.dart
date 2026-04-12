class AlertModel {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String disasterType;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int radiusKm;
  final bool isActive;
  final String? issuedBy;
  final String? createdAt;
  final String? updatedAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.disasterType,
    this.location,
    this.latitude,
    this.longitude,
    this.radiusKm = 50,
    this.isActive = true,
    this.issuedBy,
    this.createdAt,
    this.updatedAt,
  });

  String get type => disasterType;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      disasterType: json['disaster_type'] as String? ?? 'other',
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radius_km'] as num?)?.toInt() ?? 50,
      isActive: json['is_active'] as bool? ?? true,
      issuedBy: json['issued_by'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'disaster_type': disasterType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'is_active': isActive,
      'issued_by': issuedBy,
    };
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final created = DateTime.tryParse(createdAt!);
    if (created == null) return '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
