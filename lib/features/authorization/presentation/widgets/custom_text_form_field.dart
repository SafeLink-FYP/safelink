import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.headlineMedium),
        SizedBox(height: 10.h),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(
              widget.icon,
              size: 20.sp,
              color: AppTheme.hintTextColor,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 20.sp,
                      color: AppTheme.hintTextColor,
                    ),
                    onPressed: () => setState(() {
                      _obscureText = !_obscureText;
                    }),
                  )
                : null,
          ),
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}
