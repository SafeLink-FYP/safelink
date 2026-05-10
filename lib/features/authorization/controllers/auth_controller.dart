import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/authorization/data/repositories/auth_repository.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:safelink/features/authorization/services/auth_service.dart';
import 'package:safelink/features/chatbot/services/chat_history_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthActionStatus { success, failure, cancelled }

class AuthActionResult {
  final AuthActionStatus status;
  final String? message;

  const AuthActionResult._(this.status, this.message);

  const AuthActionResult.success([String? message])
    : this._(AuthActionStatus.success, message);

  const AuthActionResult.failure(String message)
    : this._(AuthActionStatus.failure, message);

  const AuthActionResult.cancelled([String? message])
    : this._(AuthActionStatus.cancelled, message);

  bool get isSuccess => status == AuthActionStatus.success;

  bool get isCancelled => status == AuthActionStatus.cancelled;
}

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final Rx<Session?> _session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;
  final RxBool _isInRecovery = false.obs;

  Session? get session => _session.value;

  bool get isLoggedIn => _session.value != null;

  /// True from the moment supabase_flutter processes a password-recovery
  /// deep link (event `AuthChangeEvent.passwordRecovery`) until the user
  /// successfully sets a new password, or signs out. SplashView reads this
  /// to avoid routing to the dashboard during recovery.
  bool get isInRecovery => _isInRecovery.value;

  @override
  void onInit() {
    super.onInit();
    _session.value = _authRepository.currentSession;
    _authRepository.authStateChanges.listen((data) {
      _session.value = data.session;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        _isInRecovery.value = true;
        // Defer navigation a microtask so we don't fight the splash's own
        // routing if the deep link arrives during cold start.
        Future.microtask(() {
          Get.offAllNamed(AppRoutes.setNewPasswordView);
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        _isInRecovery.value = false;
      }
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
    } on GoogleSignInCancelled {
      return const AuthActionResult.cancelled();
    } on AuthException catch (e) {
      return AuthActionResult.failure(e.message);
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
      // Privacy hand-off for shared devices: wipe persisted chat history so
      // the next user that signs in on this device can't see the previous
      // user's conversations. Best-effort — a failure here must not block
      // the sign-out itself, hence the swallowed catch.
      try {
        await Get.find<ChatHistoryService>().clear();
      } catch (_) {}
      return const AuthActionResult.success();
    } catch (e) {
      return const AuthActionResult.failure('Sign out failed');
    }
  }

  /// RESET PASSWORD
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

  /// UPDATE PASSWORD
  ///
  /// Called from SetNewPasswordView after the user clicks the recovery
  /// deep link. Updates the Supabase user's password using the active
  /// recovery session, signs out (so the user re-authenticates with the
  /// new password), and routes to the sign-in screen.
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _authRepository.updatePassword(newPassword);
      _isInRecovery.value = false;

      // Clear the recovery session so the next login is a fresh sign-in
      // with the new password.
      await _authRepository.signOut();

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Password Updated',
        message: 'Your password has been updated. Please sign in.',
      );

      Get.offAllNamed(AppRoutes.signInView);
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: "Couldn't update password",
        message: e.message,
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: "Couldn't update password",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkSession() async {
    return _authRepository.checkSession();
  }
}
