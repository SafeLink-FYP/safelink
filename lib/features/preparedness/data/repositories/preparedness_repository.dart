import 'package:safelink/features/preparedness/services/preparedness_state_service.dart';
import 'package:safelink/features/preparedness/models/preparedness_model.dart';
import 'package:safelink/features/preparedness/presentation/screens/preparedness_catalog.dart';

class PreparednessRepository {
  final PreparednessStateService _stateService;

  PreparednessRepository(this._stateService);

  List<PreparednessCategory> buildCategories() {
    return PreparednessCatalog.build();
  }

  Future<void> hydrateCheckedState(List<PreparednessCategory> categories) async {
    final itemIds = categories
        .expand((category) => category.items.map((item) => item.id))
        .toList();
    final checkedMap = await _stateService.loadCheckedState(itemIds);

    for (final category in categories) {
      for (final item in category.items) {
        item.isChecked = checkedMap[item.id] ?? false;
      }
    }
  }

  Future<void> saveItemState(String itemId, bool isChecked) async {
    await _stateService.saveCheckedState(itemId, isChecked);
  }
}
