import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';

class DialogHelpers {
  static void showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() => Get.back();

  static void showSuccess({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.green,
      colorText: AppTheme.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showFailure({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.red,
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showSOSDialog({
    required BuildContext context,
    required void Function()? onPressed,
  }) {
    final theme = Theme.of(context);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightRed,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.sosIcon,
                  height: 30.h,
                  width: 30.w,
                  colorFilter: ColorFilter.mode(AppTheme.red, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: 15.h),
              Text("Cancel SOS", style: theme.textTheme.headlineLarge),
              SizedBox(height: 10.h),
              Text(
                "Your emergency alert is currently active.\nAre you sure you want to cancel it?",
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium,
              ),
              SizedBox(height: 25.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Keep SOS Active",
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Cancel SOS",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
