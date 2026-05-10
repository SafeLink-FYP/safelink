import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/aid/models/disaster_report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterReportService extends GetxService {
  final _supabase = SupabaseService.instance;

  static const String _bucket = 'report-images';

  Future<DisasterReportModel> createReport({
    required String title,
    required String description,
    required String disasterType,
    required double latitude,
    required double longitude,
    String severity = 'high',
    String? address,
    List<String> imageUrls = const [],
  }) async {
    final userId = _supabase.userId!;
    final data = await _supabase.disasterReports
        .insert({
          'user_id': userId,
          'title': title,
          'description': description,
          'disaster_type': disasterType,
          'severity': severity,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'image_urls': imageUrls,
          'status': 'pending',
        })
        .select()
        .single();
    return DisasterReportModel.fromJson(data);
  }

  Future<List<DisasterReportModel>> getMyReports() async {
    final userId = _supabase.userId;
    if (userId == null) return [];
    final data = await _supabase.disasterReports
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => DisasterReportModel.fromJson(e)).toList();
  }

  Future<String> uploadReportImage(Uint8List bytes, String filename) async {
    final userId = _supabase.userId!;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$filename';
    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return await _supabase.storage
        .from(_bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 365);
  }
}
