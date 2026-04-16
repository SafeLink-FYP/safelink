import 'package:flutter/material.dart';
import 'package:safelink/features/authorization/presentation/widgets/custom_text_form_field.dart';

class DatePickerTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const DatePickerTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.backgroundColor,
    this.keyboardType,
    required this.icon,
    this.iconColor,
    this.validator,
  });

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              confirmButtonStyle: TextButton.styleFrom(
                textStyle: theme.textTheme.labelSmall,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                textStyle: theme.textTheme.labelSmall,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: CustomTextFormField(
          label: label,
          hintText: hintText,
          icon: icon,
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
