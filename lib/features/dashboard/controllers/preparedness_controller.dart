import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safelink/features/dashboard/models/preparedness_model.dart';

class PreparednessController extends GetxController {
  final categories = <PreparednessCategory>[].obs;

  int get totalItems => categories.fold(0, (sum, cat) => sum + cat.totalCount);

  int get checkedItems =>
      categories.fold(0, (sum, cat) => sum + cat.checkedCount);

  int get progressPercent =>
      totalItems > 0 ? ((checkedItems / totalItems) * 100).round() : 0;

  @override
  void onInit() {
    super.onInit();
    _initCategories();
    _loadCheckedState();
  }

  void _initCategories() {
    categories.value = [
      PreparednessCategory(
        id: 'water-food',
        title: 'Water & Food',
        icon: Icons.water_drop,
        gradientColors: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
        items: [
          PreparednessItem(
            id: 'w1',
            label: 'Water Supply',
            description: '1 gallon per person per day for 3 days',
          ),
          PreparednessItem(
            id: 'w2',
            label: 'Non-perishable Food',
            description: '3-day supply of canned/dried food',
          ),
          PreparednessItem(
            id: 'w3',
            label: 'Can Opener',
            description: 'Manual can opener for canned food',
          ),
          PreparednessItem(
            id: 'w4',
            label: 'Water Purification',
            description: 'Tablets or portable filter',
          ),
        ],
      ),
      PreparednessCategory(
        id: 'first-aid',
        title: 'First Aid & Medical',
        icon: Icons.favorite,
        gradientColors: [const Color(0xFFEF4444), const Color(0xFFF43F5E)],
        items: [
          PreparednessItem(
            id: 'm1',
            label: 'First Aid Kit',
            description: 'Bandages, antiseptic, pain relievers',
          ),
          PreparednessItem(
            id: 'm2',
            label: 'Prescription Medicines',
            description: '7-day supply of regular medications',
          ),
          PreparednessItem(
            id: 'm3',
            label: 'Face Masks',
            description: 'N95 or surgical masks',
          ),
          PreparednessItem(
            id: 'm4',
            label: 'Hand Sanitizer',
            description: 'Alcohol-based sanitizer',
          ),
        ],
      ),
      PreparednessCategory(
        id: 'tools',
        title: 'Tools & Equipment',
        icon: Icons.flashlight_on,
        gradientColors: [const Color(0xFFF59E0B), const Color(0xFFF97316)],
        items: [
          PreparednessItem(
            id: 't1',
            label: 'Flashlight',
            description: 'Battery or hand-crank flashlight',
          ),
          PreparednessItem(
            id: 't2',
            label: 'Extra Batteries',
            description: 'For flashlight and radio',
          ),
          PreparednessItem(
            id: 't3',
            label: 'Whistle',
            description: 'To signal for help',
          ),
          PreparednessItem(
            id: 't4',
            label: 'Multi-tool/Knife',
            description: 'Swiss army knife or multi-tool',
          ),
          PreparednessItem(
            id: 't5',
            label: 'Dust Masks',
            description: 'For filtering contaminated air',
          ),
        ],
      ),
      PreparednessCategory(
        id: 'communication',
        title: 'Communication',
        icon: Icons.smartphone,
        gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
        items: [
          PreparednessItem(
            id: 'c1',
            label: 'Battery Radio',
            description: 'NOAA weather radio or AM/FM',
          ),
          PreparednessItem(
            id: 'c2',
            label: 'Phone Charger',
            description: 'Portable power bank (fully charged)',
          ),
          PreparednessItem(
            id: 'c3',
            label: 'Emergency Contacts',
            description: 'Written list of important numbers',
          ),
          PreparednessItem(
            id: 'c4',
            label: 'SafeLink App Updated',
            description: 'Latest version with offline maps',
          ),
        ],
      ),
      PreparednessCategory(
        id: 'documents',
        title: 'Important Documents',
        icon: Icons.description,
        gradientColors: [const Color(0xFF10B981), const Color(0xFF22C55E)],
        items: [
          PreparednessItem(
            id: 'd1',
            label: 'CNIC Copies',
            description: 'Photocopies of all family CNICs',
          ),
          PreparednessItem(
            id: 'd2',
            label: 'Insurance Documents',
            description: 'Property and health insurance',
          ),
          PreparednessItem(
            id: 'd3',
            label: 'Bank Details',
            description: 'Account numbers and emergency cash',
          ),
          PreparednessItem(
            id: 'd4',
            label: 'Medical Records',
            description: 'Important medical history',
          ),
        ],
      ),
      PreparednessCategory(
        id: 'shelter',
        title: 'Shelter & Warmth',
        icon: Icons.shield,
        gradientColors: [const Color(0xFF1E40AF), const Color(0xFF6366F1)],
        items: [
          PreparednessItem(
            id: 's1',
            label: 'Blankets/Sleeping Bags',
            description: 'One per family member',
          ),
          PreparednessItem(
            id: 's2',
            label: 'Warm Clothing',
            description: 'Change of clothes for each person',
          ),
          PreparednessItem(
            id: 's3',
            label: 'Plastic Sheeting',
            description: 'For emergency shelter',
          ),
          PreparednessItem(
            id: 's4',
            label: 'Matches/Lighter',
            description: 'In waterproof container',
          ),
        ],
      ),
    ];
  }

  Future<void> _loadCheckedState() async {
    final prefs = await SharedPreferences.getInstance();
    for (final cat in categories) {
      for (final item in cat.items) {
        item.isChecked = prefs.getBool('prep_${item.id}') ?? false;
      }
    }
    categories.refresh();
  }

  Future<void> toggleItem(String categoryId, String itemId) async {
    for (final cat in categories) {
      if (cat.id == categoryId) {
        for (final item in cat.items) {
          if (item.id == itemId) {
            item.isChecked = !item.isChecked;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('prep_${item.id}', item.isChecked);
            break;
          }
        }
        break;
      }
    }
    categories.refresh();
  }
}
