import 'package:flutter/material.dart';
import 'package:safelink/features/preparedness/models/safety_guide_model.dart';

extension SafetyGuidePresentation on SafetyGuideModel {
  IconData get displayIcon {
    switch (iconKey) {
      case 'earthquake':
        return Icons.graphic_eq;
      case 'flood':
        return Icons.water_drop;
      case 'storm':
        return Icons.air;
      case 'fire':
        return Icons.local_fire_department;
      case 'landslide':
        return Icons.warning_amber;
      default:
        return Icons.info;
    }
  }

  List<Color> get displayGradientColors {
    switch (gradientKey) {
      case 'earthquake':
        return [const Color(0xFFEF4444), const Color(0xFFF97316)];
      case 'flood':
        return [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
      case 'storm':
        return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
      case 'fire':
        return [const Color(0xFFDC2626), const Color(0xFFF43F5E)];
      case 'landslide':
        return [const Color(0xFFF59E0B), const Color(0xFFEAB308)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF3B82F6)];
    }
  }
}
