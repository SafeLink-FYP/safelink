class SafetyTipSection {
  final String title;
  final List<String> tips;

  const SafetyTipSection({required this.title, required this.tips});
}

class SafetyGuideModel {
  final String id;
  final String title;
  final String iconKey;
  final String gradientKey;
  final String summary;
  final List<SafetyTipSection> sections;

  const SafetyGuideModel({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.gradientKey,
    required this.summary,
    required this.sections,
  });
}
