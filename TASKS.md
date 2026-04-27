# SafeLink — Backend Integration Task Tracker

Session goal: Connect the FastAPI ML backend to the Flutter app and surface earthquake/flood data in the UI.

## Status Legend
- ✅ Done
- 🔄 In progress
- ⬜ Pending

---

## Tasks

| # | Status | Task | File(s) |
|---|--------|------|---------|
| 1 | ✅ | Create ML alert data models | `lib/features/dashboard/models/ml_alert_models.dart` |
| 2 | ✅ | Create ML alert HTTP service | `lib/features/dashboard/services/ml_alert_service.dart` |
| 3 | ✅ | Create ML alert GetX controller | `lib/features/dashboard/controllers/ml_alert_controller.dart` |
| 4 | ✅ | Register ML service + controller in InitialBindings | `lib/core/services/initial_bindings.dart` |
| 5 | ✅ | Update AlertsListView with ML earthquake + flood tabs | `lib/features/dashboard/presentation/screens/alerts_list_view.dart` |
| 6 | ✅ | Create earthquake alert detail screen | `lib/features/dashboard/presentation/screens/earthquake_alert_detail_view.dart` |
| 7 | ✅ | Implement flood heatmap map view | `lib/features/dashboard/presentation/screens/map_view.dart` |
| 8 | ✅ | Add backend URL to AppSecrets | `lib/core/secrets/app_secrets.dart` |
| 9 | ✅ | Add earthquake detail route to AppRoutes | `lib/core/utilities/app_routes.dart` |
| 10 | ✅ | Switch AlertController from Supabase to ML models | `lib/features/dashboard/controllers/alert_controller.dart` |

---

## Architecture Summary

### New Data Flow
```
Flutter App
  └─ MlAlertController
       ├─ MlAlertService  →  FastAPI backend (http://10.0.2.2:8000 / localhost:8000)
       │    ├─ POST /earthquake/check  →  List<EarthquakeAlertModel>
       │    ├─ POST /flood/check       →  FloodAlertModel
       │    ├─ GET  /flood/forecast    →  FloodAlertModel (date-specific)
       │    └─ GET  /flood/heatmap     →  List<FloodHeatmapPoint>
       └─ Observables consumed by:
            ├─ AlertsListView  (Earthquakes tab + Floods tab)
            └─ MapView         (heatmap circles + forecast panel)
```

### Key Backend URL
- Android emulator → `http://10.0.2.2:8000`
- iOS Simulator → `http://localhost:8000`
- Physical device → set machine LAN IP in `AppSecrets.mlApiBaseUrl`

---

## What Each Screen Shows

### AlertsListView (3 tabs)
- **Database tab**: existing Supabase alerts (unchanged)
- **Earthquakes tab**: ML earthquake alerts — expandable cards showing:
  - Mainshock location, magnitude badge, distance from user
  - Expandable aftershock list: rank, magnitude, depth, likelihood %
  - Tap to open EarthquakeAlertDetailView
- **Floods tab**: current flood risk card with:
  - Risk level badge (LOW/MODERATE/HIGH/CRITICAL)
  - Risk score % + progress bar
  - Rainfall mm, affected areas

### EarthquakeAlertDetailView
- Gradient header (red if `should_alert`, orange otherwise)
- Mainshock info card: location, magnitude, depth, distance
- Aftershock table: rank | magnitude | depth | likelihood %
- Safety advice footer

### MapView
- Movable GoogleMap centred on Pakistan (lat 30.38, lng 69.35, zoom 5.2)
- 28 km radius Circles coloured by risk: green=LOW, orange=MODERATE, red=HIGH, dark red=CRITICAL
- Dark map style when app is in dark mode
- Backdrop-blurred top bar with back button + title
- Bottom panel (backdrop blur):
  - Colour legend
  - Date picker button → calls `/flood/forecast?date=YYYY-MM-DD`
  - Forecast result: risk level badge, progress bar, rainfall, affected areas

---

## If Resuming This Session

All tasks above are complete. Potential follow-up work:

### Task 10 Implementation Details
**AlertController** now fetches real-time earthquake and flood alerts from ML models instead of Supabase database:
- **Changes made:**
  - Modified `loadAlerts()` and `loadAllAlerts()` to call `_constructAlertsFromMlData()` instead of database service
  - Added `_constructAlertsFromMlData()` method that:
    - Iterates through `MlAlertController.earthquakeAlerts` list and creates AlertModel for each earthquake
    - Pulls single flood alert from `MlAlertController.floodAlert` and creates AlertModel
    - Maps ML magnitudes/risk scores to severity levels (critical/high/medium/low)
  - Modified `loadAlertsForLocation()` to use ML data only
  - Added helper methods:
    - `_mapMagnitudeToSeverity(double)` — converts earthquake magnitude to severity
    - `_mapFloodRiskToSeverity(double)` — converts flood risk score (0-100) to severity
- **Result:** Active Alerts section now displays real ML predictions instead of placeholder Supabase data

---

### Further follow-up work:

- [ ] Add earthquake markers to MapView (lat/lng from EarthquakeAlertModel)
- [ ] Wire "Your Area Status" banner on HomeView to live MlAlertController data
- [ ] Add pull-to-refresh on MapView heatmap
- [ ] Handle Android `INTERNET` permission in AndroidManifest if needed (already present for Supabase)
- [ ] Adjust `mlApiBaseUrl` for production deployment (replace localhost with real server URL)
