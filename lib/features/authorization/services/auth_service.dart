import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final SupabaseService _supabaseService = SupabaseService.instance;

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

  Future<void> signInWithGoogle() async {
    await _supabaseService.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signOut() async {
    await _supabaseService.auth.signOut();
  }

  Future<void> resetPassword(ResetPasswordModel model) async {
    await _supabaseService.auth.resetPasswordForEmail(model.email.trim());
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
}
