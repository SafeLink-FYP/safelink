import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/app_shell/controllers/navigation_controller.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';
import 'package:safelink/features/dashboard/presentation/screens/earthquake_alert_detail_view.dart';

enum _MapLayer { flood, earthquake }

enum _EarthquakeSort { time, magnitude, distance }

class _FloodLocation {
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  const _FloodLocation(this.name, this.province, this.latitude, this.longitude);
}

class _BreakdownEntry {
  final String label;
  final String subtitle;
  final double value; // 0–100
  const _BreakdownEntry(this.label, this.subtitle, this.value);
}

// Pakistani cities offered as flood-forecast targets. Coordinates +
// provinces mirror the backend's pakistan_geo.py / flood_service.py
// lookup tables so the forecast picks up the right per-city anchor
// weights and per-province alert thresholds.
const List<_FloodLocation> _pakistanCities = [
  // Punjab
  _FloodLocation('Attock', 'Punjab', 33.77, 72.36),
  _FloodLocation('Bahawalpur', 'Punjab', 29.39, 71.68),
  _FloodLocation('Dera Ghazi Khan', 'Punjab', 30.06, 70.63),
  _FloodLocation('Faisalabad', 'Punjab', 31.42, 73.08),
  _FloodLocation('Gujranwala', 'Punjab', 32.16, 74.19),
  _FloodLocation('Jhelum', 'Punjab', 32.94, 73.73),
  _FloodLocation('Kasur', 'Punjab', 31.12, 74.45),
  _FloodLocation('Khanewal', 'Punjab', 30.30, 71.93),
  _FloodLocation('Lahore', 'Punjab', 31.55, 74.35),
  _FloodLocation('Lodhran', 'Punjab', 29.55, 71.62),
  _FloodLocation('Mianwali', 'Punjab', 32.58, 71.53),
  _FloodLocation('Multan', 'Punjab', 30.19, 71.47),
  _FloodLocation('Muzaffargarh', 'Punjab', 30.07, 71.19),
  _FloodLocation('Rajanpur', 'Punjab', 29.10, 70.33),
  _FloodLocation('Rawalpindi', 'Punjab', 33.60, 73.04),
  _FloodLocation('Sargodha', 'Punjab', 32.08, 72.67),
  _FloodLocation('Sialkot', 'Punjab', 32.49, 74.53),
  _FloodLocation('Vehari', 'Punjab', 30.04, 72.34),

  // Sindh
  _FloodLocation('Badin', 'Sindh', 24.65, 68.84),
  _FloodLocation('Dadu', 'Sindh', 26.73, 67.78),
  _FloodLocation('Hyderabad', 'Sindh', 25.39, 68.37),
  _FloodLocation('Jacobabad', 'Sindh', 28.28, 68.44),
  _FloodLocation('Karachi', 'Sindh', 24.86, 67.01),
  _FloodLocation('Larkana', 'Sindh', 27.56, 68.22),
  _FloodLocation('Mirpurkhas', 'Sindh', 25.53, 69.01),
  _FloodLocation('Nawabshah', 'Sindh', 26.24, 68.41),
  _FloodLocation('Sehwan', 'Sindh', 26.43, 67.87),
  _FloodLocation('Sukkur', 'Sindh', 27.71, 68.86),
  _FloodLocation('Thatta', 'Sindh', 24.75, 67.92),

  // KPK
  _FloodLocation('Abbottabad', 'KPK', 34.15, 73.22),
  _FloodLocation('Bannu', 'KPK', 32.99, 70.61),
  _FloodLocation('Charsadda', 'KPK', 34.15, 71.73),
  _FloodLocation('Chitral', 'KPK', 35.85, 71.83),
  _FloodLocation('Dir', 'KPK', 35.21, 71.88),
  _FloodLocation('Kohat', 'KPK', 33.58, 71.44),
  _FloodLocation('Mansehra', 'KPK', 34.33, 73.20),
  _FloodLocation('Mardan', 'KPK', 34.20, 72.04),
  _FloodLocation('Mingora', 'KPK', 34.78, 72.36),
  _FloodLocation('Nowshera', 'KPK', 34.01, 71.98),
  _FloodLocation('Peshawar', 'KPK', 34.01, 71.57),
  _FloodLocation('Swabi', 'KPK', 34.12, 72.47),
  _FloodLocation('Swat', 'KPK', 35.22, 72.42),

  // Balochistan
  _FloodLocation('Gwadar', 'Balochistan', 25.12, 62.33),
  _FloodLocation('Jafferabad', 'Balochistan', 28.34, 68.28),
  _FloodLocation('Kalat', 'Balochistan', 29.00, 66.57),
  _FloodLocation('Khuzdar', 'Balochistan', 27.82, 66.61),
  _FloodLocation('Naseerabad', 'Balochistan', 28.42, 67.92),
  _FloodLocation('Quetta', 'Balochistan', 30.18, 67.00),
  _FloodLocation('Turbat', 'Balochistan', 26.00, 63.05),
  _FloodLocation('Zhob', 'Balochistan', 31.34, 69.45),

  // Gilgit-Baltistan
  _FloodLocation('Gilgit', 'Gilgit-Baltistan', 35.92, 74.31),
  _FloodLocation('Hunza', 'Gilgit-Baltistan', 36.32, 74.65),
  _FloodLocation('Skardu', 'Gilgit-Baltistan', 35.29, 75.63),

  // ICT
  _FloodLocation('Islamabad', 'ICT', 33.72, 73.06),

  // AJK
  _FloodLocation('Mirpur', 'AJK', 33.14, 73.75),
  _FloodLocation('Muzaffarabad', 'AJK', 34.37, 73.47),
  _FloodLocation('Neelum', 'AJK', 34.59, 73.91),
];

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MlAlertController _ml = Get.find<MlAlertController>();
  GoogleMapController? _mapController;
  _MapLayer _layer = _MapLayer.flood;
  bool _showHistorical = false;
  bool _breakdownExpanded = false;
  _EarthquakeSort _earthquakeSort = _EarthquakeSort.time;
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
    if (_ml.earthquakeAlerts.isEmpty) _ml.loadEarthquakeAlerts();
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

  // ─── Earthquake marker builder ────────────────────────────────────────────

  Set<Marker> _buildEarthquakeMarkers(List<EarthquakeAlertModel> alerts) {
    final markers = <Marker>{};
    for (final eq in alerts) {
      final aftershockCount = eq.predictedAftershocks.length;
      markers.add(Marker(
        markerId: MarkerId('eq_main_${eq.eventId}'),
        position: LatLng(eq.mainshockLatitude, eq.mainshockLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: '${eq.magnitudeLabel} mainshock — ${eq.severity}',
          snippet:
              '${eq.mainshockLocation} · $aftershockCount aftershock(s) — tap for details',
          onTap: () => _openEarthquakeDetail(eq),
        ),
      ));
    }
    return markers;
  }

  Set<Circle> _buildAftershockCircles(List<EarthquakeAlertModel> alerts) {
    // Each aftershock is rendered as a translucent disc whose radius is the
    // empirical felt-shaking radius reported by the backend (MMI ~III). The
    // colour deepens with magnitude so larger expected aftershocks read as
    // higher-impact zones at a glance.
    final circles = <Circle>{};
    for (final eq in alerts) {
      for (final a in eq.predictedAftershocks) {
        final color = _aftershockColor(a.magnitude);
        circles.add(Circle(
          circleId: CircleId('eq_after_${eq.eventId}_${a.rank}'),
          center: LatLng(a.latitude, a.longitude),
          radius: a.affectedRadiusKm * 1000, // km → metres
          fillColor: color.withValues(alpha: 0.22),
          strokeColor: color,
          strokeWidth: 2,
        ));
      }
    }
    return circles;
  }

  Color _aftershockColor(double magnitude) {
    if (magnitude >= 6.0) return const Color(0xFF8B0000); // dark red
    if (magnitude >= 5.0) return const Color(0xFFEF4444); // red
    if (magnitude >= 4.0) return const Color(0xFFF97316); // orange
    if (magnitude >= 3.0) return const Color(0xFFEAB308); // amber
    return const Color(0xFFFACC15);                       // yellow
  }

  void _openEarthquakeDetail(EarthquakeAlertModel alert) {
    Get.to(() => const EarthquakeAlertDetailView(), arguments: alert);
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

  // ─── Fallback-location banner ─────────────────────────────────────────────

  Widget _buildFallbackLocationBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.lightOrange.withValues(alpha: 0.92),
              border: Border.all(
                color: AppTheme.orange.withValues(alpha: 0.40),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off,
                  color: AppTheme.orange,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Showing default region — your location is unavailable.',
                    style: TextStyle(
                      color: AppTheme.orange,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            final isFlood = _layer == _MapLayer.flood;
            final circles = isFlood
                ? (_showHistorical
                    ? _buildHeatmap(_ml.historicalModelPoints)
                    : _buildHeatmap(_ml.heatmapPoints))
                : _buildAftershockCircles(_ml.earthquakeAlerts);
            final markers = isFlood
                ? <Marker>{}
                : _buildEarthquakeMarkers(_ml.earthquakeAlerts);

            return GoogleMap(
              initialCameraPosition: _pakistan,
              circles: circles,
              markers: markers,
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

          // ── Overlays (top bar + map controls + bottom panel) ─────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(theme),
                // Non-dismissable banner shown when Geolocator never
                // returned a real fix; the map is centred on Pakistan
                // and ML queries are country-wide rather than user-local.
                Obx(() {
                  if (_ml.hasUserLocation.value) {
                    return const SizedBox.shrink();
                  }
                  return _buildFallbackLocationBanner();
                }),
                const Spacer(),
                // Right-aligned map controls (zoom slider + locate),
                // anchored just above the bottom panel so they never
                // overlap with the panel content or each other.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildMapControls(theme),
                  ),
                ),
                SizedBox(height: 10.h),
                if (_layer == _MapLayer.earthquake)
                  _buildEarthquakePanel(theme)
                else if (_showHistorical)
                  _buildHistoricalPanel(theme)
                else
                  _buildLivePanel(theme),
              ],
            ),
          ),

          // ── Loading spinner ───────────────────────────────────────────
          Obx(() {
            final loading = _layer == _MapLayer.earthquake
                ? _ml.isLoadingEarthquakes.value
                : (_showHistorical
                    ? (_ml.isLoadingHistory.value ||
                        _ml.isLoadingHistoricalModel.value)
                    : _ml.isLoadingHeatmap.value);
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
                            _layer == _MapLayer.earthquake
                                ? 'Loading earthquakes…'
                                : (_showHistorical
                                    ? 'Loading history…'
                                    : 'Fetching data…'),
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

        ],
      ),
    );
  }

  // ─── Map controls (zoom slider + locate) ──────────────────────────────────

  Widget _buildMapControls(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildZoomSlider(theme),
        SizedBox(height: 8.h),
        _buildLocateFab(theme),
      ],
    );
  }

  Widget _buildZoomSlider(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40.w,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          color: theme.cardColor.withValues(alpha: 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add,
                  size: 16.sp, color: theme.textTheme.bodyLarge?.color),
              SizedBox(height: 2.h),
              RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  width: 90.h,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 6.r),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 11.r),
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor:
                          AppTheme.primaryColor.withValues(alpha: 0.25),
                      thumbColor: AppTheme.primaryColor,
                      overlayColor:
                          AppTheme.primaryColor.withValues(alpha: 0.15),
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
              SizedBox(height: 2.h),
              Icon(Icons.remove,
                  size: 16.sp, color: theme.textTheme.bodyLarge?.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocateFab(ThemeData theme) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: FloatingActionButton.small(
        backgroundColor: theme.cardColor,
        elevation: 4,
        onPressed: () {
          setState(() => _zoomLevel = 5.2);
          _mapController
              ?.animateCamera(CameraUpdate.newCameraPosition(_pakistan));
        },
        child: Icon(Icons.my_location,
            color: AppTheme.primaryColor, size: 18.sp),
      ),
    );
  }

  // ─── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(ThemeData theme) {
    final isFlood = _layer == _MapLayer.flood;
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
                  onPressed: _handleBack,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Center(child: _buildLayerToggle(theme))),
          SizedBox(width: 8.w),
          if (isFlood)
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showHistorical = !_showHistorical),
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

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Get.back();
      return;
    }
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changePage(0);
    }
  }

  Widget _buildLayerToggle(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _layerSegment(theme, _MapLayer.flood,
                  AppAssets.dropletsIcon, 'Flood'),
              _layerSegment(theme, _MapLayer.earthquake, null, 'Earthquake'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _layerSegment(
      ThemeData theme, _MapLayer mode, String? svgAsset, String label) {
    final active = _layer == mode;
    final fg = active ? AppTheme.white : theme.textTheme.bodyLarge?.color;
    return GestureDetector(
      onTap: () {
        if (_layer == mode) return;
        setState(() => _layer = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset,
                width: 14.w,
                height: 14.h,
                colorFilter: ColorFilter.mode(
                    fg ?? AppTheme.primaryColor, BlendMode.srcIn),
              )
            else
              Icon(Icons.public, size: 14.sp, color: fg),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Live (current heatmap) panel — compact 3-row layout ─────────────────

  Widget _buildLivePanel(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
          color: theme.cardColor.withValues(alpha: 0.92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildHorizonToggle(theme),
                  const Spacer(),
                  _buildLocationPill(theme),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(() {
                if (_ml.isLoadingForecast.value) {
                  return _compactStatusRow(
                      theme, 'Loading next-24h forecast…', spinner: true);
                }
                final f = _ml.floodForecast.value;
                if (f == null) {
                  return _compactStatusRow(
                      theme, 'Loading next-24h forecast…');
                }
                return _compactForecastCard(f, theme);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Location pill + selection sheet ──────────────────────────────────────

  Widget _buildLocationPill(ThemeData theme) {
    return Obx(() {
      final label = _ml.floodLocationLabel.value ?? 'My location';
      final isCity = _ml.floodLocationLabel.value != null;
      return GestureDetector(
        onTap: _openLocationSheet,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCity ? Icons.place : Icons.my_location,
                    size: 13.sp,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 5.w),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 110.w),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.expand_more,
                      size: 14.sp, color: theme.textTheme.bodyLarge?.color),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _openLocationSheet() async {
    final currentLabel = _ml.floodLocationLabel.value;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationSheet(
        currentLabel: currentLabel,
        onSelect: _selectLocation,
      ),
    );
  }

  void _selectLocation(_FloodLocation? loc) {
    Navigator.of(context).pop();
    if (loc == null) {
      _ml.setFloodLocationOverride();
      _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(_pakistan));
    } else {
      _ml.setFloodLocationOverride(
        label: loc.name,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(loc.latitude, loc.longitude), zoom: 8),
        ),
      );
    }
  }

  Widget _compactForecastCard(FloodAlertModel f, ThemeData theme) {
    final color = _riskColor(f.riskLevel);
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8.w),
              Text(
                '${f.riskLevel} Risk',
                style: TextStyle(
                  color: color,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${f.rainfallMm.toStringAsFixed(1)} mm',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                '${f.riskPercent}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: LinearProgressIndicator(
              value: (f.riskScore / 100).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6.h,
            ),
          ),
          if (f.affectedAreas.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              f.affectedAreas.take(3).join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (f.signals.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildBreakdownToggle(f, theme, color),
            if (_breakdownExpanded) ...[
              SizedBox(height: 8.h),
              _buildBreakdown(f, theme, color),
            ],
          ],
        ],
      ),
    );
  }

  // ─── Risk-score breakdown ─────────────────────────────────────────────────

  Widget _buildBreakdownToggle(
      FloodAlertModel f, ThemeData theme, Color color) {
    return GestureDetector(
      onTap: () =>
          setState(() => _breakdownExpanded = !_breakdownExpanded),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            _breakdownExpanded ? Icons.expand_less : Icons.expand_more,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            _breakdownExpanded ? 'Hide breakdown' : 'Why this score?',
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!_breakdownExpanded && f.zone.isNotEmpty) ...[
            SizedBox(width: 6.w),
            Text(
              '· ${f.zone}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontSize: 10.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdown(FloodAlertModel f, ThemeData theme, Color color) {
    // The four primary signals that compose the base risk score in the
    // backend's flood model. Each value is the signal's saturation level
    // 0–100 (1 - exp(-rainfall/threshold) × 100), so it answers "how
    // strongly is this factor firing?".
    final entries = <_BreakdownEntry>[
      _BreakdownEntry(
        'Intensity',
        '1-day burst',
        f.signals['intensity'] ?? 0,
      ),
      _BreakdownEntry(
        'Cumulative',
        '3-day rainfall',
        f.signals['cumulative'] ?? 0,
      ),
      _BreakdownEntry(
        'Riverine',
        'Upstream catchment',
        f.signals['riverine'] ?? 0,
      ),
      _BreakdownEntry(
        'Saturation',
        '14-day ground wetness',
        f.signals['saturation'] ?? 0,
      ),
    ];

    String anomalyNote;
    final a = f.anomalyFactor;
    if (a > 1.20) {
      anomalyNote = 'rainfall is well above seasonal normal';
    } else if (a > 1.05) {
      anomalyNote = 'slightly above seasonal normal';
    } else if (a < 0.90) {
      anomalyNote = 'below seasonal normal';
    } else {
      anomalyNote = 'near seasonal normal';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.map((e) => _buildBreakdownRow(e, color, theme)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (f.zone.isNotEmpty)
                _breakdownLine(
                    theme, 'Zone', f.zone, 'flood-mechanism regime'),
              _breakdownLine(
                theme,
                'Climatology',
                '${a.toStringAsFixed(2)}×',
                anomalyNote,
              ),
              _breakdownLine(
                theme,
                'Score',
                '${f.riskPercent}%',
                'weighted signals × climatology + zone baseline',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
      _BreakdownEntry e, Color color, ThemeData theme) {
    final pct = e.value.clamp(0.0, 100.0);
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        children: [
          SizedBox(
            width: 78.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  e.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 38.w,
            child: Text(
              '${pct.round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownLine(
      ThemeData theme, String label, String value, String note) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78.w,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '  $note'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactStatusRow(ThemeData theme, String text, {bool spinner = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          if (spinner) ...[
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Earthquake panel ─────────────────────────────────────────────────────

  Widget _buildEarthquakePanel(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
          color: theme.cardColor.withValues(alpha: 0.92),
          child: Obx(() {
            if (_ml.isLoadingEarthquakes.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            final alerts = _ml.earthquakeAlerts;
            if (alerts.isEmpty) {
              return Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: const Color(0xFF22C55E), size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'No earthquakes in the past 7 days.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  GestureDetector(
                    onTap: _ml.loadEarthquakeAlerts,
                    child: Icon(Icons.refresh,
                        color: AppTheme.primaryColor, size: 18.sp),
                  ),
                ],
              );
            }
            final totalAfter = alerts.fold<int>(
                0, (s, e) => s + e.predictedAftershocks.length);
            final sorted = _sortedEarthquakes(alerts);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Earthquakes · last 7 days',
                            style: theme.textTheme.headlineMedium,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '${alerts.length} events  ·  $totalAfter predicted aftershocks',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: _ml.loadEarthquakeAlerts,
                      child: Icon(Icons.refresh,
                          color: AppTheme.primaryColor, size: 18.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _buildEarthquakeSortToggle(theme),
                SizedBox(height: 8.h),
                Divider(height: 1.h, color: theme.dividerColor),
                SizedBox(height: 4.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => SizedBox(height: 4.h),
                    itemBuilder: (_, i) =>
                        _buildEarthquakeRow(sorted[i], theme),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ─── Earthquake row + sort toggle + helpers ───────────────────────────────

  List<EarthquakeAlertModel> _sortedEarthquakes(
      List<EarthquakeAlertModel> alerts) {
    final sorted = [...alerts];
    switch (_earthquakeSort) {
      case _EarthquakeSort.time:
        sorted.sort((a, b) {
          final ta = DateTime.tryParse(a.mainshockTimestamp);
          final tb = DateTime.tryParse(b.mainshockTimestamp);
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta); // newest first
        });
      case _EarthquakeSort.magnitude:
        sorted.sort(
            (a, b) => b.mainshockMagnitude.compareTo(a.mainshockMagnitude));
      case _EarthquakeSort.distance:
        sorted.sort(
            (a, b) => a.distanceToUserKm.compareTo(b.distanceToUserKm));
    }
    return sorted;
  }

  Widget _buildEarthquakeSortToggle(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Sort by',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: _earthquakeSortSegment(
                          theme, _EarthquakeSort.time, Icons.schedule, 'Time'),
                    ),
                    Expanded(
                      child: _earthquakeSortSegment(theme,
                          _EarthquakeSort.magnitude, Icons.bar_chart, 'Mag'),
                    ),
                    Expanded(
                      child: _earthquakeSortSegment(theme,
                          _EarthquakeSort.distance, Icons.near_me, 'Near'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _earthquakeSortSegment(
      ThemeData theme, _EarthquakeSort mode, IconData icon, String label) {
    final active = _earthquakeSort == mode;
    final fg = active ? AppTheme.white : theme.textTheme.bodyLarge?.color;
    return GestureDetector(
      onTap: () => setState(() => _earthquakeSort = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 11.sp, color: fg),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarthquakeRow(EarthquakeAlertModel eq, ThemeData theme) {
    final color = _earthquakeSeverityColor(eq.mainshockMagnitude);
    final aftershockCount = eq.predictedAftershocks.length;
    final timeAgo = _timeAgo(eq.mainshockTimestamp);
    return InkWell(
      onTap: () => _openEarthquakeDetail(eq),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 50.w,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: color.withValues(alpha: 0.40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    eq.magnitudeLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    eq.severity.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    eq.mainshockLocation,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _eqRowTag(
                          theme,
                          Icons.near_me,
                          '${eq.distanceToUserKm.toStringAsFixed(0)} km'),
                      SizedBox(width: 6.w),
                      _eqRowTag(theme, Icons.bolt, '$aftershockCount aft.'),
                      if (timeAgo.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        _eqRowTag(theme, Icons.schedule, timeAgo),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right,
                size: 16.sp, color: theme.textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }

  Widget _eqRowTag(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: theme.textTheme.bodySmall?.color),
        SizedBox(width: 2.w),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Color _earthquakeSeverityColor(double mag) {
    if (mag >= 7.0) return const Color(0xFF8B0000);
    if (mag >= 5.5) return const Color(0xFFEF4444);
    if (mag >= 4.0) return const Color(0xFFF97316);
    if (mag >= 3.0) return const Color(0xFFEAB308);
    return const Color(0xFFFACC15);
  }

  String _timeAgo(String iso) {
    if (iso.isEmpty) return '';
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final diff = DateTime.now().toUtc().difference(t.toUtc());
    if (diff.isNegative) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final days = diff.inDays;
    final hours = diff.inHours - days * 24;
    if (hours == 0) return '${days}d ago';
    return '${days}d ${hours}h ago';
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


  // ─── Horizon toggle (Today / Tomorrow) ────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildHorizonToggle(ThemeData theme) {
    return Obx(() {
      final selected = _ml.selectedDate.value;
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      // If selectedDate has drifted to a non-24h value (e.g. via an older
      // session), default the highlight to Today so the UI stays coherent.
      var isToday = _isSameDay(selected, today);
      final isTomorrow = _isSameDay(selected, tomorrow);
      if (!isToday && !isTomorrow) isToday = true;

      return ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _horizonSegment(theme, 'Today', isToday, 0),
                _horizonSegment(theme, 'Tomorrow', isTomorrow, 1),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _horizonSegment(
      ThemeData theme, String label, bool active, int dayOffset) {
    final fg = active ? AppTheme.white : theme.textTheme.bodyLarge?.color;
    return GestureDetector(
      onTap: () {
        if (active) return;
        final base = DateTime.now();
        _ml.loadFloodForecast(base.add(Duration(days: dayOffset)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
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

// ─── Location bottom sheet (search + grouped list) ─────────────────────────

class _LocationSheet extends StatefulWidget {
  final String? currentLabel;
  final void Function(_FloodLocation?) onSelect;

  const _LocationSheet({
    required this.currentLabel,
    required this.onSelect,
  });

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_FloodLocation> get _filtered {
    if (_query.isEmpty) return _pakistanCities;
    final q = _query.toLowerCase();
    return _pakistanCities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.province.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    final myLocActive = widget.currentLabel == null;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: theme.cardColor.withValues(alpha: 0.96),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          constraints: BoxConstraints(maxHeight: 560.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Forecast location',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Pick anywhere in Pakistan to see its 24-hour flood forecast.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                ),
              ),
              SizedBox(height: 10.h),
              // Search bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        size: 18.sp,
                        color: theme.textTheme.bodySmall?.color),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search city or province',
                          hintStyle: theme.textTheme.bodySmall
                              ?.copyWith(fontSize: 12.sp),
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.close,
                            size: 16.sp,
                            color: theme.textTheme.bodySmall?.color),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            'No cities match "$_query"',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length + 2,
                        itemBuilder: (ctx, i) {
                          // Slot 0: My location · Slot 1: divider · Slot 2+: cities
                          if (i == 0) {
                            return _LocationTile(
                              label: 'My location',
                              subtitle: 'Use your GPS position',
                              active: myLocActive,
                              icon: Icons.my_location,
                              onTap: () => widget.onSelect(null),
                            );
                          }
                          if (i == 1) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Divider(
                                  height: 1.h, color: theme.dividerColor),
                            );
                          }
                          final c = filtered[i - 2];
                          return _LocationTile(
                            label: c.name,
                            subtitle: c.province,
                            active: widget.currentLabel == c.name,
                            onTap: () => widget.onSelect(c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool active;
  final IconData? icon;
  final VoidCallback onTap;

  const _LocationTile({
    required this.label,
    required this.subtitle,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        active ? AppTheme.primaryColor : theme.textTheme.bodyLarge?.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.place_outlined,
              size: 16.sp,
              color: active
                  ? AppTheme.primaryColor
                  : theme.textTheme.bodySmall?.color,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.sp,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            if (active)
              Icon(Icons.check_circle,
                  size: 16.sp, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
