import 'package:flutter/material.dart';
import 'package:safelink/features/cases/models/case_model.dart';

extension CasePresentationMapper on CaseModel {
  IconData get displayIcon {
    switch (type.toLowerCase()) {
      case 'medical aid':
      case 'medical':
        return Icons.favorite;
      case 'food supply':
      case 'food':
        return Icons.inventory_2;
      case 'evacuation':
        return Icons.local_shipping;
      case 'shelter request':
      case 'shelter':
        return Icons.shield;
      case 'water':
        return Icons.water_drop;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.shield;
    }
  }

  Color get displayStatusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF3B82F6);
      case 'in_progress':
      case 'in progress':
        return const Color(0xFFF59E0B);
      case 'completed':
      case 'fulfilled':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFF6B7280);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color get displayPriorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF22C55E);
    }
  }
}
