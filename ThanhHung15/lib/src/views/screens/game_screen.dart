import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/game_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/online_match_controller.dart';
import '../widgets/sudoku_grid.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final history = context.read<HistoryController>();
    final online = context.watch<OnlineMatchController>();

    final fixed = List<bool>.generate(81, (i) => game.isFixed(i));
    final oppFixed = fixed;
    final oppGrid = online.opponentGrid;
    final oppLives = online.opponentLives;

    Future<void> finishIfWin() async {
      final ok = game.checkFinished();
      if (!ok) return;
      await online.submit(
        seconds: game.seconds,
        finished: true,
        grid: game.current,
        lives: game.lives,
      );
      await history.add(game.buildRecord(win: true));
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hoàn thành!'),
          content: Text(
            game.mode == 'online' && online.status == 'finished'
                ? (online.youWin == true
                    ? 'Bạn đã thắng đối thủ.'
                    : 'Bạn đã thua đối thủ.')
                : 'Thời gian: ${_fmt(game.seconds)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }

    Future<void> finishIfLost() async {
      if (!game.hasLost) return;
      await online.submit(
        seconds: game.seconds,
        finished: true,
        grid: game.current,
        lives: game.lives,
      );
      await history.add(game.buildRecord(win: false));
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hết mạng'),
          content: const Text(
            'Bạn đã sai quá 5 lần. Thử lại ván mới nhé!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game • ${game.mode} • ${game.difficulty} • ${_fmt(game.seconds)}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (game.mode == 'online') {
              await online.leave();
            }
            if (context.mounted) Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  GameController.maxLives,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < game.lives ? Icons.favorite : Icons.heart_broken,
                      size: 20,
                      color: i < game.lives
                          ? Colors.redAccent
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (game.mode == 'online' && online.status == 'matched')
            Card(
              child: ListTile(
                leading: const Icon(Icons.public),
                title: Text('Đối thủ: ${online.opponent ?? '...'}'),
                subtitle: Text('Phòng: ${online.roomCode ?? '...'}'),
              ),
            ),
          if (game.mode == 'online' && online.status == 'matched')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bạn: ${game.lives}/${GameController.maxLives} mạng',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Đối thủ: ${(oppLives ?? GameController.maxLives)}/${GameController.maxLives} mạng',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Còn ${game.lives}/${GameController.maxLives} mạng — mỗi số sai trừ 1 mạng.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          if (game.mode == 'online' && online.status == 'matched' && oppGrid != null)
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 700;
                final myBoard = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bàn của bạn', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SudokuGrid(
                      values: game.current,
                      fixed: fixed,
                      selectedIndex: game.selectedIndex,
                      isCorrectAt: game.isCorrectAt,
                      onTap: game.select,
                    ),
                  ],
                );
                final oppBoard = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bàn đối thủ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SudokuGrid(
                      values: oppGrid,
                      fixed: oppFixed,
                      selectedIndex: null,
                      readOnly: true,
                    ),
                  ],
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: myBoard),
                      const SizedBox(width: 16),
                      Expanded(child: oppBoard),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myBoard,
                    const SizedBox(height: 16),
                    oppBoard,
                  ],
                );
              },
            )
          else
            SudokuGrid(
              values: game.current,
              fixed: fixed,
              selectedIndex: game.selectedIndex,
              isCorrectAt: game.isCorrectAt,
              onTap: game.select,
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var n = 1; n <= 9; n++)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 16 * 2 - 8 * 8) / 9,
                  child: OutlinedButton(
                    onPressed: game.isPlaying
                        ? () async {
                            game.inputNumber(n);
                            await online.submit(
                              seconds: game.seconds,
                              finished: false,
                              grid: game.current,
                              lives: game.lives,
                            );
                            await finishIfLost();
                            if (context.mounted) await finishIfWin();
                          }
                        : null,
                    child: Text('$n'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: game.isPlaying
                      ? () async {
                          game.clearCell();
                          await online.submit(
                            seconds: game.seconds,
                            finished: false,
                            grid: game.current,
                            lives: game.lives,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Xóa'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: game.isPlaying
                      ? () async {
                          final ok = game.applyHint();
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không còn ô để gợi ý'),
                              ),
                            );
                          } else {
                            await online.submit(
                              seconds: game.seconds,
                              finished: false,
                              grid: game.current,
                              lives: game.lives,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gợi ý một ô đúng'),
                              ),
                            );
                            if (context.mounted) await finishIfWin();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Gợi ý'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: game.isPlaying
                      ? () async {
                          final ok = game.checkFinished();
                          if (!ok) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chưa đúng hoặc còn ô trống'),
                              ),
                            );
                            return;
                          }
                          await finishIfWin();
                        }
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Nộp bài'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

