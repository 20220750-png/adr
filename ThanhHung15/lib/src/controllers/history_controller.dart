import 'package:flutter/foundation.dart';

import '../models/game_record.dart';
import '../services/local_storage_service.dart';

class HistoryController extends ChangeNotifier {
  final LocalStorageService localStorage;

  HistoryController({required this.localStorage});

  List<GameRecord> _items = [];
  bool _loading = false;

  List<GameRecord> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await localStorage.loadHistory();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(GameRecord record) async {
    await localStorage.addHistory(record);
    await load();
  }

  Future<void> clear() async {
    await localStorage.clearHistory();
    await load();
  }
}

