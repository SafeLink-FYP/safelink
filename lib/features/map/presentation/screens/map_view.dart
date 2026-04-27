import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MlAlertController _ml = Get.find<MlAlertController>();
  GoogleMapController? _mapController;
  bool _showHistorical = false;
  double _zoomLevel = 5.2;

  static const _pakistan = CameraPosition(
    target: LatLng(30.3753, 69.3451),
    zoom: 5.2,
  );

  @override
  void initState() {
    super.initState();
    if (_ml.heatmapPoints.isEmpty) _ml.loadFloodHeatmap();
    if (_ml.floodForecast.value == null) _ml.loadFloodForecast(DateTime.now());
    if (_ml.historicalFloods.isEmpty) _ml.loadHistoricalFloods();
  }

  // Polygon filter approximating the Durand Line (west) and Radcliffe Line (east).
  // Tighter than a plain bounding box so Afghanistan/India overlap zones in the
  // backend grid are excluded even when they carry HIGH/CRITICAL scores in flood years.
  static bool _inPakistan(double lat, double lon) {
    if (lat < 23.5 || lat > 37.2 || lon < 61.5 || lon > 77.2) return false;

    // Exclude Afghanistan (Durand Line, west/northwest boundary)
    if (lat > 35.5 && lon < 71.5) return false; // Nuristan / Chitral border
    if (lat > 33.5 && lon < 71.0) return false; // Khyber / Kurram border
    if (lat > 31.0 && lon < 67.0) return false; // Waziristan / Balochistan border
    if (lat > 29.0 && lon < 64.5) return false; // Balochistan / Kandahar border
    if (lat > 27.0 && lon < 63.0) return false; // Balochistan / Helmand border

    // Exclude India (Radcliffe Line, east boundary)
    if (lat > 30.0 && lat < 33.5 && lon > 75.5) return false; // Punjab India
    if (lat >= 25.0 && lat <= 30.0 && lon > 73.5) return false; // Rajasthan
    if (lat < 25.0 && lon > 71.5) return false; // Gujarat border

    return true;
  }

  // ─── Circle builder ───────────────────────────────────────────────────────

  Set<Circle> _buildHeatmap(List<FloodHeatmapPoint> points) {
    final circles = <Circle>{};
    for (final p in points) {
      if (!_inPakistan(p.lat, p.lon)) continue;

      final level = p.riskLevel.toUpperCase();
      if (level != 'CRITICAL' && level != 'HIGH') continue;

      final color = _riskLevelColor(level);

      circles.add(Circle(
        circleId: CircleId('hm_${p.lat}_${p.lon}'),
        center: LatLng(p.lat, p.lon),
        radius: 50000,
        fillColor: color.withValues(alpha: 0.30),
        strokeColor: color,
        strokeWidth: 2,
      ));
    }
    return circles;
  }

  Color _riskLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFEF4444);
      case 'HIGH':
        return const Color(0xFFF97316);
      case 'MODERATE':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF22C55E);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────
          Obx(() {
            final circles = _showHistorical
                ? _buildHeatmap(_ml.historicalModelPoints)
                : _buildHeatmap(_ml.heatmapPoints);

            return GoogleMap(
              initialCameraPosition: _pakistan,
              circles: circles,
              style: isDark ? _darkMapStyle : null,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(23.0, 60.0),
                  northeast: const LatLng(38.5, 78.5),
                ),
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(5.0, 20.0),
              onMapCreated: (c) => _mapController = c,
            );
          }),

          // ── Overlays (top bar + bottom panel) ────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(theme),
                const Spacer(),
                _showHistorical
                    ? _buildHistoricalPanel(theme)
                    : _buildLivePanel(theme),
              ],
            ),
          ),

          // ── Loading spinner ───────────────────────────────────────────
          Obx(() {
            final loading = _showHistorical
                ? (_ml.isLoadingHistory.value ||
                    _ml.isLoadingHistoricalModel.value)
                : _ml.isLoadingHeatmap.value;
            if (!loading) return const SizedBox.shrink();
            return Positioned(
              top: 100.h,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            _showHistorical
                                ? 'Loading history…'
                                : 'Loading heatmap…',
                            style: TextStyle(
                                color: AppTheme.white, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // ── Zoom slider ───────────────────────────────────────────────
          Positioned(
            right: 12.w,
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 44.w,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      color: theme.cardColor.withValues(alpha: 0.85),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              size: 18.sp,
                              color: theme.textTheme.bodyLarge?.color),
                          SizedBox(height: 4.h),
                          RotatedBox(
                            quarterTurns: 3,
                            child: SizedBox(
                              width: 120.h,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 7.r),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 12.r),
                                  activeTrackColor: AppTheme.primaryColor,
                                  inactiveTrackColor: AppTheme.primaryColor
                                      .withValues(alpha: 0.25),
                                  thumbColor: AppTheme.primaryColor,
                                  overlayColor: AppTheme.primaryColor
                                      .withValues(alpha: 0.15),
                                ),
                                child: Slider(
                                  value: _zoomLevel.clamp(5.0, 20.0),
                                  min: 5.0,
                                  max: 20.0,
                                  onChanged: (v) {
                                    setState(() => _zoomLevel = v);
                                    _mapController
                                        ?.animateCamera(CameraUpdate.zoomTo(v));
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Icon(Icons.remove,
                              size: 18.sp,
                              color: theme.textTheme.bodyLarge?.color),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Reset camera FAB ──────────────────────────────────────────
          Positioned(
            bottom: 240.h,
            right: 16.w,
            child: FloatingActionButton.small(
              backgroundColor: theme.cardColor,
              elevation: 4,
              onPressed: () {
                setState(() => _zoomLevel = 5.2);
                _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(_pakistan));
              },
              child: Icon(Icons.my_location,
                  color: AppTheme.primaryColor, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: theme.cardColor.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 20.sp),
                  color: theme.textTheme.bodyLarge?.color,
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  color: theme.cardColor.withValues(alpha: 0.85),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.dropletsIcon,
                        width: 16.w,
                        height: 16.h,
                        colorFilter: const ColorFilter.mode(
                            AppTheme.primaryColor, BlendMode.srcIn),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _showHistorical
                            ? 'Historical Flood Events'
                            : 'Pakistan Flood Heatmap',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GestureDetector(
                onTap: () => setState(() => _showHistorical = !_showHistorical),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: _showHistorical
                        ? AppTheme.primaryGradient
                        : AppTheme.purpleGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _showHistorical ? 'Live' : 'History',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Live (current heatmap) panel ─────────────────────────────────────────

  Widget _buildLivePanel(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          color: theme.cardColor.withValues(alpha: 0.92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeatmapLegend(theme),
              SizedBox(height: 14.h),
              Divider(height: 1.h, color: theme.dividerColor),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Text('Forecast Date',
                      style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  Obx(() {
                    final d = _ml.selectedDate.value;
                    return GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14.sp, color: AppTheme.white),
                            SizedBox(width: 6.w),
                            Text(
                              '${d.year}-'
                              '${d.month.toString().padLeft(2, '0')}-'
                              '${d.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 14.h),
              Obx(() {
                if (_ml.isLoadingForecast.value) {
                  return Center(
                    child: SizedBox(
                      height: 32.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final forecast = _ml.floodForecast.value;
                if (forecast == null) {
                  return Text(
                    'Select a date to see the flood forecast.',
                    style: theme.textTheme.bodySmall,
                  );
                }
                return _buildForecastResult(forecast, theme);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Historical panel ─────────────────────────────────────────────────────

  Widget _buildHistoricalPanel(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 16.h, 0, 20.h),
          color: theme.cardColor.withValues(alpha: 0.92),
          child: Obx(() {
            if (_ml.isLoadingHistory.value) {
              return Padding(
                padding: EdgeInsets.all(20.r),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (_ml.historicalFloods.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(20.r),
                child: Text('No historical data available.',
                    style: theme.textTheme.bodySmall),
              );
            }

            final events = _ml.historicalFloods;
            final selectedYear = _ml.selectedHistoricalYear.value;
            final selected =
                events.firstWhereOrNull((e) => e.year == selectedYear);
            final years = events.map((e) => e.year).toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: years.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      final y = years[i];
                      final active = y == selectedYear;
                      return GestureDetector(
                        onTap: () => _ml.selectHistoricalYear(y),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: active ? AppTheme.purpleGradient : null,
                            color: active
                                ? null
                                : theme.dividerColor.withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '$y',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? AppTheme.white
                                  : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (selected != null) ...[
                  SizedBox(height: 14.h),
                  Divider(height: 1.h, color: theme.dividerColor),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    child: _buildHistoricalEventCard(selected, theme),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHistoricalEventCard(
      HistoricalFloodEvent event, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(event.label,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                    color: const Color(0xFF6D28D9).withValues(alpha: 0.35)),
              ),
              child: Text(
                '${event.year}',
                style: TextStyle(
                  color: const Color(0xFF6D28D9),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(event.description, style: theme.textTheme.bodySmall),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 4.h,
          children: event.regions.map((r) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                r.district,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6D28D9),
                  fontSize: 11.sp,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Forecast result ──────────────────────────────────────────────────────

  Widget _buildForecastResult(FloodAlertModel forecast, ThemeData theme) {
    final color = _riskColor(forecast.riskLevel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Risk Level: ', style: theme.textTheme.bodySmall),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: color.withValues(alpha: 0.30)),
              ),
              child: Text(
                forecast.riskLevel,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: LinearProgressIndicator(
            value: (forecast.riskScore / 100).clamp(0.0, 1.0),
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7.h,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${forecast.riskPercent}% risk  ·  '
          '${forecast.rainfallMm.toStringAsFixed(1)} mm rainfall',
          style: theme.textTheme.bodySmall,
        ),
        if (forecast.affectedAreas.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            forecast.affectedAreas.take(2).join(', '),
            style: theme.textTheme.bodySmall?.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  // ─── Heatmap legend ───────────────────────────────────────────────────────

  Widget _buildHeatmapLegend(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('High', style: theme.textTheme.bodySmall),
            Text('Critical', style: theme.textTheme.bodySmall),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Container(
            height: 8.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEF4444)],
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Obx(() {
          final pts = _showHistorical
              ? _ml.historicalModelPoints
              : _ml.heatmapPoints;
          final pak = pts.where((p) => _inPakistan(p.lat, p.lon));
          final critical =
              pak.where((p) => p.riskLevel.toUpperCase() == 'CRITICAL').length;
          final high =
              pak.where((p) => p.riskLevel.toUpperCase() == 'HIGH').length;
          final moderate =
              pak.where((p) => p.riskLevel.toUpperCase() == 'MODERATE').length;
          if (critical == 0 && high == 0 && moderate == 0) {
            return Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 14.sp, color: const Color(0xFF22C55E)),
                SizedBox(width: 6.w),
                Text('No elevated risk zones in Pakistan',
                    style: theme.textTheme.bodySmall),
              ],
            );
          }
          return Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              if (critical > 0)
                _zoneBadge(critical, 'Critical', const Color(0xFFEF4444), theme),
              if (high > 0)
                _zoneBadge(high, 'High', const Color(0xFFF97316), theme),
              if (moderate > 0)
                _zoneBadge(moderate, 'Moderate', const Color(0xFFEAB308), theme),
            ],
          );
        }),
      ],
    );
  }

  Widget _zoneBadge(int count, String label, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        '$count $label',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ml.selectedDate.value,
      firstDate: DateTime(2014),
      lastDate: DateTime.now().add(const Duration(days: 16)),
      helpText: 'Select forecast date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: AppTheme.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _ml.loadFloodForecast(picked);
  }

  Color _riskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFF8B0000);
      case 'HIGH':
        return AppTheme.red;
      case 'MODERATE':
        return AppTheme.orange;
      default:
        return AppTheme.green;
    }
  }
}

// Dark map style JSON for dark theme
const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#9e9e9e"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#bdbdbd"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#181818"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [{"color": "#1b1b1b"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#373737"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
  {"featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [{"color": "#4e4e4e"}]},
  {"featureType": "road.local", "elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"featureType": "transit", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3d3d3d"}]}
]
''';
