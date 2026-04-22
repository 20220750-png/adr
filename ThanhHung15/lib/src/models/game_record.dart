class GameRecord {
  final String id;
  final String playerName;
  final String mode; // offline | online
  final String difficulty; // easy|medium|hard
  final int seconds;
  final bool win;
  final DateTime createdAt;

  const GameRecord({
    required this.id,
    required this.playerName,
    required this.mode,
    required this.difficulty,
    required this.seconds,
    required this.win,
    required this.createdAt,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'playerName': playerName,
        'mode': mode,
        'difficulty': difficulty,
        'seconds': seconds,
        'win': win,
        'createdAt': createdAt.toIso8601String(),
      };

  static GameRecord fromJson(Map<String, Object?> json) => GameRecord(
        id: (json['id'] as String?) ?? '',
        playerName: (json['playerName'] as String?) ?? '',
        mode: (json['mode'] as String?) ?? 'offline',
        difficulty: (json['difficulty'] as String?) ?? 'easy',
        seconds: (json['seconds'] as num?)?.toInt() ?? 0,
        win: (json['win'] as bool?) ?? false,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

