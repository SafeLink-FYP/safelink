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

  // FEATURE TABLES
  SupabaseQueryBuilder get emergencyContacts =>
      client.from('emergency_contacts');
  SupabaseQueryBuilder get alerts => client.from('alerts');
  SupabaseQueryBuilder get sosRequests => client.from('sos_requests');
  SupabaseQueryBuilder get disasterReports => client.from('disaster_reports');

  // COMMUNICATION TABLES
  SupabaseQueryBuilder get notifications => client.from('notifications');

  // STORAGE
  SupabaseStorageClient get storage => client.storage;

  // RPC CALLS
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
}
