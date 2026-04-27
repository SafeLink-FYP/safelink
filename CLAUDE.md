# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SafeLink is a Flutter-based disaster management and emergency response app for Pakistan. It connects citizens, aid workers, and government officials with real-time earthquake/flood alerts powered by a Python FastAPI ML backend.

## Commands

### Flutter (Mobile App)
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Static analysis
flutter build apk --release   # Android release build
flutter build ios --release   # iOS release build
flutter clean && flutter pub get  # Clean rebuild
```

There is no meaningful test suite — only the default `widget_test.dart` stub exists.

### Backend (FastAPI ML Service)
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000   # Dev server with hot reload
# API docs: http://localhost:8000/docs
# Dashboard UI: http://localhost:8000/ui
```

See `backend/CLAUDE.md` for backend-specific architecture and environment setup.

## Architecture

### Flutter App Structure

**Feature-based vertical slicing** under `lib/`:

```
lib/
├── core/              # Shared code: routes, themes, widgets, services
│   ├── constants/     # Asset paths, emergency constants
│   ├── services/      # SupabaseService (singleton), CacheService, InitialBindings
│   ├── themes/        # Light/dark theme, color palette, typography
│   └── utilities/     # AppRoutes (named routes), validators, dialog helpers
└── features/
    ├── authorization/ # Sign in/up/reset — Supabase Auth + Google OAuth
    ├── onboarding/    # Splash + onboarding screens
    ├── dashboard/     # 18 screens, controllers, services (core feature)
    ├── chatbot/       # AI assistant for emergency guidance
    └── profile/       # User profile management
```

Each feature follows `controllers/ → models/ → services/ → presentation/screens/ + widgets/`.

### State Management: GetX

All controllers extend `GetxController` with `Rx` observables. All services and controllers are registered as **permanent singletons** in `InitialBindings` (`lib/core/services/initial_bindings.dart`), which runs before the app renders.

```dart
// Observable pattern used throughout
final isLoading = false.obs;
final items = <MyModel>[].obs;
```

**Registration order matters** — `MlAlertController` must be registered before `AlertController` because `AlertController` calls `Get.find<MlAlertController>()` in its constructor.

**Reactive workers** — `AlertController` uses `ever()` to watch `MlAlertController` observables and rebuild its own list whenever ML data changes. Use this pattern (not one-shot reads in `onInit`) whenever data loads asynchronously after controller creation.

**Controllers NOT in InitialBindings** — `NavigationController`, `DisasterReportController`, `CaseTrackingController`, `PreparednessController`, and `SettingsController` are instantiated on demand by their respective screens via `Get.put()` rather than being pre-registered.

**ThemeController** is a static singleton initialized in `main()` via `ThemeController.instance.init()` — it is not registered through `InitialBindings`. Access it via `ThemeController.instance`.

### Backend Integration

**Supabase** (PostgreSQL + Auth) is the primary backend. `SupabaseService` (`lib/core/services/supabase_service.dart`) wraps the client and exposes named table references. Key tables: `profiles`, `alerts`, `sos_requests`, `emergency_contacts`, `disaster_reports`, `aid_requests`, `notifications`. Auth supports both email/password and Google OAuth (`AuthController.signInWithGoogle()`).

**FastAPI ML backend** (`backend/`) provides earthquake aftershock prediction (BiLSTM) and flood risk scoring (XGBoost), consumed by `MlAlertService` / `MlAlertController`.

### Alert Data Flow

There are two alert pipelines that converge in the UI:

```
FastAPI ML backend
  └─ MlAlertService  →  MlAlertController
       ├─ earthquakeAlerts: List<EarthquakeAlertModel>
       └─ floodAlert: FloodAlertModel
            │
            └─▶ AlertController._constructAlertsFromMlData()
                     │   converts ML models → List<AlertModel>
                     └─▶ HomeView "Active Alerts" + AlertsListView "Database" tab
```

`AlertController` no longer queries Supabase for alerts — it reads from `MlAlertController` and converts the data to `AlertModel` so the existing home-screen UI continues to work without changes. `AlertService` (Supabase) is still registered but only `viewAlert()` touches it.

`AlertsListView` has three tabs:
- **Database** — `AlertController.alerts` (ML data bridged through `AlertModel`)
- **Earthquakes** — `MlAlertController.earthquakeAlerts` directly (expandable aftershock cards)
- **Floods** — `MlAlertController.floodAlert` directly (risk score + affected areas)

### Environment-Dependent URLs

Two URLs must be updated when switching between Android emulator, iOS Simulator, and physical devices:

**ML backend** — `AppSecrets.mlApiBaseUrl` (`lib/core/secrets/app_secrets.dart`):
- Android emulator → `http://10.0.2.2:8000`
- iOS Simulator → `http://localhost:8000`
- Physical device → your machine's LAN IP

**Chatbot** — `ChatbotService._baseUrl` (`lib/features/chatbot/services/chatbot_service.dart`):
- This is a hardcoded `static const` (not in `AppSecrets`) — edit the file directly when switching environments.
- Falls back to keyword-matching with cached Pakistan emergency helpline data when the backend is unreachable.

### User Roles

Three roles with role-specific profile tables: `citizen`, `aid_worker`, `gov_official`. Role logic is handled in `ProfileService` and `AuthController`.

### Local Caching

`CacheService` uses SharedPreferences with a 30-minute TTL. It caches profile data and emergency contacts to support offline usage.

### Routing

Named routes defined in `lib/core/utilities/app_routes.dart`. Auth flow: `SplashView` → `MainDashboardView` (if logged in) or `SignInView`. Bottom navigation manages: Home, Map, SOS, Chat, Profile tabs.

### Design System

- **Responsive layout:** `flutter_screenutil` (design base: 412×915)
- **Typography:** Google Fonts (Roboto)
- **Colors:** Primary blue `#3B82F6`; status colors green/red/orange/purple
- **Theme:** Light/dark toggled via `ThemeController`
- **Secrets:** Supabase URL, anon key, and ML API base URL live in `lib/core/secrets/app_secrets.dart`

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point — initializes Supabase, ScreenUtil, cache, theme |
| `lib/core/services/initial_bindings.dart` | Registers all GetX singletons (order matters for ML→Alert dependency) |
| `lib/core/utilities/app_routes.dart` | All named routes |
| `lib/core/secrets/app_secrets.dart` | Supabase keys + ML API base URL |
| `lib/features/dashboard/controllers/alert_controller.dart` | Bridges ML data into `AlertModel` for home-screen UI via `ever()` workers |
| `lib/features/dashboard/controllers/ml_alert_controller.dart` | Fetches earthquake/flood/heatmap data from FastAPI; holds device location |
| `lib/features/dashboard/services/ml_alert_service.dart` | HTTP client for FastAPI `/earthquake/check`, `/flood/check`, `/flood/forecast`, `/flood/heatmap` |
| `lib/features/dashboard/models/ml_alert_models.dart` | `EarthquakeAlertModel`, `AftershockModel`, `FloodAlertModel`, `FloodHeatmapPoint` |
| `lib/features/dashboard/presentation/screens/map_view.dart` | Movable Google Map with flood heatmap circles + date-picker forecast panel |
| `lib/features/chatbot/services/chatbot_service.dart` | Chatbot HTTP client with offline keyword-fallback mode |
| `backend/CLAUDE.md` | Full backend architecture reference |
