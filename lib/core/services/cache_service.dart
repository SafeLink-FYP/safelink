import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safelink/features/profile/models/profile_model.dart';
import 'package:safelink/features/dashboard/models/emergency_contact_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();
  static CacheService get instance => _instance;

  late SharedPreferences _prefs;

  /// KEYS
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberedPasswordKey = 'remembered_password';
  static const String _cachedProfileKey = 'cached_profile';
  static const String _cachedContactsKey = 'cached_emergency_contacts';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _lastCacheTimeKey = 'last_cache_time';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// REMEMBER ME

  bool get isRememberMeEnabled => _prefs.getBool(_rememberMeKey) ?? false;

  String? get rememberedEmail => _prefs.getString(_rememberedEmailKey);
  String? get rememberedPassword => _prefs.getString(_rememberedPasswordKey);

  Future<void> saveRememberMe({
    required bool enabled,
    String? email,
    String? password,
  }) async {
    await _prefs.setBool(_rememberMeKey, enabled);
    if (enabled && email != null && password != null) {
      await _prefs.setString(_rememberedEmailKey, email);
      await _prefs.setString(_rememberedPasswordKey, password);
    } else {
      await _prefs.remove(_rememberedEmailKey);
      await _prefs.remove(_rememberedPasswordKey);
    }
  }

  Future<void> clearRememberMe() async {
    await _prefs.remove(_rememberMeKey);
    await _prefs.remove(_rememberedEmailKey);
    await _prefs.remove(_rememberedPasswordKey);
  }

  /// ONBOARDING

  bool get isOnboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }

  /// PROFILE CACHE

  Future<void> cacheProfile(ProfileModel profile) async {
    final json = jsonEncode(profile.toJson());
    await _prefs.setString(_cachedProfileKey, json);
    await _updateCacheTimestamp();
  }

  ProfileModel? getCachedProfile() {
    final json = _prefs.getString(_cachedProfileKey);
    if (json == null) return null;
    try {
      return ProfileModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProfileCache() async {
    await _prefs.remove(_cachedProfileKey);
  }

  /// EMERGENCY CONTACTS CACHE

  Future<void> cacheEmergencyContacts(
      List<EmergencyContactModel> contacts) async {
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await _prefs.setString(_cachedContactsKey, jsonEncode(jsonList));
    await _updateCacheTimestamp();
  }

  List<EmergencyContactModel> getCachedEmergencyContacts() {
    final json = _prefs.getString(_cachedContactsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => EmergencyContactModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearContactsCache() async {
    await _prefs.remove(_cachedContactsKey);
  }

  /// CACHE FRESHNESS

  DateTime? get lastCacheTime {
    final ms = _prefs.getInt(_lastCacheTimeKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isCacheStale {
    final last = lastCacheTime;
    if (last == null) return true;
    return DateTime.now().difference(last).inMinutes > 30;
  }

  Future<void> _updateCacheTimestamp() async {
    await _prefs.setInt(
        _lastCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// FULL CLEAR (ON SIGN-OUT)

  Future<void> clearAllUserData() async {
    await clearProfileCache();
    await clearContactsCache();
    await _prefs.remove(_lastCacheTimeKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
