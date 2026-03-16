enum SOSType {
  medical,
  flood,
  earthquake;

  String get label {
    switch (this) {
      case SOSType.medical:
        return 'Medical';
      case SOSType.flood:
        return 'Flood';
      case SOSType.earthquake:
        return 'Earthquake';
    }
  }

  static SOSType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medical':
        return SOSType.medical;
      case 'flood':
        return SOSType.flood;
      case 'earthquake':
        return SOSType.earthquake;
      default:
        return SOSType.medical;
    }
  }
}

class SOSRequestModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String? address;
  final String? description;
  final SOSType type;
  final String urgency;
  final String status;
  final int peopleCount;
  final String? assignedTeamId;
  final String? respondedBy;
  final String? respondedAt;
  final String? resolvedAt;
  final String? createdAt;
  final String? updatedAt;

  const SOSRequestModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.description,
    required this.type,
    required this.urgency,
    required this.status,
    this.peopleCount = 1,
    this.assignedTeamId,
    this.respondedBy,
    this.respondedAt,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SOSRequestModel.fromJson(Map<String, dynamic> json) {
    return SOSRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      description: json['description'] as String?,
      type: SOSType.fromString(json['type'] as String? ?? 'medical'),
      urgency: json['urgency'] as String,
      status: json['status'] as String,
      peopleCount: json['people_count'] as int? ?? 1,
      assignedTeamId: json['assigned_team_id'] as String?,
      respondedBy: json['responded_by'] as String?,
      respondedAt: json['responded_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'type': type.name,
      'urgency': urgency,
      'status': status,
      'people_count': peopleCount,
      'assigned_team_id': assignedTeamId,
      'responded_by': respondedBy,
      'responded_at': respondedAt,
      'resolved_at': resolvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  SOSRequestModel copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
    String? urgency,
    SOSType? type,
    String? status,
    int? peopleCount,
    String? assignedTeamId,
    String? respondedBy,
    String? respondedAt,
    String? resolvedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return SOSRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      description: description ?? this.description,
      type: type ?? this.type,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      peopleCount: peopleCount ?? this.peopleCount,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      respondedBy: respondedBy ?? this.respondedBy,
      respondedAt: respondedAt ?? this.respondedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
