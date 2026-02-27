import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';

class HelplineButton extends StatelessWidget {
  final HelplineInfo helpline;
  final void Function()? onTap;

  const HelplineButton({super.key, required this.helpline, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone, size: 14.sp, color: AppTheme.green),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          helpline.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (helpline.available24x7) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '24/7',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    helpline.number,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.green.withValues(alpha: 0.8),
                    ),
                  ),
                  if (helpline.description != null &&
                      helpline.description!.isNotEmpty)
                    Text(
                      helpline.description!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 9.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Icon(Icons.call, size: 18.sp, color: AppTheme.green),
          ],
        ),
      ),
    );
  }
}
