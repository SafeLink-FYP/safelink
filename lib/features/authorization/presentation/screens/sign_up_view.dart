import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/utilities/validators.dart';
import 'package:safelink/core/widgets/profile_avatar.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/features/authorization/controllers/sign_up_page_controller.dart';
import 'package:safelink/features/authorization/models/auth_models.dart';
import 'package:safelink/features/authorization/presentation/widgets/custom_text_form_field.dart';
import 'package:safelink/features/authorization/presentation/widgets/date_picker_text_field.dart';
import 'package:safelink/features/authorization/presentation/widgets/social_button.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ImagePickingController _imagePickingController =
      Get.find<ImagePickingController>();
  final SignUpPageController _signUpPageController = Get.put(
    SignUpPageController(),
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _imagePickingController.dispose();
    _signUpPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Flexible(
            child: PageView.builder(
              itemCount: 4,
              physics: NeverScrollableScrollPhysics(),
              controller: _signUpPageController.pageController,
              onPageChanged: (value) =>
                  _signUpPageController.currentPage.value = value,
              itemBuilder: (context, index) {
                Widget page;
                switch (index) {
                  case 0:
                    page = _buildEmailStep(theme);
                    break;
                  case 1:
                    page = _buildDetailsStep(theme);
                    break;
                  case 2:
                    page = _buildPasswordStep(theme);
                    break;
                  case 3:
                    page = _buildProfilePictureStep(theme);
                    break;
                  default:
                    page = SizedBox.shrink();
                    break;
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(40.r),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: () =>
                                _signUpPageController.previousPage(),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        page,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create a New Account',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Join the relief network to stay updated and connected.',
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
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _signUpPageController.nextPage();
            }
          },
        ),
        SizedBox(height: 30.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[100]!,
                      Colors.grey[900]!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text('OR', style: theme.textTheme.bodyLarge),
            ),
            Expanded(
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[100]!,
                      Colors.grey[900]!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        SocialButton(
          label: 'Continue with Google',
          icon: AppAssets.googleIcon,
          onPressed: () => _authController.signInWithGoogle(),
        ),
        SizedBox(height: 30.h),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyLarge,
            children: [
              TextSpan(text: "Already have an account? "),
              TextSpan(
                text: 'Sign In',
                style: theme.textTheme.displayLarge,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.offAndToNamed('signInView'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Tell us about yourself',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Help us personalize your experience',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        CustomTextFormField(
          label: 'First Name',
          hintText: 'First Name',
          controller: _firstNameController,
          validator: (value) => Validators.validateName(value),
          icon: CupertinoIcons.person,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'Last Name',
          hintText: 'Last Name',
          controller: _lastNameController,
          validator: (value) => Validators.validateName(value),
          icon: CupertinoIcons.person,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'Phone',
          hintText: 'Enter Phone Number',
          controller: _phoneController,
          validator: (value) => Validators.validatePhoneNumber(value),
          icon: CupertinoIcons.phone,
        ),
        SizedBox(height: 20.h),
        DatePickerTextField(
          label: 'Date of Birth',
          hintText: 'Select Date of Birth',
          icon: Icons.calendar_month,
          controller: _dobController,
          validator: (value) => Validators.validateDOB(value),
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _signUpPageController.nextPage();
            }
          },
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _signUpPageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create a password',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Make it strong and memorable',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        CustomTextFormField(
          label: 'Password',
          hintText: 'Create a password',
          isPassword: true,
          icon: CupertinoIcons.lock,
          controller: _passwordController,
          validator: (value) => Validators.validatePassword(value),
          onChanged: _signUpPageController.onPasswordChanged,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'Confirm Password',
          hintText: 'Confirm your password',
          isPassword: true,
          icon: CupertinoIcons.lock,
          controller: _confirmPasswordController,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Password must contain:',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 10.h),
              _buildPasswordRuleRow(
                'At least 8 characters',
                _signUpPageController.hasMinLength,
              ),
              _buildPasswordRuleRow(
                'One uppercase letter',
                _signUpPageController.hasUppercase,
              ),
              _buildPasswordRuleRow(
                'One number',
                _signUpPageController.hasNumber,
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _signUpPageController.nextPage();
            }
          },
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _signUpPageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildPasswordRuleRow(String label, RxBool isValid) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => Checkbox(
            value: isValid.value,
            onChanged: null,
            checkColor: AppTheme.white,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return isValid.value ? AppTheme.green : Colors.grey.shade400;
              }
              return isValid.value ? AppTheme.green : Colors.grey.shade400;
            }),
            side: BorderSide(
              color: isValid.value ? AppTheme.green : Colors.grey.shade400,
              width: 1.w,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Text(label, style: theme.textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildProfilePictureStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Add a profile picture',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Optional: Add a photo to make your profile more personal.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Obx(() {
          final image = _imagePickingController.selectedImage.value;
          return ProfileAvatar(
            image: image != null ? File(image.path) : null,
            onPickImage: _imagePickingController.pickImage,
            onRemoveImage: () =>
                _imagePickingController.selectedImage.value = null,
            showControls: true,
          );
        }),
        SizedBox(height: 10.h),
        Text(
          'Recommended: Square image, at least 400x400px',
          style: theme.textTheme.bodySmall,
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Complete Registration',
          onPressed: () => _authController.signUp(
            SignUpModel(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              phone: _phoneController.text.trim(),
              dateOfBirth: _dobController.text.trim(),
              profilePicture:
                  _imagePickingController.selectedImage.value != null
                  ? File(_imagePickingController.selectedImage.value!.path)
                  : null,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _signUpPageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
