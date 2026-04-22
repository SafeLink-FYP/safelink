import 'package:get/get.dart';
import 'package:safelink/features/cases/models/case_model.dart';
import 'package:safelink/features/cases/services/case_tracking_service.dart';

class CaseTrackingController extends GetxController {
  final CaseTrackingService _service = Get.find<CaseTrackingService>();

  final isLoading = false.obs;
  final cases = <CaseModel>[].obs;
  final activeFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final filteredCases = <CaseModel>[].obs;

  static const filters = ['All', 'In Progress', 'Pending', 'Completed'];

  @override
  void onInit() {
    super.onInit();

    everAll([cases, activeFilter, searchQuery], (_) {
      _applyFilters();
    });

    loadCases();
  }

  void _applyFilters() {
    filteredCases.value = cases.where((c) {
      if (activeFilter.value != 'All') {
        final filterLower = activeFilter.value.toLowerCase().replaceAll(
          ' ',
          '_',
        );
        if (c.status.toLowerCase().replaceAll(' ', '_') != filterLower) {
          return false;
        }
      }

      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return c.displayId.toLowerCase().contains(query) ||
            c.type.toLowerCase().contains(query) ||
            (c.location?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  }

  Future<void> loadCases() async {
    isLoading.value = true;
    try {
      cases.value = await _service.getMyCases();
      _applyFilters();
    } catch (e) {
      Get.log('Error loading cases: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int countByStatus(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');
    return cases
        .where(
          (c) => c.status.toLowerCase().replaceAll(' ', '_') == statusLower,
        )
        .length;
  }

  int get activeCount => countByStatus('active');
  int get inProgressCount => countByStatus('in_progress');
  int get pendingCount => countByStatus('pending');

  int get completedCount => cases
      .where(
        (c) =>
            c.status.toLowerCase() == 'completed' ||
            c.status.toLowerCase() == 'fulfilled' ||
            c.status.toLowerCase() == 'resolved',
      )
      .length;

  CaseModel? getCaseById(String id) {
    try {
      return cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
