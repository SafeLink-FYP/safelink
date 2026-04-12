import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/controllers/disaster_report_controller.dart';

class ReportIncidentView extends StatefulWidget {
  const ReportIncidentView({super.key});

  @override
  State<ReportIncidentView> createState() => _ReportIncidentViewState();
}

class _ReportIncidentViewState extends State<ReportIncidentView> {
  final DisasterReportController controller = Get.put(
    DisasterReportController(),
  );
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  static const _disasterTypes = [
    {
      'id': 'flood',
      'label': 'Flood',
      'icon': Icons.water_drop,
      'colors': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    },
    {
      'id': 'earthquake',
      'label': 'Earthquake',
      'icon': Icons.graphic_eq,
      'colors': [Color(0xFFEF4444), Color(0xFFF97316)],
    },
    {
      'id': 'medical',
      'label': 'Medical',
      'icon': Icons.medical_services,
      'colors': [Color(0xFFDC2626), Color(0xFFF43F5E)],
    },
    {
      'id': 'other',
      'label': 'Other',
      'icon': Icons.info,
      'colors': [Color(0xFF6B7280), Color(0xFF4B5563)],
    },
  ];

  static const _severityLevels = [
    {
      'id': 'low',
      'label': 'Low',
      'desc': 'Minor, no immediate danger',
      'color': Color(0xFF22C55E),
    },
    {
      'id': 'high',
      'label': 'High',
      'desc': 'Serious danger, help needed',
      'color': Color(0xFFF97316),
    },
    {
      'id': 'critical',
      'label': 'Critical',
      'desc': 'Life-threatening, urgent response',
      'color': Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isSubmitting.value == false &&
              controller.currentStep.value == 0) {
            return _buildSuccessScreen(theme);
          }
          return Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (controller.currentStep.value > 1) {
                              controller.prevStep();
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: AppTheme.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report Incident',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.white,
                                ),
                              ),
                              Text(
                                'Step ${controller.currentStep.value} of 3',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.white.withValues(alpha: 0.80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: List.generate(3, (i) {
                        return Expanded(
                          child: Container(
                            height: 5.h,
                            margin: EdgeInsets.only(right: i < 2 ? 8.w : 0),
                            decoration: BoxDecoration(
                              color: i < controller.currentStep.value
                                  ? AppTheme.white
                                  : AppTheme.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(25.r),
                  child: _buildStep(theme),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep(ThemeData theme) {
    switch (controller.currentStep.value) {
      case 1:
        return _buildStep1(theme);
      case 2:
        return _buildStep2(theme);
      case 3:
        return _buildStep3(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What type of disaster?', style: theme.textTheme.titleSmall),
        SizedBox(height: 5.h),
        Text(
          'Select the type of incident you want to report',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 20.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.5,
          children: _disasterTypes.map((type) {
            final isSelected = controller.selectedType.value == type['id'];
            final colors = type['colors'] as List<Color>;
            return InkWell(
              onTap: () => controller.selectedType.value = type['id'] as String,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.dividerColor,
                    width: isSelected ? 2.w : 1.w,
                  ),
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        gradient: LinearGradient(colors: colors),
                      ),
                      child: Icon(
                        type['icon'] as IconData,
                        color: AppTheme.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      type['label'] as String,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 25.h),
        _buildContinueButton(
          enabled: controller.selectedType.value.isNotEmpty,
          onTap: () => controller.nextStep(),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How severe is it?', style: theme.textTheme.titleSmall),
        SizedBox(height: 5.h),
        Text(
          'Help us prioritize the response',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 20.h),
        ..._severityLevels.map((level) {
          final isSelected = controller.selectedSeverity.value == level['id'];
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
              onTap: () =>
                  controller.selectedSeverity.value = level['id'] as String,
              borderRadius: BorderRadius.circular(15.r),
              child: Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.dividerColor,
                    width: isSelected ? 2.w : 1.w,
                  ),
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: level['color'] as Color,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level['label'] as String,
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                            level['desc'] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 20.sp,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppTheme.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location', style: theme.textTheme.bodySmall),
                    Obx(
                      () => Text(
                        controller.location.value,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  'GPS',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 25.h),
        _buildContinueButton(
          enabled: controller.selectedSeverity.value.isNotEmpty,
          onTap: () => controller.nextStep(),
        ),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Details', style: theme.textTheme.titleSmall),
        SizedBox(height: 5.h),
        Text(
          'Provide more information to help responders',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 20.h),
        Text('Title', style: theme.textTheme.bodySmall),
        SizedBox(height: 5.h),
        TextField(
          controller: titleCtrl,
          onChanged: (val) => controller.title.value = val,
          style: theme.textTheme.headlineMedium,
          decoration: InputDecoration(
            hintText: 'Short headline, e.g. "Flash flood on Main Rd"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Text('Description', style: theme.textTheme.bodySmall),
        SizedBox(height: 5.h),
        TextField(
          controller: descriptionCtrl,
          onChanged: (val) => controller.description.value = val,
          maxLines: 5,
          style: theme.textTheme.headlineMedium,
          decoration: InputDecoration(
            hintText: 'Describe the situation in detail...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 25.h),
        InkWell(
          onTap: () async {
            final success = await controller.submitReport();
            if (success) {
              controller.currentStep.value = 0;
            }
          },
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, color: AppTheme.white, size: 18.sp),
                SizedBox(width: 10.w),
                Text(
                  'Submit Report',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offNamed('/caseTrackingView');
      }
    });
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(25.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.white,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 25.h),
            Text('Report Submitted!', style: theme.textTheme.titleMedium),
            SizedBox(height: 10.h),
            Text(
              'Your incident report has been sent to local authorities and relief teams.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              'Redirecting to case tracking...',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton({
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: enabled ? AppTheme.primaryGradient : null,
          color: enabled ? null : Colors.grey.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: enabled ? AppTheme.white : Colors.grey,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
