import 'dart:async';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safelink/core/secrets/app_secrets.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
  @override
  String toString() => 'Sign-in cancelled.';
}

class AuthService extends GetxService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  GoogleSignIn? _googleSignInInstance;

  Session? get currentSession => _supabaseService.auth.currentSession;

  Stream<AuthState> get authStateChanges =>
      _supabaseService.auth.onAuthStateChange;

  Future<AuthResponse> signUp(SignUpModel model) async {
    final AuthResponse response = await _supabaseService.auth.signUp(
      email: model.email.trim(),
      password: model.password,
      data: model.toAuthMetadata(),
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    return response;
  }

  Future<void> signIn(SignInModel model) async {
    await _supabaseService.auth.signInWithPassword(
      email: model.email.trim(),
      password: model.password,
    );
  }

  /// Native Google Sign-In on Android → exchange the Google ID token for a
  /// Supabase session via `signInWithIdToken`. The Postgres trigger
  /// `trg_on_auth_user_created` then auto-creates the `profiles` row, so no
  /// post-auth profile-completion step is needed for the OAuth flow.
  ///
  /// Throws [GoogleSignInCancelled] if the user dismisses the picker.
  Future<void> signInWithGoogle() async {
    if (!AppSecrets.isGoogleSignInConfigured) {
      throw const AuthException(
        'Google sign-in is not configured. Set AppSecrets.googleWebClientId '
        'to your Web OAuth client ID from Google Cloud Console.',
      );
    }

    final account = await _googleSignIn().signIn();
    if (account == null) {
      throw const GoogleSignInCancelled();
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      throw const AuthException(
        'Google did not return an ID token. Verify the SHA-1 fingerprint of '
        'your debug/release keystore and the package name '
        '"com.example.safelink" are registered against the same Web Client '
        'ID in Google Cloud Console, and that Supabase\'s Google provider '
        'uses that same Web Client ID.',
      );
    }

    await _supabaseService.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  Future<void> signOut() async {
    // Sign out of Google first so the next login shows the account picker.
    // Best-effort: don't fail Supabase signOut if Google session is already gone.
    try {
      if (AppSecrets.isGoogleSignInConfigured) {
        await _googleSignIn().signOut();
      }
    } catch (_) {
      /* ignore */
    }
    await _supabaseService.auth.signOut();
  }

  Future<void> resetPassword(ResetPasswordModel model) async {
    await _supabaseService.auth.resetPasswordForEmail(
      model.email.trim(),
      redirectTo: 'safelink://reset-password',
    );
  }

  /// Sets a new password for the currently authenticated user.
  /// Used after a `passwordRecovery` event when the user has clicked
  /// the deep link from the Supabase reset-password email.
  Future<void> updatePassword(String newPassword) async {
    await _supabaseService.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<bool> checkSession() async {
    try {
      final session = _supabaseService.auth.currentSession;
      if (session == null) return false;

      if (session.isExpired) {
        await _supabaseService.auth.refreshSession();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // Android-only configuration. `serverClientId` is the Web OAuth Client ID;
  // the issued ID token is signed with this audience so Supabase can verify
  // it. The Android calling app is identified by SHA-1 fingerprint + package
  // name registered against the same Web Client ID in Google Cloud Console,
  // so no per-platform `clientId` is needed.
  GoogleSignIn _googleSignIn() {
    return _googleSignInInstance ??= GoogleSignIn(
      serverClientId: AppSecrets.googleWebClientId,
      scopes: const ['email', 'profile', 'openid'],
    );
  }
}
