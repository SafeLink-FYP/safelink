import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  static SupabaseService get instance => _instance;

  final SupabaseClient client = Supabase.instance.client;

  GoTrueClient get auth => client.auth;
  User? get currentUser => client.auth.currentUser;
  String? get userId => currentUser?.id;
  bool get isLoggedIn => currentUser != null;

  // BASE TABLES
  SupabaseQueryBuilder get profiles => client.from('profiles');
  SupabaseQueryBuilder get appRegistrations => client.from('app_registrations');

  // MODULE PROFILE TABLES
  SupabaseQueryBuilder get citizenProfiles => client.from('citizen_profiles');
  SupabaseQueryBuilder get aidWorkerProfiles =>
      client.from('aid_worker_profiles');
  SupabaseQueryBuilder get govOfficialProfiles =>
      client.from('gov_official_profiles');
  SupabaseQueryBuilder get aidOrganizations =>
      client.from('aid_organizations');

  // FEATURE TABLES
  SupabaseQueryBuilder get emergencyContacts =>
      client.from('emergency_contacts');
  SupabaseQueryBuilder get alerts => client.from('alerts');
  SupabaseQueryBuilder get sosRequests => client.from('sos_requests');
  SupabaseQueryBuilder get disasterReports => client.from('disaster_reports');
  SupabaseQueryBuilder get aidRequests => client.from('aid_requests');
  SupabaseQueryBuilder get aidRequestTimeline =>
      client.from('aid_request_timeline');
  SupabaseQueryBuilder get teams => client.from('teams');
  SupabaseQueryBuilder get teamMembers => client.from('team_members');
  SupabaseQueryBuilder get resources => client.from('resources');
  SupabaseQueryBuilder get resourceAllocations =>
      client.from('resource_allocations');

  // COMMUNICATION TABLES
  SupabaseQueryBuilder get notifications => client.from('notifications');
  SupabaseQueryBuilder get feedback => client.from('feedback');

  // STORAGE
  SupabaseStorageClient get storage => client.storage;

  // RPC CALLS
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }

  // ROLE VERIFICATION
  Future<bool> verifyRoleAccess(String role) async {
    if (userId == null) return false;
    final result = await appRegistrations
        .select('id')
        .eq('user_id', userId!)
        .eq('role', role)
        .maybeSingle();
    return result != null;
  }
}
