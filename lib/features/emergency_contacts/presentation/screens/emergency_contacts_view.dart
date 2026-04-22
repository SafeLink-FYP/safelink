import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/shared/controllers/emergency_contact_controller.dart';

class EmergencyContactsView extends StatelessWidget {
  const EmergencyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmergencyContactController());
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.redGradient,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, color: AppTheme.white),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      'Emergency Contacts',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showAddContactDialog(context, controller),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.contacts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(25.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.phoneIcon,
                            width: 60.w,
                            height: 60.h,
                            colorFilter: ColorFilter.mode(
                              theme.hintColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            'No Emergency Contacts',
                            style: theme.textTheme.headlineLarge,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Add contacts who should be notified\nin case of an emergency',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 25.h),
                          CustomElevatedButton(
                            label: 'Add Contact',
                            onPressed: () =>
                                _showAddContactDialog(context, controller),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshContacts,
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: controller.contacts.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final contact = controller.contacts[index];
                      return Container(
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.transparentColor.withValues(
                                alpha: 0.10,
                              ),
                              offset: const Offset(0, 1),
                              blurRadius: 3.r,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: contact.isPrimary
                                    ? AppTheme.redGradient
                                    : AppTheme.primaryGradient,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.personIcon,
                                width: 20.w,
                                height: 20.h,
                                colorFilter: ColorFilter.mode(
                                  AppTheme.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        contact.name,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      if (contact.isPrimary) ...[
                                        SizedBox(width: 8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.red.withValues(
                                              alpha: 0.10,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            'Primary',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppTheme.red,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    contact.phone,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (contact.relationship != null) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      contact.relationship!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.hintColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(
                                context,
                                controller,
                                contact.id,
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppTheme.red,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.contacts.isNotEmpty
            ? FloatingActionButton(
                backgroundColor: AppTheme.primaryColor,
                onPressed: () => _showAddContactDialog(context, controller),
                child: const Icon(Icons.add, color: AppTheme.white),
              )
            : const SizedBox(),
      ),
    );
  }

  void _showAddContactDialog(
    BuildContext context,
    EmergencyContactController controller,
  ) {
    final theme = Get.theme;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    final isPrimary = false.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(25.r),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: theme.hintColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Add Emergency Contact', style: theme.textTheme.titleSmall),
              SizedBox(height: 20.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  hintText: 'Relationship (optional)',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => CheckboxListTile(
                  value: isPrimary.value,
                  onChanged: (v) => isPrimary.value = v ?? false,
                  title: Text(
                    'Set as primary contact',
                    style: theme.textTheme.headlineMedium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                label: 'Add Contact',
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    Get.snackbar('Error', 'Name and phone are required');
                    return;
                  }
                  controller.addContact(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    relationship: relationshipController.text.trim().isEmpty
                        ? null
                        : relationshipController.text.trim(),
                    isPrimary: isPrimary.value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(
    BuildContext context,
    EmergencyContactController controller,
    String id,
  ) {
    Get.defaultDialog(
      title: 'Delete Contact',
      middleText: 'Are you sure you want to remove this emergency contact?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: AppTheme.white,
      buttonColor: AppTheme.red,
      onConfirm: () {
        Get.back();
        controller.deleteContact(id);
      },
    );
  }
}

