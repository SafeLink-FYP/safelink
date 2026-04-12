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
  final SOSType disasterType;
  final String? description;
  final String urgency;
  final String status;
  final double latitude;
  final double longitude;
  final String? address;
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
    required this.disasterType,
    this.description,
    required this.urgency,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.address,
    this.peopleCount = 1,
    this.assignedTeamId,
    this.respondedBy,
    this.respondedAt,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  SOSType get type => disasterType;

  factory SOSRequestModel.fromJson(Map<String, dynamic> json) {
    return SOSRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      disasterType: SOSType.fromString(
        json['disaster_type'] as String? ?? 'medical',
      ),
      description: json['description'] as String?,
      urgency: json['urgency'] as String? ?? 'critical',
      status: json['status'] as String? ?? 'pending',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      peopleCount: (json['people_count'] as num?)?.toInt() ?? 1,
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
      'user_id': userId,
      'disaster_type': disasterType.name,
      'description': description,
      'urgency': urgency,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'people_count': peopleCount,
    };
  }

  SOSRequestModel copyWith({
    String? id,
    String? userId,
    SOSType? disasterType,
    String? description,
    String? urgency,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
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
      disasterType: disasterType ?? this.disasterType,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
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
