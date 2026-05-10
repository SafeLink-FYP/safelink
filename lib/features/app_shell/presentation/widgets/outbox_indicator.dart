import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/outbox/controllers/outbox_controller.dart';

/// Surfaces queued / failed offline submissions on the citizen home view.
/// Hides itself entirely when both queues are empty so the header stays
/// uncluttered for the common online case. Tapping the failed pill
/// retries everything; tapping pending forces a drain attempt.
class OutboxIndicator extends StatelessWidget {
  const OutboxIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OutboxController>()) return const SizedBox.shrink();
    final controller = Get.find<OutboxController>();
    final theme = Theme.of(context);
    return Obx(() {
      final pending = controller.pendingCount.value;
      final failed = controller.failedCount.value;
      final draining = controller.isDraining.value;
      if (pending == 0 && failed == 0) return const SizedBox.shrink();
      return Row(
        children: [
          if (pending > 0)
            Expanded(
              child: _Chip(
                color: AppTheme.primaryColor,
                icon: draining
                    ? Icons.sync_rounded
                    : Icons.schedule_send_rounded,
                label: draining
                    ? 'Sending $pending queued…'
                    : '$pending awaiting connection',
                onTap: controller.drain,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (pending > 0 && failed > 0) SizedBox(width: 10.w),
          if (failed > 0)
            Expanded(
              child: _Chip(
                color: AppTheme.red,
                icon: Icons.error_outline_rounded,
                label: '$failed failed — tap to retry',
                onTap: () async {
                  for (final item in controller.failed) {
                    await controller.retryFailed(item.id);
                  }
                },
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textStyle,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.white, size: 16.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
