import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _historyFileName = 'game_history.json';
const _historySubdir = 'sudoku';

Future<File> _historyFile() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}${Platform.pathSeparator}$_historySubdir');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return File('${dir.path}${Platform.pathSeparator}$_historyFileName');
}

Future<String?> readHistoryFileContent() async {
  final file = await _historyFile();
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeHistoryFileContent(String data) async {
  final file = await _historyFile();
  await file.writeAsString(data, flush: true);
}

Future<void> deleteHistoryFile() async {
  final file = await _historyFile();
  if (await file.exists()) await file.delete();
}
