class AlertModel {
  final String id;
  final String title;
  final String? description;
  final String severity; // low, medium, high, critical
  final String type; // flood, earthquake, fire, storm, other
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool isActive;
  final String? issuedBy;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;

  const AlertModel({
    required this.id,
    required this.title,
    this.description,
    required this.severity,
    required this.type,
    this.location,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.isActive = true,
    this.issuedBy,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      severity: json['severity'] as String? ?? 'low',
      type: json['type'] as String? ?? 'other',
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radius_km'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      issuedBy: json['issued_by'] as String?,
      expiresAt: json['expires_at'] as String?,
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
      'type': type,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'is_active': isActive,
      'issued_by': issuedBy,
      'expires_at': expiresAt,
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
