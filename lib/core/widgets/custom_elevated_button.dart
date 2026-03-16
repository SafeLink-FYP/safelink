import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: theme.textTheme.headlineLarge?.copyWith(color: AppTheme.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
