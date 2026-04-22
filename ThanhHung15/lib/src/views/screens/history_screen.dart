import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HistoryController>().load();
    });
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử'),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử',
            onPressed: history.items.isEmpty
                ? null
                : () async {
                    await history.clear();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa lịch sử')),
                    );
                  },
            icon: const Icon(Icons.delete_outline),
          )
        ],
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.items.isEmpty
              ? const Center(child: Text('Chưa có ván nào'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = history.items[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          r.win ? Icons.emoji_events : Icons.close,
                          color: r.win ? Colors.amber.shade700 : null,
                        ),
                        title: Text('${r.playerName} • ${r.mode} • ${r.difficulty}'),
                        subtitle: Text(
                          '${_fmt(r.seconds)} • ${r.createdAt.toLocal()}',
                          maxLines: 2,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

