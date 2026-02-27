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

  SupabaseQueryBuilder get profiles => client.from('profiles');
  SupabaseQueryBuilder get emergencyContacts =>
      client.from('emergency_contacts');
  SupabaseQueryBuilder get alerts => client.from('alerts');
  SupabaseQueryBuilder get sosRequests => client.from('sos_requests');
  SupabaseQueryBuilder get disasterReports => client.from('disaster_reports');
  SupabaseQueryBuilder get aidRequests => client.from('aid_requests');
  SupabaseQueryBuilder get shelters => client.from('shelters');
  SupabaseQueryBuilder get chatSessions => client.from('chat_sessions');
  SupabaseQueryBuilder get chatMessages => client.from('chat_messages');
  SupabaseQueryBuilder get notifications => client.from('notifications');
  SupabaseQueryBuilder get feedback => client.from('feedback');
  SupabaseStorageClient get storage => client.storage;

  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
}
