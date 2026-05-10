import 'package:flutter/material.dart';
import 'package:safelink/features/preparedness/models/preparedness_model.dart';

extension PreparednessCategoryPresentation on PreparednessCategory {
  IconData get displayIcon {
    switch (iconKey) {
      case 'water_drop':
        return Icons.water_drop;
      case 'favorite':
        return Icons.favorite;
      case 'flashlight':
        return Icons.flashlight_on;
      case 'smartphone':
        return Icons.smartphone;
      case 'description':
        return Icons.description;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.checklist;
    }
  }

  List<Color> get displayGradientColors {
    switch (gradientKey) {
      case 'water_food':
        return [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
      case 'first_aid':
        return [const Color(0xFFEF4444), const Color(0xFFF43F5E)];
      case 'tools':
        return [const Color(0xFFF59E0B), const Color(0xFFF97316)];
      case 'communication':
        return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
      case 'documents':
        return [const Color(0xFF10B981), const Color(0xFF22C55E)];
      case 'shelter':
        return [const Color(0xFF1E40AF), const Color(0xFF6366F1)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF3B82F6)];
    }
  }
}
