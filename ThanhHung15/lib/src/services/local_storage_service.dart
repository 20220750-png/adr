import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_record.dart';
import '../models/user_profile.dart';
import 'history_file_io.dart' if (dart.library.html) 'history_file_stub.dart'
    as history_file;

class LocalStorageService {
  static const _kUserKey = 'user_profile_v1';
  static const _kTokenKey = 'auth_token_v1';
  /// Web + migrate: từng lưu lịch sử ở đây
  static const _kHistoryKey = 'game_history_v1';

  Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_kUserKey);
    if (raw == null || raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return UserProfile.fromJson(
      Map<String, Object?>.from(
        decoded.map((k, v) => MapEntry(k.toString(), v as Object?)),
      ),
    );
  }

  Future<void> saveUser(UserProfile? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_kUserKey);
      return;
    }
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
  }

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final t = prefs.getString(_kTokenKey);
    if (t == null || t.trim().isEmpty) return null;
    return t;
  }

  Future<void> saveToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.trim().isEmpty) {
      await prefs.remove(_kTokenKey);
      return;
    }
    await prefs.setString(_kTokenKey, token);
  }

  Future<List<GameRecord>> loadHistory() async {
    if (kIsWeb) {
      return _loadHistoryFromPrefs();
    }
    return _loadHistoryFileWithMigration();
  }

  Future<void> addHistory(GameRecord record) async {
    final history = await loadHistory();
    history.insert(0, record);
    await _persistHistory(history);
  }

  Future<void> clearHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kHistoryKey);
      return;
    }
    try {
      await history_file.deleteHistoryFile();
    } catch (e, st) {
      debugPrint('clearHistory file: $e\n$st');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistoryKey);
  }

  Future<List<GameRecord>> _loadHistoryFileWithMigration() async {
    try {
      final raw = await history_file.readHistoryFileContent();
      if (raw != null && raw.trim().isNotEmpty) {
        return _decodeHistoryJson(raw);
      }
    } catch (e, st) {
      debugPrint('loadHistory file error: $e\n$st');
    }

    final fromPrefs = await _loadHistoryFromPrefs();
    if (fromPrefs.isNotEmpty) {
      await _persistHistory(fromPrefs);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kHistoryKey);
    }
    return fromPrefs;
  }

  Future<void> _persistHistory(List<GameRecord> history) async {
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHistoryKey, encoded);
      return;
    }
    try {
      await history_file.writeHistoryFileContent(encoded);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kHistoryKey);
    } catch (e, st) {
      debugPrint('persistHistory file failed, fallback prefs: $e\n$st');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHistoryKey, encoded);
    }
  }

  Future<List<GameRecord>> _loadHistoryFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final raw = prefs.getString(_kHistoryKey);
      if (raw == null || raw.trim().isEmpty) return [];
      return _decodeHistoryJson(raw);
    } catch (e, st) {
      debugPrint('loadHistory prefs error: $e\n$st');
      return [];
    }
  }

  List<GameRecord> _decodeHistoryJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final out = <GameRecord>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final map = Map<String, Object?>.from(
        item.map((k, v) => MapEntry(k.toString(), v as Object?)),
      );
      try {
        out.add(GameRecord.fromJson(map));
      } catch (e, st) {
        debugPrint('skip bad GameRecord: $e\n$st');
      }
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }
}
