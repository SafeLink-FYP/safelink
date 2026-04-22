class PreparednessItem {
  final String id;
  final String label;
  final String description;
  bool isChecked;

  PreparednessItem({
    required this.id,
    required this.label,
    required this.description,
    this.isChecked = false,
  });
}

class PreparednessCategory {
  final String id;
  final String title;
  final String iconKey;
  final String gradientKey;
  final List<PreparednessItem> items;

  const PreparednessCategory({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.gradientKey,
    required this.items,
  });

  int get checkedCount => items.where((i) => i.isChecked).length;

  int get totalCount => items.length;

  bool get isComplete => checkedCount == totalCount;
}
