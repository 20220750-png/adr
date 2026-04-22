import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../controllers/auth_controller.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/online_match_controller.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _difficulty = 'easy';
  final _serverController = TextEditingController();
  final _roomController = TextEditingController();
  bool? _serverOk;
  bool _navigatingToGame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final online = context.read<OnlineMatchController>();
      online.addListener(_onOnlineChanged);
    });
  }

  void _onOnlineChanged() {
    if (!mounted) return;
    final online = context.read<OnlineMatchController>();
    if (_navigatingToGame) return;
    if (online.status != 'matched') return;
    if (online.seed == null) return;

    _navigatingToGame = true;
    context.read<GameController>().startNewGame(
          mode: 'online',
          difficulty: online.roomDifficulty ?? _difficulty,
          seed: online.seed,
        );
    Navigator.pushNamed(context, AppRoutes.game).then((_) {
      if (!mounted) return;
      _navigatingToGame = false;
    });
  }

  @override
  void dispose() {
    try {
      context.read<OnlineMatchController>().removeListener(_onOnlineChanged);
    } catch (_) {}
    _serverController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final online = context.watch<OnlineMatchController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          if (auth.currentUser == null)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text('Đăng nhập'),
            )
          else
            TextButton(
              onPressed: () => auth.logout(),
              child: const Text('Đăng xuất'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${auth.currentUser?.username ?? 'bạn'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'easy', label: Text('Dễ')),
                      ButtonSegment(value: 'medium', label: Text('Vừa')),
                      ButtonSegment(value: 'hard', label: Text('Khó')),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (v) =>
                        setState(() => _difficulty = v.first),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<GameController>().startNewGame(
                                  mode: 'offline',
                                  difficulty: _difficulty,
                                );
                            online.reset();
                            Navigator.pushNamed(context, AppRoutes.game);
                          },
                          icon: const Icon(Icons.offline_bolt),
                          label: const Text('Chơi offline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: online.isFinding
                              ? null
                              : () async {
                                  await online.findRandomRoom(
                                    difficulty: _difficulty,
                                  );
                                  if (online.status == 'matched' &&
                                      context.mounted) {
                                    context.read<GameController>().startNewGame(
                                          mode: 'online',
                                          difficulty:
                                              online.roomDifficulty ?? _difficulty,
                                          seed: online.seed,
                                        );
                                    Navigator.pushNamed(context, AppRoutes.game);
                                  } else if (online.status == 'waiting' &&
                                      online.roomCode != null &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đã tạo phòng ${online.roomCode}. Đang chờ người chơi khác...',
                                        ),
                                      ),
                                    );
                                  } else if (online.error != null &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(online.error!)),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.public),
                          label:
                              Text(online.isFinding ? 'Đang tìm...' : 'Random online'),
                        ),
                      ),
                    ],
                  ),
                  if (online.status == 'waiting' && online.roomCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đang chờ trong phòng: ${online.roomCode}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => online.reset(),
                          child: const Text('Hủy'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _roomController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Mã phòng',
                      hintText: 'VD: A1B2C3',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: online.isFinding
                        ? null
                        : () async {
                            final code = _roomController.text.trim();
                            if (code.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nhập mã phòng')),
                              );
                              return;
                            }
                            await online.joinByCode(code: code);
                            if (online.status == 'matched' && context.mounted) {
                              context.read<GameController>().startNewGame(
                                    mode: 'online',
                                    difficulty:
                                        online.roomDifficulty ?? _difficulty,
                                    seed: online.seed,
                                  );
                              Navigator.pushNamed(context, AppRoutes.game);
                            } else if (online.error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(online.error!)),
                              );
                            }
                          },
                    icon: const Icon(Icons.meeting_room_outlined),
                    label: const Text('Vào phòng theo mã'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.history),
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Online server',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverController,
                    decoration: InputDecoration(
                      hintText:
                          kIsWeb ? 'http://127.0.0.1:8080' : 'http://10.0.2.2:8080',
                      helperText: kIsWeb
                          ? 'Web: dùng 127.0.0.1 hoặc localhost'
                          : 'Android emulator: 10.0.2.2 | Máy thật: IP máy chạy server',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          final api = context.read<OnlineMatchController>().onlineApi;
                          final v = _serverController.text.trim();
                          if (v.isNotEmpty) api.baseUrl = v;
                          final ok = await api.ping();
                          setState(() => _serverOk = ok);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_serverOk != null)
                    Text(
                      _serverOk == true
                          ? 'Kết nối OK'
                          : 'Không kết nối được server',
                      style: TextStyle(
                        color: _serverOk == true
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (online.status == 'matched' && online.opponent != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Phòng: ${online.roomCode ?? ''} • Đối thủ: ${online.opponent}',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

