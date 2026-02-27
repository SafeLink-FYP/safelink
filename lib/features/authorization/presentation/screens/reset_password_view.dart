import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/utilities/validators.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/features/authorization/presentation/widgets/custom_text_form_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 50.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Reset Your Password',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Enter your email to receive reset instructions.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  CustomTextFormField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    validator: (value) => Validators.validateEmail(value),
                    icon: CupertinoIcons.envelope,
                  ),
                  SizedBox(height: 35.h),
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: "💡 Note: ",
                            style: theme.textTheme.displayMedium,
                          ),
                          TextSpan(
                            text:
                                'If the email exists in our system, you\'ll receive password reset instructions within a few minutes.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),
                  CustomElevatedButton(
                    label: 'Send Reset Link',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _authController.resetPassword(
                          email: _emailController.text.trim(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 25.h),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Back to Login',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.offAndToNamed('signInView'),
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
