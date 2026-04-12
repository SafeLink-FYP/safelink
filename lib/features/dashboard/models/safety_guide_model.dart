import 'package:flutter/material.dart';

class SafetyTipSection {
  final String title;
  final List<String> tips;

  const SafetyTipSection({required this.title, required this.tips});
}

class SafetyGuideModel {
  final String id;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final String summary;
  final List<SafetyTipSection> sections;

  const SafetyGuideModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.summary,
    required this.sections,
  });
}
