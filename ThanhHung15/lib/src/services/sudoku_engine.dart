import 'dart:math';

class SudokuPuzzle {
  final List<int> givens; // 81, 0 for empty
  final List<int> solution; // 81

  const SudokuPuzzle({required this.givens, required this.solution});
}

class SudokuEngine {
  final Random _rand;

  SudokuEngine({Random? rand}) : _rand = rand ?? Random();

  SudokuPuzzle generate({required String difficulty}) {
    final solution = _generateSolvedGrid();
    final givens = List<int>.from(solution);

    final removeCount = switch (difficulty) {
      'easy' => 40,
      'medium' => 50,
      'hard' => 58,
      _ => 45,
    };

    final indices = List<int>.generate(81, (i) => i)..shuffle(_rand);
    var removed = 0;
    for (final idx in indices) {
      if (removed >= removeCount) break;
      givens[idx] = 0;
      removed++;
    }

    return SudokuPuzzle(givens: givens, solution: solution);
  }

  SudokuPuzzle generateSeeded({required String difficulty, required int seed}) {
    return SudokuEngine(rand: Random(seed)).generate(difficulty: difficulty);
  }

  List<int> _generateSolvedGrid() {
    final grid = List<int>.filled(81, 0);
    _fill(grid, 0);
    return grid;
  }

  bool _fill(List<int> grid, int pos) {
    if (pos >= 81) return true;
    if (grid[pos] != 0) return _fill(grid, pos + 1);

    final candidates = List<int>.generate(9, (i) => i + 1)..shuffle(_rand);
    for (final v in candidates) {
      if (_canPlace(grid, pos, v)) {
        grid[pos] = v;
        if (_fill(grid, pos + 1)) return true;
        grid[pos] = 0;
      }
    }
    return false;
  }

  bool _canPlace(List<int> grid, int pos, int v) {
    final r = pos ~/ 9;
    final c = pos % 9;

    for (var i = 0; i < 9; i++) {
      if (grid[r * 9 + i] == v) return false;
      if (grid[i * 9 + c] == v) return false;
    }

    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (var dr = 0; dr < 3; dr++) {
      for (var dc = 0; dc < 3; dc++) {
        if (grid[(br + dr) * 9 + (bc + dc)] == v) return false;
      }
    }
    return true;
  }
}

