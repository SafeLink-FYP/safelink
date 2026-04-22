import 'package:safelink/features/preparedness/models/preparedness_model.dart';

class PreparednessCatalog {
  static List<PreparednessCategory> build() {
    return [
      PreparednessCategory(
        id: 'water-food',
        title: 'Water & Food',
        iconKey: 'water_drop',
        gradientKey: 'water_food',
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
        iconKey: 'favorite',
        gradientKey: 'first_aid',
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
        iconKey: 'flashlight',
        gradientKey: 'tools',
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
        iconKey: 'smartphone',
        gradientKey: 'communication',
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
        iconKey: 'description',
        gradientKey: 'documents',
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
        iconKey: 'shield',
        gradientKey: 'shelter',
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
}
