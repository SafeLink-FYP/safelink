class AidRequestModel {
  final String id;
  final String userId;
  final String type; // medical, food, shelter, clothing, water, other
  final String? description;
  final String urgency; // low, medium, high, critical
  final String status; // pending, approved, in_progress, fulfilled, rejected
  final int quantity;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? fulfilledBy;
  final String? fulfilledAt;
  final String? createdAt;
  final String? updatedAt;

  const AidRequestModel({
    required this.id,
    required this.userId,
    required this.type,
    this.description,
    required this.urgency,
    this.status = 'pending',
    this.quantity = 1,
    this.latitude,
    this.longitude,
    this.address,
    this.fulfilledBy,
    this.fulfilledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AidRequestModel.fromJson(Map<String, dynamic> json) {
    return AidRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      urgency: json['urgency'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      quantity: json['quantity'] as int? ?? 1,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      fulfilledBy: json['fulfilled_by'] as String?,
      fulfilledAt: json['fulfilled_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'description': description,
      'urgency': urgency,
      'status': status,
      'quantity': quantity,
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
