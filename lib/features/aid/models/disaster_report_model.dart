class DisasterReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String disasterType;
  final String severity;
  final double latitude;
  final double longitude;
  final String? address;
  final List<String> imageUrls;
  final String status;
  final String? verifiedBy;
  final String? verifiedAt;
  final String? createdAt;
  final String? updatedAt;

  const DisasterReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.disasterType,
    this.severity = 'high',
    required this.latitude,
    required this.longitude,
    this.address,
    this.imageUrls = const [],
    this.status = 'pending',
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  String get type => disasterType;

  factory DisasterReportModel.fromJson(Map<String, dynamic> json) {
    return DisasterReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      disasterType: json['disaster_type'] as String? ?? 'other',
      severity: json['severity'] as String? ?? 'high',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      imageUrls: (json['image_urls'] as List?)?.cast<String>() ?? const [],
      status: json['status'] as String? ?? 'pending',
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'disaster_type': disasterType,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'image_urls': imageUrls,
      'status': status,
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
