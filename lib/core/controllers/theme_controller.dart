import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();
  static ThemeController get instance => _instance;

  final _themeMode = ThemeMode.light.obs;
  final _isDarkMode = false.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _isDarkMode.value;

  Future<void> init() async {
    await _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _isDarkMode.value = isDark;
    _themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    _themeMode.value = _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeToPrefs();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    _isDarkMode.value = mode == ThemeMode.dark;
    await _saveThemeToPrefs();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode.value);
  }
}
