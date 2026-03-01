import 'dart:io';
import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final _supabaseService = SupabaseService.instance;
  final Rx<Session?> _session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;

  Session? get session => _session.value;

  bool get isLoggedIn => _session.value != null;

  @override
  void onInit() {
    super.onInit();
    _session.value = _supabaseService.auth.currentSession;
    _supabaseService.auth.onAuthStateChange.listen((data) {
      _session.value = data.session;
    });
  }

  /// SIGN OUT
  Future<void> signUp(SignUpModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      final AuthResponse response = await _supabaseService.auth.signUp(
        email: model.email,
        password: model.password,
        data: model.toAuthMetadata(),
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      String? avatarUrl;

      if (model.profilePicture != null) {
        avatarUrl = await _uploadAvatar(user.id, model.profilePicture!);
      }

      await _supabaseService.profiles
          .update(model.toProfileUpdate(avatarUrl))
          .eq('id', user.id);

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Success',
        message:
        'Account created successfully! Please check your email to verify your account.',
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

      await _supabaseService.auth.signInWithPassword(
        email: model.email,
        password: model.password,
      );

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
      await _supabaseService.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      DialogHelpers.showFailure(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
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

      await _supabaseService.auth.resetPasswordForEmail(model.email);

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

  /// UPLOAD AVATAR
  Future<String?> _uploadAvatar(String userID, File file) async {
    try {
      final extension = file.path.split('.').last;
      final path = '$userID/avatar.$extension';

      await _supabaseService.storage
          .from('avatars')
          .upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _supabaseService.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  /// CHECK SESSION
  Future<bool> checkSession() async {
    try {
      final session = _supabaseService.auth.currentSession;
      if (session == null) return false;
      if (session.isExpired) {
        await _supabaseService.auth.refreshSession();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
