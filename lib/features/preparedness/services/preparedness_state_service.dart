import 'package:shared_preferences/shared_preferences.dart';

class PreparednessStateService {
  static const String _keyPrefix = 'prep_';

  Future<Map<String, bool>> loadCheckedState(List<String> itemIds) async {
    final prefs = await SharedPreferences.getInstance();
    final state = <String, bool>{};
    for (final id in itemIds) {
      state[id] = prefs.getBool('$_keyPrefix$id') ?? false;
    }
    return state;
  }

  Future<void> saveCheckedState(String itemId, bool isChecked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$itemId', isChecked);
  }
}
