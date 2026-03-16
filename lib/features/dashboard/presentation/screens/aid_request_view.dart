import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/custom_elevated_button.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/controllers/aid_request_controller.dart';

class AidRequestView extends StatefulWidget {
  const AidRequestView({super.key});

  @override
  State<AidRequestView> createState() => _AidRequestViewState();
}

class _AidRequestViewState extends State<AidRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedType = 'medical';
  String _selectedUrgency = 'medium';

  final _types = [
    'medical',
    'food',
    'shelter',
    'clothing',
    'water',
    'other',
  ];
  final _urgencies = ['low', 'medium', 'high', 'critical'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.greenGradient,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Icon(Icons.arrow_back, color: AppTheme.white),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Aid',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Get the help you need',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ],
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
                      Text('Aid Type',
                          style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            items: _types
                                .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.capitalizeFirst ?? t),
                            ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedType = v!),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text('Urgency',
                          style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 10.w,
                        children: _urgencies.map((u) {
                          final isSelected = _selectedUrgency == u;
                          return ChoiceChip(
                            label: Text(u.capitalizeFirst ?? u),
                            selected: isSelected,
                            selectedColor:
                            _getUrgencyColor(u).withValues(alpha: 0.20),
                            onSelected: (_) =>
                                setState(() => _selectedUrgency = u),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20.h),
                      Text('Quantity',
                          style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Number of items/people',
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text('Description',
                          style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe what you need...',
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text('Address / Location',
                          style: theme.textTheme.headlineMedium),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Delivery address',
                        ),
                      ),
                      SizedBox(height: 30.h),
                      CustomElevatedButton(
                        label: 'Submit Request',
                        onPressed: _submitRequest,
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

  void _submitRequest() {
    final controller = Get.find<AidRequestController>();
    controller.submitRequest(
      type: _selectedType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      urgency: _selectedUrgency,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'critical':
        return AppTheme.red;
      case 'high':
        return AppTheme.orange;
      case 'medium':
        return AppTheme.primaryColor;
      default:
        return AppTheme.green;
    }
  }
}
