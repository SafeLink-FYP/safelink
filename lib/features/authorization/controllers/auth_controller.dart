import 'package:get/get.dart';
import 'package:safelink/features/authorization/data/repositories/auth_repository.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthActionStatus { success, failure }

class AuthActionResult {
  final AuthActionStatus status;
  final String? message;

  const AuthActionResult._(this.status, this.message);

  const AuthActionResult.success([String? message])
      : this._(AuthActionStatus.success, message);
  const AuthActionResult.failure(String message)
      : this._(AuthActionStatus.failure, message);

  bool get isSuccess => status == AuthActionStatus.success;
}

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final Rx<Session?> _session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;

  Session? get session => _session.value;

  bool get isLoggedIn => _session.value != null;

  @override
  void onInit() {
    super.onInit();
    _session.value = _authRepository.currentSession;
    _authRepository.authStateChanges.listen((data) {
      _session.value = data.session;
    });
  }

  Future<AuthActionResult> signUp(SignUpModel model) async {
    try {
      isLoading.value = true;
      await _authRepository.signUp(model);
      return const AuthActionResult.success('Account created successfully!');
    } on AuthException catch (e) {
      return AuthActionResult.failure(e.message);
    } catch (e) {
      return AuthActionResult.failure(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthActionResult> signIn(SignInModel model) async {
    try {
      isLoading.value = true;
      await _authRepository.signIn(model);
      return const AuthActionResult.success();
    } on AuthException catch (e) {
      return AuthActionResult.failure(e.message);
    } catch (e) {
      return AuthActionResult.failure(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthActionResult> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithGoogle();
      return const AuthActionResult.success();
    } catch (e) {
      return AuthActionResult.failure(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthActionResult> signOut() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
      return const AuthActionResult.success();
    } catch (e) {
      return const AuthActionResult.failure('Sign out failed');
    }
  }

  Future<AuthActionResult> resetPassword(ResetPasswordModel model) async {
    try {
      isLoading.value = true;
      await _authRepository.resetPassword(model);
      return const AuthActionResult.success(
        'Check your email for reset instructions.',
      );
    } on AuthException catch (e) {
      return AuthActionResult.failure(e.message);
    } catch (e) {
      return AuthActionResult.failure(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkSession() async {
    return _authRepository.checkSession();
  }
}
