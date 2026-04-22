import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/game_record.dart';
import '../models/user_profile.dart';
import '../services/sudoku_engine.dart';

class GameController extends ChangeNotifier {
  SudokuEngine _engine = SudokuEngine();

  static const int maxLives = 5;

  UserProfile? _player;
  String _mode = 'offline'; // offline|online
  String _difficulty = 'easy';

  List<int> _givens = List<int>.filled(81, 0);
  List<int> _solution = List<int>.filled(81, 0);
  List<int> _current = List<int>.filled(81, 0);
  int? _selected;

  Timer? _timer;
  int _seconds = 0;
  /// null = đang chơi, true = thắng, false = thua (hết mạng)
  bool? _outcome;

  int _lives = maxLives;

  UserProfile? get player => _player;
  String get mode => _mode;
  String get difficulty => _difficulty;
  List<int> get givens => List.unmodifiable(_givens);
  List<int> get current => List.unmodifiable(_current);
  int? get selectedIndex => _selected;
  int get seconds => _seconds;
  int get lives => _lives;
  bool get isPlaying => _outcome == null;
  bool get hasWon => _outcome == true;
  bool get hasLost => _outcome == false;

  void setPlayer(UserProfile? user) {
    _player = user;
    notifyListeners();
  }

  void startNewGame({
    required String mode,
    required String difficulty,
    int? seed,
  }) {
    _mode = mode;
    _difficulty = difficulty;
    if (seed != null) {
      _engine = SudokuEngine(rand: Random(seed));
    } else {
      _engine = SudokuEngine();
    }
    final puzzle = _engine.generate(difficulty: difficulty);
    _givens = puzzle.givens;
    _solution = puzzle.solution;
    _current = List<int>.from(_givens);
    _selected = null;
    _seconds = 0;
    _outcome = null;
    _lives = maxLives;
    _startTimer();
    notifyListeners();
  }

  void select(int index) {
    _selected = index;
    notifyListeners();
  }

  void inputNumber(int value) {
    if (!isPlaying) return;
    final idx = _selected;
    if (idx == null) return;
    if (_givens[idx] != 0) return;
    if (value < 0 || value > 9) return;

    if (value != 0 && value != _solution[idx]) {
      _lives = (_lives - 1).clamp(0, maxLives);
      if (_lives <= 0) {
        _lives = 0;
        _outcome = false;
        _timer?.cancel();
      }
    }

    _current[idx] = value;
    notifyListeners();
  }

  void clearCell() {
    if (!isPlaying) return;
    final idx = _selected;
    if (idx == null) return;
    if (_givens[idx] != 0) return;
    _current[idx] = 0;
    notifyListeners();
  }

  /// Điền đúng một ô: ưu tiên ô người chơi điền sai, sau đó ô trống.
  /// Không trừ mạng.
  bool applyHint() {
    if (!isPlaying) return false;

    for (var i = 0; i < 81; i++) {
      if (_givens[i] != 0) continue;
      final v = _current[i];
      if (v != 0 && v != _solution[i]) {
        _current[i] = _solution[i];
        _selected = i;
        notifyListeners();
        return true;
      }
    }
    for (var i = 0; i < 81; i++) {
      if (_givens[i] != 0) continue;
      if (_current[i] == 0) {
        _current[i] = _solution[i];
        _selected = i;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool isFixed(int index) => _givens[index] != 0;

  bool isCorrectAt(int index) {
    final v = _current[index];
    if (v == 0) return true;
    return v == _solution[index];
  }

  bool checkFinished() {
    if (!isPlaying) return hasWon;
    for (var i = 0; i < 81; i++) {
      if (_current[i] == 0) return false;
      if (_current[i] != _solution[i]) return false;
    }
    _outcome = true;
    _timer?.cancel();
    notifyListeners();
    return true;
  }

  GameRecord buildRecord({required bool win}) {
    return GameRecord(
      id: const Uuid().v4(),
      playerName: _player?.username ?? 'Unknown',
      mode: _mode,
      difficulty: _difficulty,
      seconds: _seconds,
      win: win,
      createdAt: DateTime.now(),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

