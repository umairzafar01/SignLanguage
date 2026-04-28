import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  static AppNotification fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        read: j['read'] as bool? ?? false,
      );
}

class NotificationProvider extends ChangeNotifier {
  static const _storageKey = 'app_notifications_v1';
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _items.clear();
      _items.addAll(list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> addNotification(AppNotification n) async {
    _items.insert(0, n);
    await _save();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0 && !_items[idx].read) {
      _items[idx].read = true;
      await _save();
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    var changed = false;
    for (final n in _items) {
      if (!n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (changed) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    _items.clear();
    await _save();
    notifyListeners();
  }
}
