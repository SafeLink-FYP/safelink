import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safelink/core/themes/app_theme.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final void Function()? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: AppTheme.transparentColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: theme.iconTheme.size,
              height: theme.iconTheme.size,
            ),
            SizedBox(width: 15.w),
            Text(label, style: theme.textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
