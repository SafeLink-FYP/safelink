import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/dashboard/models/aid_request_model.dart';
import 'package:get/get.dart';

class AidRequestService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<AidRequestModel> createAidRequest({
    required String aidType,
    required String description,
    required String urgency,
    int quantity = 1,
    int peopleAffected = 1,
    List<String> imageUrls = const [],
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final userId = _supabase.userId!;
    final data = await _supabase.aidRequests
        .insert({
          'user_id': userId,
          'aid_type': aidType,
          'description': description,
          'urgency': urgency,
          'status': 'pending',
          'quantity': quantity,
          'people_affected': peopleAffected,
          'image_urls': imageUrls,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        })
        .select()
        .single();
    return AidRequestModel.fromJson(data);
  }

  Future<List<AidRequestModel>> getMyAidRequests() async {
    final userId = _supabase.userId;
    if (userId == null) return [];
    final data = await _supabase.aidRequests
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => AidRequestModel.fromJson(e)).toList();
  }

  Future<void> cancelAidRequest(String id) async {
    await _supabase.aidRequests.update({'status': 'cancelled'}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getTimeline(String requestId) async {
    final data = await _supabase.aidRequestTimeline
        .select()
        .eq('request_id', requestId)
        .order('created_at', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
