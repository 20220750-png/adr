import 'package:flutter/foundation.dart';
import 'dart:async';

import '../controllers/auth_controller.dart';
import '../services/online_api_service.dart';

class OnlineMatchController extends ChangeNotifier {
  final OnlineApiService onlineApi;
  AuthController? _auth;

  OnlineMatchController({required this.onlineApi});

  bool _finding = false;
  String? _error;

  String? _roomCode;
  String? _opponent;
  int? _seed;
  String? _difficulty;
  String _status = 'idle'; // idle|finding|waiting|matched|finished
  bool? _youWin;
  Timer? _pollTimer;
  Timer? _heartbeatTimer;
  int? _opponentLives;
  List<int>? _opponentGrid;

  bool get isFinding => _finding;
  String? get error => _error;
  String? get roomCode => _roomCode;
  String? get opponent => _opponent;
  int? get seed => _seed;
  String? get roomDifficulty => _difficulty;
  String get status => _status;
  bool? get youWin => _youWin;
  int? get opponentLives => _opponentLives;
  List<int>? get opponentGrid => _opponentGrid;

  void setAuth(AuthController auth) {
    _auth = auth;
  }

  Future<void> findRandomRoom({required String difficulty}) async {
    final token = _auth?.token;
    if (token == null) {
      _error = 'Bạn cần đăng nhập online để thi đấu.';
      notifyListeners();
      return;
    }

    _finding = true;
    _status = 'finding';
    _error = null;
    _roomCode = null;
    _opponent = null;
    _seed = null;
    _difficulty = null;
    _youWin = null;
    _opponentLives = null;
    _opponentGrid = null;
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    notifyListeners();

    try {
      final json = await onlineApi.randomRoom(token: token, difficulty: difficulty);
      _roomCode = (json['code'] as String?)?.toUpperCase();
      _opponent = json['opponent'] as String?;
      _seed = (json['seed'] as num?)?.toInt();
      _difficulty = json['difficulty'] as String? ?? difficulty;
      final status = json['status'] as String?;
      _opponentLives = (json['opponentLives'] as num?)?.toInt();
      _opponentGrid = _parseGrid(json['opponentGrid'] as String?);
      if (_roomCode == null || _seed == null) {
        throw Exception('Không nhận được thông tin phòng');
      }

      if (status == 'matched' && _opponent != null) {
        _status = 'matched';
        _startPolling(); // tiếp tục poll để lấy tiến độ đối thủ
        _startHeartbeat();
        return;
      }

      _status = 'waiting';
      notifyListeners();
      _startPolling();
      _startHeartbeat();
    } catch (e) {
      _error = e.toString();
      _status = 'idle';
    } finally {
      _finding = false;
      notifyListeners();
    }
  }

  Future<void> joinByCode({required String code}) async {
    final token = _auth?.token;
    if (token == null) {
      _error = 'Bạn cần đăng nhập online để vào phòng.';
      notifyListeners();
      return;
    }

    _finding = true;
    _status = 'finding';
    _error = null;
    _roomCode = null;
    _opponent = null;
    _seed = null;
    _difficulty = null;
    _youWin = null;
    _opponentLives = null;
    _opponentGrid = null;
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    notifyListeners();

    try {
      final json = await onlineApi.joinRoom(token: token, code: code.toUpperCase());
      _roomCode = (json['code'] as String?)?.toUpperCase();
      _opponent = json['opponent'] as String?;
      _seed = (json['seed'] as num?)?.toInt();
      _difficulty = json['difficulty'] as String?;
      final status = json['status'] as String?;
      _opponentLives = (json['opponentLives'] as num?)?.toInt();
      _opponentGrid = _parseGrid(json['opponentGrid'] as String?);
      if (_roomCode == null || _seed == null) {
        throw Exception('Không nhận được thông tin phòng');
      }
      if (status == 'matched' && _opponent != null) {
        _status = 'matched';
        _startPolling(); // tiếp tục poll để lấy tiến độ đối thủ
        _startHeartbeat();
        return;
      }

      _status = 'waiting';
      notifyListeners();
      _startPolling();
      _startHeartbeat();
    } catch (e) {
      _error = e.toString();
      _status = 'idle';
    } finally {
      _finding = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    final token = _auth?.token;
    final code = _roomCode;
    if (token == null || code == null) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final m = await onlineApi.getRoom(token: token, code: code);
        _opponent = m['opponent'] as String?;
        _seed = (m['seed'] as num?)?.toInt() ?? _seed;
        _difficulty = m['difficulty'] as String? ?? _difficulty;
        final st = m['status'] as String?;
        _opponentLives = (m['opponentLives'] as num?)?.toInt() ?? _opponentLives;
        _opponentGrid = _parseGrid(m['opponentGrid'] as String?) ?? _opponentGrid;

        if (st == 'finished') {
          _status = 'finished';
          _youWin = m['youWin'] as bool?;
          _pollTimer?.cancel();
        } else if (st == 'matched') {
          _status = 'matched';
        } else {
          _status = 'waiting';
        }
        notifyListeners();
      } catch (_) {
        // giữ im lặng để UI ổn định
      }
    });
  }

  void _startHeartbeat() {
    final token = _auth?.token;
    final code = _roomCode;
    if (token == null || code == null) return;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await onlineApi.heartbeatRoom(
          token: token,
          code: code,
        );
      } catch (_) {}
    });
  }

  Future<void> submit({
    required int seconds,
    required bool finished,
    List<int>? grid,
    int? lives,
  }) async {
    final token = _auth?.token;
    final code = _roomCode;
    if (token == null || code == null) return;

    try {
      final json = await onlineApi.submitRoom(
        token: token,
        code: code,
        seconds: seconds,
        finished: finished,
        grid: grid != null ? _encodeGrid(grid) : null,
        lives: lives,
      );
      final status = json['status'] as String?;
      if (status == 'finished') {
        _status = 'finished';
        _youWin = json['youWin'] as bool?;
        _pollTimer?.cancel();
      }
      _opponentLives = (json['opponentLives'] as num?)?.toInt() ?? _opponentLives;
      _opponentGrid = _parseGrid(json['opponentGrid'] as String?) ?? _opponentGrid;
      notifyListeners();
    } catch (_) {
      // ignore to keep game stable
    }
  }

  void reset() {
    _finding = false;
    _error = null;
    _roomCode = null;
    _opponent = null;
    _seed = null;
    _difficulty = null;
    _status = 'idle';
    _youWin = null;
    _opponentLives = null;
    _opponentGrid = null;
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    notifyListeners();
  }

  Future<void> leave() async {
    final token = _auth?.token;
    final code = _roomCode;
    if (token == null || code == null) {
      reset();
      return;
    }
    try {
      await onlineApi.leaveRoom(token: token, code: code);
    } catch (_) {
      // ignore
    } finally {
      reset();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  String _encodeGrid(List<int> grid) {
    final b = StringBuffer();
    for (final v in grid) {
      b.write(v.clamp(0, 9));
    }
    return b.toString();
  }

  List<int>? _parseGrid(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.length != 81) return null;
    final out = <int>[];
    for (var i = 0; i < 81; i++) {
      final codeUnit = s.codeUnitAt(i);
      final n = codeUnit - 48;
      if (n < 0 || n > 9) return null;
      out.add(n);
    }
    return out;
  }
}

