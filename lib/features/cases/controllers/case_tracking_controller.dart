import 'package:get/get.dart';
import 'package:safelink/features/cases/models/case_model.dart';
import 'package:safelink/features/cases/services/case_tracking_service.dart';

class CaseTrackingController extends GetxController {
  final CaseTrackingService _service = Get.find<CaseTrackingService>();

  final isLoading = false.obs;
  final cases = <CaseModel>[].obs;
  // Empty string means "no filter" — show every case. A non-empty value
  // is the name of one of the buckets in [_bucketStatuses] and limits
  // the rendered list to cases whose status falls in that bucket.
  final activeFilter = ''.obs;
  final searchQuery = ''.obs;
  final filteredCases = <CaseModel>[].obs;

  /// The four mutually-exclusive, exhaustive buckets the case list is
  /// classified into. Statuses come from two sources
  /// (sos_requests / disaster_reports) and don't overlap — every
  /// status string produced by either table maps to exactly one
  /// bucket here, so the chip counts always sum to cases.length.
  ///
  ///   SOS   produces: pending, responded, resolved, cancelled
  ///   Report produces: pending, verified, dismissed
  static const _bucketStatuses = <String, Set<String>>{
    'Pending': {'pending'},
    'In Progress': {'responded', 'verified'},
    'Done': {'resolved', 'dismissed'},
    'Cancelled': {'cancelled'},
  };

  /// Names of the buckets in display order. Used by the view to render
  /// the four stat chips (which double as filter toggles).
  static const filters = ['Pending', 'In Progress', 'Done', 'Cancelled'];

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
      if (activeFilter.value.isNotEmpty) {
        final statuses = _bucketStatuses[activeFilter.value] ?? const {};
        if (!statuses.contains(c.status.toLowerCase())) {
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

  /// Toggles the bucket filter. Tapping the chip for the currently
  /// active bucket clears the filter (returns to the unfiltered view);
  /// tapping any other chip switches to that bucket.
  void toggleFilter(String bucket) {
    if (activeFilter.value == bucket) {
      activeFilter.value = '';
    } else {
      activeFilter.value = bucket;
    }
  }

  int _countInBucket(String bucket) {
    final statuses = _bucketStatuses[bucket] ?? const {};
    return cases
        .where((c) => statuses.contains(c.status.toLowerCase()))
        .length;
  }

  int get pendingCount => _countInBucket('Pending');
  int get inProgressCount => _countInBucket('In Progress');
  int get doneCount => _countInBucket('Done');
  int get cancelledCount => _countInBucket('Cancelled');

  CaseModel? getCaseById(String id) {
    try {
      return cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
