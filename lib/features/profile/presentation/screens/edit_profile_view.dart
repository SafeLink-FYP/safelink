import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';
import 'package:safelink/core/widgets/profile_avatar.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  final ProfileController _profileController = Get.find<ProfileController>();
  final ImagePickingController _imagePickingController =
      Get.find<ImagePickingController>();

  @override
  void initState() {
    super.initState();
    final profile = _profileController.profile.value;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedImage = _imagePickingController.selectedImage.value;
    if (selectedImage != null) {
      final Uint8List bytes = await selectedImage.readAsBytes();
      await _profileController.uploadAvatar(bytes);
      _imagePickingController.selectedImage.value = null;
    }

    final updates = <String, dynamic>{};
    final profile = _profileController.profile.value;

    final newFullName = [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    if (newFullName != (profile?.fullName ?? '')) {
      updates['full_name'] = newFullName;
    }
    if (_phoneController.text.trim() != (profile?.phone ?? '')) {
      updates['phone'] = _phoneController.text.trim();
    }
    if (updates.isNotEmpty) {
      await _profileController.updateProfile(updates);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_back, color: AppTheme.white),
                      ),
                    ),
                    Obx(() {
                      final localImage =
                          _imagePickingController.selectedImage.value;
                      final avatarUrl = _profileController.avatarUrl;

                      return ProfileAvatar(
                        image: localImage != null
                            ? File(localImage.path)
                            : null,
                        imageUrl: localImage == null ? avatarUrl : null,
                        onPickImage: _imagePickingController.pickImage,
                        onRemoveImage: () =>
                            _imagePickingController.selectedImage.value = null,
                        showControls: true,
                      );
                    }),
                    SizedBox(height: 10.h),
                    Obx(
                      () => Text(
                        _profileController.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Obx(
                      () => Text(
                        _profileController.phone,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Name', style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter first name',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      Text('Last Name', style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter last name',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      Text('Phone', style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Enter phone number',
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Obx(
                        () => CustomElevatedButton(
                          label:
                              _profileController.isUploadingAvatar.value ||
                                  _profileController.isLoading.value
                              ? 'Saving...'
                              : 'Save Changes',
                          onPressed:
                              _profileController.isUploadingAvatar.value ||
                                  _profileController.isLoading.value
                              ? null
                              : _saveProfile,
                        ),
                      ),
                    ],
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
