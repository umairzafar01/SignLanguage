import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider extends ChangeNotifier {
  static const _themeKey = 'pref_theme_mode';
  static const _aiSuggestionsKey = 'pref_ai_suggestions';
  static const _notificationsKey = 'pref_notifications';
  static const _signLanguageKey = 'pref_sign_language';
  static const _migrationKey = 'pref_migration_v2'; // light-theme migration

  ThemeMode _themeMode = ThemeMode.light; // default: light
  bool _aiSuggestions = true;
  bool _notifications = true;
  String _signLanguage = 'ASL (American)';

  ThemeMode get themeMode => _themeMode;
  bool get aiSuggestions => _aiSuggestions;
  bool get notifications => _notifications;
  String get signLanguage => _signLanguage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Migration: reset theme to light if user never explicitly chose one
    //    (clears the old dark default that was stored by the previous build)
    final migrated = prefs.getBool(_migrationKey) ?? false;
    if (!migrated) {
      await prefs.remove(_themeKey); // wipe old dark default
      await prefs.setBool(_migrationKey, true);
    }

    final stored = prefs.getString(_themeKey);
    if (stored != null) {
      _themeMode = _decodeTheme(stored);
    }
    _aiSuggestions = prefs.getBool(_aiSuggestionsKey) ?? true;
    _notifications = prefs.getBool(_notificationsKey) ?? true;
    _signLanguage = prefs.getString(_signLanguageKey) ?? 'ASL (American)';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _encodeTheme(mode));
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(next);
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> setAiSuggestions(bool value) async {
    _aiSuggestions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiSuggestionsKey, value);
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> setSignLanguage(String value) async {
    _signLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signLanguageKey, value);
  }

  ThemeMode _decodeTheme(String raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  String _encodeTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}
