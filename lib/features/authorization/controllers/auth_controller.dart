import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:safelink/features/authorization/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  final AuthService _authService = Get.find<AuthService>();

  final Rx<Session?> _session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;

  Session? get session => _session.value;

  bool get isLoggedIn => _session.value != null;

  @override
  void onInit() {
    super.onInit();
    _session.value = _authService.currentSession;
    _authService.authStateChanges.listen((data) {
      _session.value = data.session;
    });
  }

  /// SIGN UP
  Future<void> signUp(SignUpModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _authService.signUp(model);

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Success',
        message: 'Account created successfully!',
      );
      Get.offAllNamed('signInView');
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Sign Up Failed', message: e.message);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SIGN IN
  Future<void> signIn(SignInModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _authService.signIn(model);

      DialogHelpers.hideLoadingDialog();
      Get.offAllNamed('mainDashboardView');
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Sign In Failed', message: e.message);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SIGN IN VIA GOOGLE OAUTH
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _authService.signInWithGoogle();
    } catch (e) {
      DialogHelpers.showFailure(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('signInView');
    } catch (e) {
      DialogHelpers.showFailure(title: 'Error', message: 'Sign out Failed');
    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword(ResetPasswordModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _authService.resetPassword(model);

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Email Sent',
        message: 'Check your email for reset instructions.',
      );
      Get.offAllNamed('signInView');
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Error', message: e.message);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// CHECK SESSION
  Future<bool> checkSession() async {
    return _authService.checkSession();
  }
}
