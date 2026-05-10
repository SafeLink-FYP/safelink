import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePin extends StatelessWidget {
  final String label;
  final int count;
  const ProfilePin({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.20),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
