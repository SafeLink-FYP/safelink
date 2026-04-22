class AidRequestModel {
  final String id;
  final String userId;
  final String aidType;
  final String description;
  final String urgency;
  final String status;
  final int quantity;
  final int peopleAffected;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? assignedTeamId;
  final String? fulfilledBy;
  final String? fulfilledAt;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;

  const AidRequestModel({
    required this.id,
    required this.userId,
    required this.aidType,
    required this.description,
    required this.urgency,
    this.status = 'pending',
    this.quantity = 1,
    this.peopleAffected = 1,
    this.imageUrls = const [],
    this.latitude,
    this.longitude,
    this.address,
    this.assignedTeamId,
    this.fulfilledBy,
    this.fulfilledAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  String get type => aidType;

  factory AidRequestModel.fromJson(Map<String, dynamic> json) {
    return AidRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      aidType: json['aid_type'] as String? ?? 'other',
      description: json['description'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'high',
      status: json['status'] as String? ?? 'pending',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      peopleAffected: (json['people_affected'] as num?)?.toInt() ?? 1,
      imageUrls: (json['image_urls'] as List?)?.cast<String>() ?? const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      assignedTeamId: json['assigned_team_id'] as String?,
      fulfilledBy: json['fulfilled_by'] as String?,
      fulfilledAt: json['fulfilled_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'aid_type': aidType,
      'description': description,
      'urgency': urgency,
      'status': status,
      'quantity': quantity,
      'people_affected': peopleAffected,
      'image_urls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
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
