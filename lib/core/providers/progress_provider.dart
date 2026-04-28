import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressProvider extends ChangeNotifier {
  static const _localStorageKey = 'user_progress_local';
  static const _moduleDefaults = <String, double>{
    'Sign to Text': 0.1,
    'Text to Sign': 0.1,
    'Speech to Text': 0.1,
    'AI Dictionary': 0.1,
  };

  int _translations = 0;
  int _dayStreak = 0;
  int _savedSigns = 0;
  Map<String, double> _moduleProgress = Map<String, double>.from(_moduleDefaults);
  List<double> _weeklyActivity = List<double>.filled(7, 0.0);
  DateTime? _lastActiveAt;
  String? _userId;
  bool _loading = true;
  bool _hasLoaded = false;

  int get translations => _translations;
  int get dayStreak => _dayStreak;
  int get savedSigns => _savedSigns;
  bool get isLoading => _loading;
  Map<String, double> get moduleProgress => _moduleProgress;
  List<double> get weeklyActivity => _weeklyActivity;

  Future<void> initializeForUser(String? userId) async {
    if (_hasLoaded && _userId == userId) return;
    _loading = true;
    notifyListeners();
    _userId = userId;

    if (userId == null) {
      await _loadLocal();
      _loading = false;
      _hasLoaded = true;
      notifyListeners();
      return;
    }

    await _loadFromCloudOrLocalFallback(userId);
    _loading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> recordTextToSignTranslation({required int characters}) async {
    if (characters <= 0) return;
    _translations += 1;
    _increaseModuleProgress('Text to Sign', (characters / 120).clamp(0.02, 0.12));
    _recordDailyActivity((characters / 150).clamp(0.03, 0.2));
    _touchStreak();
    await _persist();
  }

  Future<void> recordSignToTextTranslation({required int words}) async {
    if (words <= 0) return;
    _translations += 1;
    _increaseModuleProgress('Sign to Text', (words / 40).clamp(0.02, 0.12));
    _recordDailyActivity((words / 60).clamp(0.03, 0.2));
    _touchStreak();
    await _persist();
  }

  Future<void> recordDictionaryLookup() async {
    _increaseModuleProgress('AI Dictionary', 0.02);
    _recordDailyActivity(0.02);
    _touchStreak();
    await _persist();
  }

  Future<void> setSavedSignsCount(int count) async {
    _savedSigns = count < 0 ? 0 : count;
    await _persist();
  }

  Future<void> recordSpeechToTextUsage({required int words}) async {
    _increaseModuleProgress('Speech to Text', (words / 80).clamp(0.02, 0.12));
    _recordDailyActivity((words / 120).clamp(0.03, 0.2));
    _touchStreak();
    await _persist();
  }

  List<String> aiSuggestions() {
    final weakest = _moduleProgress.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final output = <String>[];
    for (final entry in weakest.take(2)) {
      switch (entry.key) {
        case 'Text to Sign':
          output.add('Practice Text to Sign with 3 short sentences today.');
          break;
        case 'Speech to Text':
          output.add('Try 2 voice prompts to improve speech recognition confidence.');
          break;
        case 'AI Dictionary':
          output.add('Explore 5 new dictionary words and mark favorites.');
          break;
        case 'Sign to Text':
          output.add('Complete one Sign to Text practice session.');
          break;
      }
    }
    if (output.isEmpty) {
      output.add('Keep a 7-day streak by completing one translation today.');
    }
    return output;
  }

  double achievementProgress(int target) {
    if (target <= 0) return 0;
    return (_translations / target).clamp(0.0, 1.0);
  }

  void _increaseModuleProgress(String module, double amount) {
    final current = _moduleProgress[module] ?? 0.0;
    _moduleProgress[module] = (current + amount).clamp(0.0, 1.0);
  }

  void _recordDailyActivity(double amount) {
    final index = DateTime.now().weekday - 1;
    final current = _weeklyActivity[index];
    _weeklyActivity[index] = (current + amount).clamp(0.0, 1.0);
  }

  void _touchStreak() {
    final now = DateTime.now();
    if (_lastActiveAt == null) {
      _dayStreak = 1;
    } else {
      final lastDate = DateTime(_lastActiveAt!.year, _lastActiveAt!.month, _lastActiveAt!.day);
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(lastDate).inDays;
      if (difference == 1) {
        _dayStreak += 1;
      } else if (difference > 1) {
        _dayStreak = 1;
      }
    }
    _lastActiveAt = now;
  }

  Future<void> _loadFromCloudOrLocalFallback(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        await _loadLocal();
        await _persistCloud();
        return;
      }
      _applyMap(doc.data()!);
    } catch (_) {
      await _loadLocal();
    }
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKeyForCurrentUser());
    if (raw == null || raw.isEmpty) {
      _resetDefaults();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _applyMap(decoded);
    } catch (_) {
      _resetDefaults();
    }
  }

  Future<void> _persist() async {
    notifyListeners();
    await _persistLocal();
    if (_userId != null) {
      await _persistCloud();
    }
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeyForCurrentUser(), jsonEncode(_toMap()));
  }

  Future<void> _persistCloud() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(_toMap(), SetOptions(merge: true));
    } catch (_) {
      // Keep local state as source of truth when offline/unconfigured.
    }
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'translations': _translations,
      'dayStreak': _dayStreak,
      'savedSigns': _savedSigns,
      'moduleProgress': _moduleProgress,
      'weeklyActivity': _weeklyActivity,
      'lastActiveAt': _lastActiveAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  void _applyMap(Map<String, dynamic> data) {
    _translations = (data['translations'] as num?)?.toInt() ?? 0;
    _dayStreak = (data['dayStreak'] as num?)?.toInt() ?? 0;
    _savedSigns = (data['savedSigns'] as num?)?.toInt() ?? 0;

    final modules = data['moduleProgress'];
    _moduleProgress = Map<String, double>.from(_moduleDefaults);
    if (modules is Map<String, dynamic>) {
      modules.forEach((key, value) {
        _moduleProgress[key] = ((value as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
      });
    }

    final weekly = data['weeklyActivity'];
    _weeklyActivity = List<double>.filled(7, 0.0);
    if (weekly is List) {
      for (var i = 0; i < weekly.length && i < 7; i++) {
        _weeklyActivity[i] = ((weekly[i] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
      }
    }

    final lastActiveAtRaw = data['lastActiveAt'];
    if (lastActiveAtRaw is String && lastActiveAtRaw.isNotEmpty) {
      _lastActiveAt = DateTime.tryParse(lastActiveAtRaw);
    } else {
      _lastActiveAt = null;
    }
  }

  void _resetDefaults() {
    _translations = 0;
    _dayStreak = 0;
    _savedSigns = 0;
    _moduleProgress = Map<String, double>.from(_moduleDefaults);
    _weeklyActivity = List<double>.filled(7, 0.0);
    _lastActiveAt = null;
  }

  String _storageKeyForCurrentUser() {
    final uid = _userId;
    if (uid == null || uid.isEmpty) return _localStorageKey;
    return '${_localStorageKey}_$uid';
  }
}
