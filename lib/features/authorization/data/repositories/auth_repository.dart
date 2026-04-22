import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:safelink/features/authorization/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Session? get currentSession => _authService.currentSession;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<void> signUp(SignUpModel model) async {
    await _authService.signUp(model);
  }

  Future<void> signIn(SignInModel model) async {
    await _authService.signIn(model);
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(ResetPasswordModel model) async {
    await _authService.resetPassword(model);
  }

  Future<bool> checkSession() async {
    return _authService.checkSession();
  }
}
