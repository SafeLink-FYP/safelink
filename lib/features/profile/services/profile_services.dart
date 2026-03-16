import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:safelink/features/dashboard/models/emergency_contact_model.dart';
import 'package:safelink/features/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safelink/core/services/supabase_service.dart';

class ProfileService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<ProfileModel?> getProfile() async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.profiles
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> updates) async {
    final userId = _supabase.userId!;
    final data = await _supabase.profiles
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> uploadAvatar(Uint8List fileBytes) async {
    final userId = _supabase.userId!;
    final path = 'avatars/$userId.jpg';

    await _supabase.storage.from('avatars').uploadBinary(
      path,
      fileBytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    );

    final url = _supabase.storage.from('avatars').getPublicUrl(path);

    final data = await _supabase.profiles
        .update({'avatar_url': url})
        .eq('id', userId)
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    final userId = _supabase.userId;
    if (userId == null) return [];
    final data = await _supabase.emergencyContacts
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (data as List)
        .map((e) => EmergencyContactModel.fromJson(e))
        .toList();
  }

  Future<EmergencyContactModel> addEmergencyContact(
      Map<String, dynamic> contact,
      ) async {
    contact['user_id'] = _supabase.userId!;
    final data = await _supabase.emergencyContacts
        .insert(contact)
        .select()
        .single();
    return EmergencyContactModel.fromJson(data);
  }

  Future<void> deleteEmergencyContact(String id) async {
    await _supabase.emergencyContacts.delete().eq('id', id);
  }
}