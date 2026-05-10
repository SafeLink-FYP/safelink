import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/animated_press_effect.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPressEffect(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.40),
              offset: const Offset(0, 8),
              blurRadius: 20.r,
              spreadRadius: -3.r,
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.white,
                    ),
                  ),
                ),
              )
            : Text(
                label,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
