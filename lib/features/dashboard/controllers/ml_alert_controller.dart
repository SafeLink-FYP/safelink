import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';
import 'package:safelink/features/dashboard/services/ml_alert_service.dart';

class MlAlertController extends GetxController {
  final MlAlertService _service = Get.find<MlAlertService>();

  final isLoadingEarthquakes = false.obs;
  final isLoadingFlood = false.obs;
  final isLoadingHeatmap = false.obs;
  final isLoadingForecast = false.obs;
  final isLoadingHistory = false.obs;
  final isLoadingHistoricalModel = false.obs;

  final earthquakeAlerts = <EarthquakeAlertModel>[].obs;
  final floodAlert = Rxn<FloodAlertModel>();
  final floodForecast = Rxn<FloodAlertModel>();
  final heatmapPoints = <FloodHeatmapPoint>[].obs;
  final historicalFloods = <HistoricalFloodEvent>[].obs;
  final historicalModelPoints = <FloodHeatmapPoint>[].obs;
  final selectedHistoricalYear = Rxn<int>();

  final selectedDate = DateTime.now().obs;

  double _lat = 30.3753;
  double _lng = 69.3451;

  @override
  void onInit() {
    super.onInit();
    ever(heatmapPoints, (_) => _updateFloodRiskFromHeatmap());
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 8));
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (_) {
      // Fall back to Pakistan center
    }
    loadEarthquakeAlerts();
    loadFloodHeatmap();
    loadFloodForecast(selectedDate.value);
    loadHistoricalFloods();
  }

  Future<void> loadEarthquakeAlerts() async {
    isLoadingEarthquakes.value = true;
    try {
      earthquakeAlerts.value = await _service.checkEarthquakes(
        _lat,
        _lng,
        pakistanOnly: false,
      );
    } catch (e) {
      Get.log('MlAlertController: earthquake error — $e');
      earthquakeAlerts.value = [];
    } finally {
      isLoadingEarthquakes.value = false;
    }
  }

  // Derives Pakistan-wide flood risk from already-loaded heatmap data.
  // Called automatically via ever() whenever heatmapPoints changes.
  void _updateFloodRiskFromHeatmap() {
    final pak = heatmapPoints.where(_inPakistan).toList();
    if (pak.isEmpty) {
      floodAlert.value = null;
      return;
    }

    final critical =
        pak.where((p) => p.riskLevel.toUpperCase() == 'CRITICAL').toList();
    final high =
        pak.where((p) => p.riskLevel.toUpperCase() == 'HIGH').toList();

    if (critical.isEmpty && high.isEmpty) {
      floodAlert.value = null;
      return;
    }

    final elevated = [...critical, ...high];
    final maxScore = elevated.fold<double>(
        0.0, (best, p) => p.riskScore > best ? p.riskScore : best);
    final avgRainfall = elevated.isEmpty
        ? 0.0
        : elevated.fold<double>(0.0, (s, p) => s + p.rainfallMm) /
            elevated.length;

    final areas = <String>[
      if (critical.isNotEmpty) '${critical.length} critical zone(s)',
      if (high.isNotEmpty) '${high.length} high-risk zone(s)',
    ];

    floodAlert.value = FloodAlertModel(
      riskLevel: critical.isNotEmpty ? 'CRITICAL' : 'HIGH',
      riskScore: maxScore,
      rainfallMm: avgRainfall,
      affectedAreas: areas,
      shouldAlert: true,
    );
  }

  static bool _inPakistan(FloodHeatmapPoint p) {
    final lat = p.lat, lon = p.lon;
    if (lat < 23.5 || lat > 37.2 || lon < 61.5 || lon > 77.2) return false;

    // Exclude Afghanistan (Durand Line)
    if (lat > 35.5 && lon < 71.5) return false;
    if (lat > 33.5 && lon < 71.0) return false;
    if (lat > 31.0 && lon < 67.0) return false;
    if (lat > 29.0 && lon < 64.5) return false;
    if (lat > 27.0 && lon < 63.0) return false;

    // Exclude India (Radcliffe Line)
    if (lat > 30.0 && lat < 33.5 && lon > 75.5) return false;
    if (lat >= 25.0 && lat <= 30.0 && lon > 73.5) return false;
    if (lat < 25.0 && lon > 71.5) return false;

    return true;
  }

  Future<void> loadFloodRisk() async {
    // Re-derive from current heatmap; reload heatmap first if empty.
    if (heatmapPoints.isEmpty) {
      await loadFloodHeatmap();
    } else {
      _updateFloodRiskFromHeatmap();
    }
  }

  Future<void> loadFloodForecast(DateTime date) async {
    selectedDate.value = date;
    isLoadingForecast.value = true;
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      floodForecast.value = await _service.getFloodForecast(
        dateStr,
        latitude: _lat,
        longitude: _lng,
      );
    } catch (e) {
      Get.log('MlAlertController: forecast error — $e');
    } finally {
      isLoadingForecast.value = false;
    }
  }

  Future<void> loadFloodHeatmap() async {
    isLoadingHeatmap.value = true;
    try {
      heatmapPoints.value = await _service.getFloodHeatmap();
    } catch (e) {
      Get.log('MlAlertController: heatmap error — $e');
      heatmapPoints.value = [];
    } finally {
      isLoadingHeatmap.value = false;
    }
  }

  Future<void> loadHistoricalFloods() async {
    isLoadingHistory.value = true;
    try {
      historicalFloods.value = await _service.getHistoricalFloods();
      // Default to the most recent year
      if (historicalFloods.isNotEmpty) {
        final mostRecent = historicalFloods
            .map((e) => e.year)
            .fold<int>(0, (best, y) => y > best ? y : best);
        selectedHistoricalYear.value = mostRecent;
        loadHistoricalModelHeatmap(mostRecent);
      }
    } catch (e) {
      Get.log('MlAlertController: historical floods error — $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void selectHistoricalYear(int year) {
    selectedHistoricalYear.value = year;
    loadHistoricalModelHeatmap(year);
  }

  Future<void> loadHistoricalModelHeatmap(int year) async {
    isLoadingHistoricalModel.value = true;
    try {
      historicalModelPoints.value =
          await _service.getHistoricalModelHeatmap(year);
    } catch (e) {
      Get.log('MlAlertController: historical model heatmap error — $e');
      historicalModelPoints.value = [];
    } finally {
      isLoadingHistoricalModel.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await Future.wait([
      loadEarthquakeAlerts(),
      loadFloodHeatmap(),
      loadFloodForecast(selectedDate.value),
    ]);
  }
}
