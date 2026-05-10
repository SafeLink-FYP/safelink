import 'package:get/get.dart';
import 'package:safelink/features/preparedness/data/repositories/preparedness_repository.dart';
import 'package:safelink/features/preparedness/models/preparedness_model.dart';

class PreparednessController extends GetxController {
  final PreparednessRepository _repository;

  PreparednessController({PreparednessRepository? repository})
      : _repository = repository ?? Get.find<PreparednessRepository>();

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
    categories.value = _repository.buildCategories();
  }

  Future<void> _loadCheckedState() async {
    await _repository.hydrateCheckedState(categories);
    categories.refresh();
  }

  Future<void> toggleItem(String categoryId, String itemId) async {
    for (final cat in categories) {
      if (cat.id == categoryId) {
        for (final item in cat.items) {
          if (item.id == itemId) {
            item.isChecked = !item.isChecked;
            await _repository.saveItemState(item.id, item.isChecked);
            break;
          }
        }
        break;
      }
    }
    categories.refresh();
  }
}

