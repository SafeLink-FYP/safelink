import 'dart:io';

class AppSecrets {
  static const String supabaseUrl = 'https://eoixpffqoygzasyuvahl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvaXhwZmZxb3lnemFzeXV2YWhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMjcyNTcsImV4cCI6MjA3NTgwMzI1N30.HUapK_UmzBSknNnYNS9je9DbwpGMKtOI9aa5dy8b-Zc';

  // Web OAuth Client ID from Google Cloud Console — NOT the Android client.
  // Android Google Sign-In uses this as the `serverClientId`; the issued ID
  // token's audience is this value, and Supabase verifies tokens against it.
  // The same Web Client ID must be configured in Supabase Auth → Providers →
  // Google. The Android calling app is identified by SHA-1 fingerprint +
  // package name registered in the GCP OAuth consent screen.
  //
  // Replace the placeholder below with your real Web Client ID.
  static const String googleWebClientId = '115346446790-0fo3ib6o3knromlqu6oo456ua39okhe5.apps.googleusercontent.com';

  static bool get isGoogleSignInConfigured =>
      !googleWebClientId.startsWith('REPLACE_WITH_');

  static String get mlApiBaseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  // ── Chatbot ────────────────────────────────────────────────────────────────
  // The chatbot backend lives at a different deploy target from the ML API
  // (FastAPI service on Railway in prod). Build-time override:
  //
  //   flutter build apk --release \
  //     --dart-define=CHATBOT_BASE_URL=https://safelink-chatbot.up.railway.app \
  //     --dart-define=CHATBOT_API_KEY=<key>
  //
  // When CHATBOT_BASE_URL is unset, the platform-aware dev fallbacks below
  // mirror the existing mlApiBaseUrl pattern.
  static const String _chatbotBaseUrlOverride =
      String.fromEnvironment('CHATBOT_BASE_URL', defaultValue: '');

  static String get chatbotBaseUrl {
    if (_chatbotBaseUrlOverride.isNotEmpty) return _chatbotBaseUrlOverride;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  // Sent in the X-API-Key header. Required when the backend is running with
  // DEBUG=false; backend's auth dep is a no-op in DEBUG=true mode.
  static const String chatbotApiKey =
      String.fromEnvironment('CHATBOT_API_KEY', defaultValue: '');
}
