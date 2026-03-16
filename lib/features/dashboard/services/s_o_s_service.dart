import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/dashboard/models/s_o_s_request_model.dart';

class SOSService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<SOSRequestModel> createSOSRequest({
    required double latitude,
    required double longitude,
    required String type,
    String? address,
    String? description,
    String urgency = 'critical',
    int peopleCount = 1,
  }) async {
    try {
      final userId = _supabase.userId!;

      final data = await _supabase.sosRequests
          .insert({
            'user_id': userId,
            'latitude': latitude,
            'longitude': longitude,
            'type': type,
            'address': address,
            'description': description,
            'urgency': urgency,
            'status': 'pending',
            'people_count': peopleCount,
          })
          .select()
          .single();
      return SOSRequestModel.fromJson(data);
    } catch (e) {
      print("SOS ERROR: $e");
      rethrow;
    }
  }

  Future<List<SOSRequestModel>> getMySOSRequests() async {
    final userId = _supabase.userId;
    if (userId == null) return [];
    final data = await _supabase.sosRequests
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => SOSRequestModel.fromJson(e)).toList();
  }

  Future<SOSRequestModel?> getActiveSOSRequest() async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.sosRequests
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['pending', 'responded'])
        .order('created_at', ascending: false)
        .maybeSingle();
    if (data == null) return null;
    return SOSRequestModel.fromJson(data);
  }

  Future<void> cancelSOSRequest(String id) async {
    await _supabase.sosRequests.update({'status': 'cancelled'}).eq('id', id);
  }
}
