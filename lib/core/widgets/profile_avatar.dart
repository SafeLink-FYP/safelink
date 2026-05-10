import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final File? image;
  final String? imageUrl;
  final VoidCallback? onPickImage;
  final VoidCallback? onRemoveImage;
  final bool showControls;

  const ProfileAvatar({
    super.key,
    required this.image,
    this.imageUrl,
    this.onPickImage,
    this.onRemoveImage,
    this.showControls = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(15.r),
          height: 150.h,
          width: 150.w,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                offset: const Offset(0, 25),
                blurRadius: 50.r,
                spreadRadius: -12.r,
              ),
            ],
          ),
          child: _buildAvatarContent(),
        ),
        if (showControls)
          Positioned(
            bottom: 15.h,
            right: 25.w,
            child: InkWell(
              onTap: image == null ? onPickImage : onRemoveImage,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: image == null ? Colors.white : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  image == null ? Icons.upload : Icons.close,
                  size: 18.sp,
                  color: image == null ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (image != null) {
      return Image.file(image!, fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
              strokeWidth: 2.w,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Padding(
      padding: EdgeInsets.all(35.r),
      child: SvgPicture.asset(
        AppAssets.personIcon,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
