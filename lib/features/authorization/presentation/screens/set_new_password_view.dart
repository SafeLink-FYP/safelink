import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/utilities/validators.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/authorization/presentation/widgets/custom_text_form_field.dart';

class SetNewPasswordView extends StatefulWidget {
  const SetNewPasswordView({super.key});

  @override
  State<SetNewPasswordView> createState() => _SetNewPasswordViewState();
}

class _SetNewPasswordViewState extends State<SetNewPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RxBool _hasMinLength = false.obs;
  final RxBool _hasUppercase = false.obs;
  final RxBool _hasNumber = false.obs;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    _hasMinLength.value = value.length >= 8;
    _hasUppercase.value = RegExp(r'[A-Z]').hasMatch(value);
    _hasNumber.value = RegExp(r'[0-9]').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 30.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.arrowIcon,
                        height: 25.h,
                        width: 25.w,
                        colorFilter: ColorFilter.mode(
                          theme.iconTheme.color ?? AppTheme.darkGreyColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),

                  Image.asset(
                    AppAssets.safeLinkLogo,
                    width: 100.w,
                    height: 100.h,
                  ),

                  SizedBox(height: 15.h),

                  Text(
                    'Set New Password',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Create a strong new password for your account.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  CustomTextFormField(
                    label: 'New Password',
                    hintText: 'Create a new password',
                    isPassword: true,
                    icon: CupertinoIcons.lock,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                    onChanged: _onPasswordChanged,
                  ),
                  SizedBox(height: 20.h),
                  CustomTextFormField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your new password',
                    isPassword: true,
                    icon: CupertinoIcons.lock,
                    controller: _confirmPasswordController,
                    validator: (v) => Validators.validateConfirmPassword(
                      v,
                      _passwordController.text,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password must contain:',
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: 10.h),
                        _buildPasswordRule(
                          'At least 8 characters',
                          _hasMinLength,
                        ),
                        _buildPasswordRule(
                          'One uppercase letter',
                          _hasUppercase,
                        ),
                        _buildPasswordRule('One number', _hasNumber),
                      ],
                    ),
                  ),
                  SizedBox(height: 35.h),
                  CustomElevatedButton(
                    label: 'Update Password',
                    isLoading: _authController.isLoading.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _authController.updatePassword(
                          _passwordController.text.trim(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String label, RxBool isValid) {
    final theme = Get.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => Checkbox(
            value: isValid.value,
            onChanged: null,
            checkColor: AppTheme.white,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
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
}
