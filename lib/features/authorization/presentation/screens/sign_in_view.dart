import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/core/widgets/custom_divider.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:safelink/features/authorization/presentation/widgets/custom_text_form_field.dart';
import 'package:safelink/features/authorization/presentation/widgets/social_button.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 30.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                        AppAssets.safeLinkLogo,
                        width: 100.w,
                        height: 100.h,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  SizedBox(height: 15.h),
                  Text(
                    'Login to Your Account',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Access your disaster relief app_shell and updates.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  CustomTextFormField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    icon: CupertinoIcons.envelope,
                  ),
                  SizedBox(height: 20.h),
                  CustomTextFormField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    icon: CupertinoIcons.lock,
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.displayMedium,
                          children: [
                            TextSpan(
                              text: 'Forgot Password?',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Get.toNamed(AppRoutes.resetPasswordView),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  CustomElevatedButton(
                    label: 'Sign In',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        DialogHelpers.showLoadingDialog();
                        final result = await _authController.signIn(
                          SignInModel(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          ),
                        );
                        DialogHelpers.hideLoadingDialog();
                        if (result.isSuccess) {
                          Get.offAllNamed(AppRoutes.mainDashboardView);
                        } else {
                          DialogHelpers.showFailure(
                            title: 'Sign In Failed',
                            message: result.message ?? 'Unable to sign in.',
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Expanded(child: CustomDivider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.w),
                        child: Text('OR', style: theme.textTheme.bodyLarge),
                      ),
                      Expanded(child: CustomDivider()),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  SocialButton(
                    label: 'Continue with Google',
                    icon: AppAssets.googleIcon,
                    onPressed: () async {
                      final result = await _authController.signInWithGoogle();
                      if (!result.isSuccess) {
                        DialogHelpers.showFailure(
                          title: 'Error',
                          message: result.message ?? 'Google sign-in failed.',
                        );
                      }
                    },
                  ),
                  SizedBox(height: 30.h),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge,
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: theme.textTheme.displayLarge,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.toNamed(AppRoutes.signUpView),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
