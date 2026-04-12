import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool gradient;
  final bool glow;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.gradient = false,
    this.glow = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(15.r);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius as BorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.w, sigmaY: 8.h),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: gradient
                  ? null
                  : isDark
                  ? Colors.black.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.80),
              gradient: gradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.10),
                        AppTheme.purple.withValues(alpha: 0.10),
                      ],
                    )
                  : null,
              border: Border.all(
                color: gradient
                    ? AppTheme.primaryColor.withValues(alpha: 0.20)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.20),
              ),
              boxShadow: glow
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.20),
                        blurRadius: 16.r,
                        spreadRadius: -4.r,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
