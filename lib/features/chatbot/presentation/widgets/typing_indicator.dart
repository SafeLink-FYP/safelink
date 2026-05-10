import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Three-dot animated typing indicator. Reduced-motion accessible — when
/// `MediaQuery.disableAnimations` is true the dots stay flat (no animation,
/// just three filled dots).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Assistant is typing',
      liveRegion: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h, right: 60.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  // Stagger so dots ripple left → right.
                  final t = (_ctrl.value + i * 0.2) % 1.0;
                  // Triangle wave: 0 → 1 → 0
                  final intensity = disableAnim
                      ? 1.0
                      : (t < 0.5 ? t * 2 : (1 - t) * 2);
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.hintColor.withValues(
                          alpha: 0.35 + 0.55 * intensity,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
