import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider extends ChangeNotifier {
  static const _themeKey = 'pref_theme_mode';
  static const _aiSuggestionsKey = 'pref_ai_suggestions';
  static const _notificationsKey = 'pref_notifications';
  static const _signLanguageKey = 'pref_sign_language';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _aiSuggestions = true;
  bool _notifications = true;
  String _signLanguage = 'ASL (American)';

  ThemeMode get themeMode => _themeMode;
  bool get aiSuggestions => _aiSuggestions;
  bool get notifications => _notifications;
  String get signLanguage => _signLanguage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _decodeTheme(prefs.getString(_themeKey));
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

  ThemeMode _decodeTheme(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String _encodeTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
