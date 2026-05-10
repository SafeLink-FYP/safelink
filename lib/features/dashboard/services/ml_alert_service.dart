import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:safelink/core/secrets/app_secrets.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';

class MlAlertService extends GetxService {
  String get _base => AppSecrets.mlApiBaseUrl;

  Future<List<EarthquakeAlertModel>> checkEarthquakes(
    double latitude,
    double longitude, {
    bool pakistanOnly = true,
  }) async {
    final uri = Uri.parse('$_base/earthquake/check');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'latitude': latitude,
            'longitude': longitude,
            'pakistan_only': pakistanOnly,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Earthquake check failed: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => EarthquakeAlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FloodAlertModel> checkFloodRisk(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse('$_base/flood/check');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flood check failed: ${response.statusCode}');
    }

    return FloodAlertModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<FloodAlertModel> getFloodForecast(
    String date, {
    double latitude = 30.3753,
    double longitude = 69.3451,
  }) async {
    final uri = Uri.parse('$_base/flood/forecast').replace(
      queryParameters: {
        'date': date,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    final response =
        await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flood forecast failed: ${response.statusCode}');
    }

    return FloodAlertModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<HistoricalFloodEvent>> getHistoricalFloods() async {
    final uri = Uri.parse('$_base/flood/historical');
    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Historical floods failed: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (e) => HistoricalFloodEvent.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<FloodHeatmapPoint>> getHistoricalModelHeatmap(int year) async {
    final uri = Uri.parse('$_base/flood/historical/model').replace(
      queryParameters: {'year': year.toString()},
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 90));
    if (response.statusCode != 200) {
      throw Exception('Historical model heatmap failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final grid = body['grid'] as List<dynamic>? ?? [];
    return grid
        .map((e) => FloodHeatmapPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FloodHeatmapPoint>> getFloodHeatmap() async {
    final uri = Uri.parse('$_base/flood/heatmap');
    final response =
        await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Heatmap fetch failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final grid = body['grid'] as List<dynamic>? ?? [];
    return grid
        .map(
          (e) => FloodHeatmapPoint.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
