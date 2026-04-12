import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/dashboard/models/s_o_s_request_model.dart';

class SOSService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<SOSRequestModel> createSOSRequest({
    required double latitude,
    required double longitude,
    required SOSType disasterType,
    String? address,
    String? description,
    String urgency = 'critical',
    int peopleCount = 1,
  }) async {
    final userId = _supabase.userId!;
    final data = await _supabase.sosRequests
        .insert({
          'user_id': userId,
          'disaster_type': disasterType.name,
          'description': description,
          'urgency': urgency,
          'status': 'pending',
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'people_count': peopleCount,
        })
        .select()
        .single();
    return SOSRequestModel.fromJson(data);
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
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SOSRequestModel.fromJson(data);
  }

  Future<void> cancelSOSRequest(String id) async {
    await _supabase.sosRequests.update({'status': 'cancelled'}).eq('id', id);
  }
}
