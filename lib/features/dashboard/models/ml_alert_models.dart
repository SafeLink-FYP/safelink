class AftershockModel {
  final int rank;
  final double magnitude;
  final double latitude;
  final double longitude;
  final double depthKm;
  final double confidence;

  const AftershockModel({
    required this.rank,
    required this.magnitude,
    required this.latitude,
    required this.longitude,
    required this.depthKm,
    required this.confidence,
  });

  int get likelihoodPercent => (confidence * 100).round();

  factory AftershockModel.fromJson(Map<String, dynamic> json) {
    return AftershockModel(
      rank: (json['rank'] as num).toInt(),
      magnitude: (json['magnitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      depthKm: (json['depth_km'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class EarthquakeAlertModel {
  final String eventId;
  final double mainshockMagnitude;
  final double mainshockLatitude;
  final double mainshockLongitude;
  final double mainshockDepthKm;
  final String mainshockTimestamp;
  final String mainshockLocation;
  final List<AftershockModel> predictedAftershocks;
  final double distanceToUserKm;
  final bool shouldAlert;
  final String message;

  const EarthquakeAlertModel({
    required this.eventId,
    required this.mainshockMagnitude,
    required this.mainshockLatitude,
    required this.mainshockLongitude,
    required this.mainshockDepthKm,
    required this.mainshockTimestamp,
    required this.mainshockLocation,
    required this.predictedAftershocks,
    required this.distanceToUserKm,
    required this.shouldAlert,
    required this.message,
  });

  factory EarthquakeAlertModel.fromJson(Map<String, dynamic> json) {
    final aftershocks = (json['predicted_aftershocks'] as List? ?? [])
        .map((e) => AftershockModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return EarthquakeAlertModel(
      eventId: json['mainshock_event_id'] as String? ?? '',
      mainshockMagnitude:
          (json['mainshock_magnitude'] as num?)?.toDouble() ?? 0,
      mainshockLatitude: (json['mainshock_latitude'] as num?)?.toDouble() ?? 0,
      mainshockLongitude:
          (json['mainshock_longitude'] as num?)?.toDouble() ?? 0,
      mainshockDepthKm:
          (json['mainshock_depth_km'] as num?)?.toDouble() ?? 0,
      mainshockTimestamp: json['mainshock_timestamp'] as String? ?? '',
      mainshockLocation: json['mainshock_location'] as String? ?? 'Unknown',
      predictedAftershocks: aftershocks,
      distanceToUserKm:
          (json['distance_to_user_km'] as num?)?.toDouble() ?? 0,
      shouldAlert: json['should_alert'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  String get magnitudeLabel => 'M${mainshockMagnitude.toStringAsFixed(1)}';

  String get severity {
    if (mainshockMagnitude >= 7.0) return 'Critical';
    if (mainshockMagnitude >= 5.5) return 'High';
    if (mainshockMagnitude >= 4.0) return 'Moderate';
    return 'Low';
  }
}

class FloodAlertModel {
  final String riskLevel;
  final double riskScore;
  final double rainfallMm;
  final List<String> affectedAreas;
  final bool shouldAlert;
  final String? dataDate;

  const FloodAlertModel({
    required this.riskLevel,
    required this.riskScore,
    required this.rainfallMm,
    required this.affectedAreas,
    required this.shouldAlert,
    this.dataDate,
  });

  int get riskPercent => riskScore.round();

  factory FloodAlertModel.fromJson(Map<String, dynamic> json) {
    return FloodAlertModel(
      riskLevel: json['risk_level'] as String? ?? 'LOW',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0,
      affectedAreas:
          (json['affected_areas'] as List? ?? []).cast<String>(),
      shouldAlert: json['should_alert'] as bool? ?? false,
      dataDate: json['data_date'] as String?,
    );
  }
}

class HistoricalFloodRegion {
  final double lat;
  final double lng;
  final double radiusKm;
  final String district;

  const HistoricalFloodRegion({
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.district,
  });

  factory HistoricalFloodRegion.fromJson(Map<String, dynamic> json) {
    return HistoricalFloodRegion(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      radiusKm: (json['radius_km'] as num).toDouble(),
      district: json['district'] as String? ?? '',
    );
  }
}

class HistoricalFloodEvent {
  final int year;
  final String label;
  final String description;
  final int deaths;
  final double affectedMillions;
  final List<HistoricalFloodRegion> regions;

  const HistoricalFloodEvent({
    required this.year,
    required this.label,
    required this.description,
    required this.deaths,
    required this.affectedMillions,
    required this.regions,
  });

  factory HistoricalFloodEvent.fromJson(Map<String, dynamic> json) {
    final regions = (json['regions'] as List? ?? [])
        .map((e) => HistoricalFloodRegion.fromJson(e as Map<String, dynamic>))
        .toList();
    return HistoricalFloodEvent(
      year: (json['year'] as num).toInt(),
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      deaths: (json['deaths'] as num?)?.toInt() ?? 0,
      affectedMillions: (json['affected_millions'] as num?)?.toDouble() ?? 0,
      regions: regions,
    );
  }
}

class FloodHeatmapPoint {
  final double lat;
  final double lon;
  final double riskScore;
  final String riskLevel;
  final double rainfallMm;

  const FloodHeatmapPoint({
    required this.lat,
    required this.lon,
    required this.riskScore,
    required this.riskLevel,
    this.rainfallMm = 0,
  });

  factory FloodHeatmapPoint.fromJson(Map<String, dynamic> json) {
    final score = (json['risk_score'] as num?)?.toDouble() ?? 0;
    String level = json['risk_level'] as String? ?? '';
    if (level.isEmpty) {
      if (score >= 80) {
        level = 'CRITICAL';
      } else if (score >= 60) {
        level = 'HIGH';
      } else if (score >= 40) {
        level = 'MODERATE';
      } else {
        level = 'LOW';
      }
    }
    return FloodHeatmapPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      riskScore: score,
      riskLevel: level,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0,
    );
  }
}
