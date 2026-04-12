import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/dashboard/models/alert_model.dart';

class AlertService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<List<AlertModel>> getActiveAlerts() async {
    final data = await _supabase.alerts
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  Future<List<AlertModel>> getAllAlerts() async {
    final data = await _supabase.alerts.select().order(
      'created_at',
      ascending: false,
    );
    return (data as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  Future<AlertModel?> getAlertById(String id) async {
    final data = await _supabase.alerts.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return AlertModel.fromJson(data);
  }

  Future<List<AlertModel>> getAlertsForLocation(
    double latitude,
    double longitude,
  ) async {
    final data = await _supabase.rpc(
      'get_active_alerts_for_location',
      params: {'p_lat': latitude, 'p_lng': longitude},
    );
    if (data == null) return [];
    return (data as List).map((e) => AlertModel.fromJson(e)).toList();
  }
}
