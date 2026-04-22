import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ??
      int.tryParse(args.isNotEmpty ? args.first : '') ??
      8080;

  final db = await MySqlStore.connectFromEnv();
  await db.ensureSchema();
  db.startCleanupJob();

  final router = Router();

  router.get('/health', (Request req) async {
    final ok = await db.ping();
    return Response.ok(jsonEncode({'ok': ok}), headers: _jsonHeaders());
  });

  router.post('/auth/register', (Request req) async {
    final json = await _readJson(req);
    final username = (json['username'] as String?)?.trim() ?? '';
    final password = (json['password'] as String?) ?? '';
    if (username.length < 3 || password.length < 4) {
      return _err(400, 'Username >=3, password >=4');
    }
    try {
      final result = await db.register(username: username, password: password);
      return Response.ok(jsonEncode(result), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  router.post('/auth/login', (Request req) async {
    final json = await _readJson(req);
    final username = (json['username'] as String?)?.trim() ?? '';
    final password = (json['password'] as String?) ?? '';
    if (username.isEmpty || password.isEmpty) {
      return _err(400, 'Thiếu username/password');
    }
    try {
      final result = await db.login(username: username, password: password);
      return Response.ok(jsonEncode(result), headers: _jsonHeaders());
    } catch (e) {
      return _err(401, e.toString());
    }
  });

  // Random: nếu có phòng đang chờ thì join, không thì tạo phòng mới
  router.post('/room/random', (Request req) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');

    final json = await _readJson(req);
    final difficulty = (json['difficulty'] as String?) ?? 'easy';
    try {
      final room = await db.randomOrCreateRoom(
        userId: user.userId,
        difficulty: difficulty,
      );
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  // Join theo mã phòng
  router.post('/room/join', (Request req) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');

    final json = await _readJson(req);
    final code = ((json['code'] as String?) ?? '').trim().toUpperCase();
    if (code.length < 4) return _err(400, 'Mã phòng không hợp lệ');

    try {
      final room = await db.joinRoomByCode(userId: user.userId, code: code);
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  // Lấy trạng thái phòng (poll)
  router.get('/room/<code>', (Request req, String code) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');
    final c = code.trim().toUpperCase();
    try {
      final room = await db.getRoom(userId: user.userId, code: c);
      if (room == null) return _err(404, 'Không tìm thấy phòng');
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  router.post('/room/<code>/submit', (Request req, String code) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');
    final c = code.trim().toUpperCase();
    final json = await _readJson(req);
    final seconds = (json['seconds'] as num?)?.toInt();
    final finished = (json['finished'] as bool?) ?? false;
    final lives = (json['lives'] as num?)?.toInt();
    final grid = json['grid'] as String?;
    if (seconds == null) return _err(400, 'Thiếu seconds');
    try {
      final room = await db.submit(
        userId: user.userId,
        code: c,
        seconds: seconds,
        finished: finished,
        lives: lives,
        grid: grid,
      );
      if (room == null) return _err(404, 'Không tìm thấy phòng');
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  router.post('/room/<code>/heartbeat', (Request req, String code) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');
    final c = code.trim().toUpperCase();
    final json = await _readJson(req);
    final seconds = (json['seconds'] as num?)?.toInt();
    final lives = (json['lives'] as num?)?.toInt();
    final grid = json['grid'] as String?;
    try {
      final room = await db.heartbeat(
        userId: user.userId,
        code: c,
        seconds: seconds,
        lives: lives,
        grid: grid,
      );
      if (room == null) return _err(404, 'Không tìm thấy phòng');
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  router.post('/room/<code>/leave', (Request req, String code) async {
    final user = await _requireAuth(db, req);
    if (user == null) return _err(401, 'Thiếu token');
    final c = code.trim().toUpperCase();
    final json = await _readJson(req);
    final seconds = (json['seconds'] as num?)?.toInt();
    final lives = (json['lives'] as num?)?.toInt();
    final grid = json['grid'] as String?;
    try {
      final room = await db.leaveRoom(
        userId: user.userId,
        code: c,
        seconds: seconds,
        lives: lives,
        grid: grid,
      );
      if (room == null) return _err(404, 'Không tìm thấy phòng');
      return Response.ok(jsonEncode(room), headers: _jsonHeaders());
    } catch (e) {
      return _err(400, e.toString());
    }
  });

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('Sudoku server running on http://${server.address.host}:$port');
}

Map<String, String> _jsonHeaders() => const {'content-type': 'application/json'};

Response _err(int code, String message) => Response(
      code,
      body: jsonEncode({'message': message}),
      headers: _jsonHeaders(),
    );

Future<Map<String, Object?>> _readJson(Request req) async {
  final body = await req.readAsString();
  if (body.trim().isEmpty) return <String, Object?>{};
  final decoded = jsonDecode(body);
  if (decoded is! Map) return <String, Object?>{};
  return decoded.cast<String, Object?>();
}

class AuthedUser {
  final String userId;
  final String username;
  AuthedUser({required this.userId, required this.username});
}

Future<AuthedUser?> _requireAuth(MySqlStore db, Request req) async {
  final auth = req.headers['authorization'];
  if (auth == null) return null;
  final parts = auth.split(' ');
  if (parts.length != 2 || parts.first.toLowerCase() != 'bearer') return null;
  return db.getUserByToken(parts[1]);
}

class MySqlStore {
  final ConnectionSettings _settings;
  MySqlConnection _conn;
  final Random _rand = Random();
  final _AsyncMutex _mmMutex = _AsyncMutex();

  MySqlStore._(this._settings, this._conn);

  MySqlConnection get conn => _conn;

  static Future<MySqlStore> connectFromEnv() async {
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 3306;
    final user = Platform.environment['DB_USER'] ?? 'root';
    final pass = Platform.environment['DB_PASS'] ?? '123456';
    final db = Platform.environment['DB_NAME'] ?? 'sudoku';

    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: pass,
      db: db,
    );
    final conn = await MySqlConnection.connect(settings);
    return MySqlStore._(settings, conn);
  }

  Future<bool> ping() async {
    try {
      await conn.query('SELECT 1');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _reconnect() async {
    try {
      await _conn.close();
    } catch (_) {}
    _conn = await MySqlConnection.connect(_settings);
  }

  bool _isSocketClosedError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('socket') && s.contains('closed');
  }

  Future<Results> _query(String sql, [List<Object?>? params]) async {
    try {
      return await _conn.query(sql, params);
    } catch (e) {
      if (_isSocketClosedError(e)) {
        await _reconnect();
        return await _conn.query(sql, params);
      }
      rethrow;
    }
  }

  Future<void> ensureSchema() async {
    await _query('''
CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  salt VARCHAR(64) NOT NULL,
  password_hash VARCHAR(128) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
''');
    await _query('''
CREATE TABLE IF NOT EXISTS sessions (
  token CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id)
);
''');
    await _query('''
CREATE TABLE IF NOT EXISTS rooms (
  code VARCHAR(8) PRIMARY KEY,
  difficulty VARCHAR(10) NOT NULL,
  seed BIGINT NOT NULL,
  status VARCHAR(10) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  host_user_id CHAR(36) NOT NULL,
  guest_user_id CHAR(36) NULL,
  host_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guest_last_seen TIMESTAMP NULL,
  host_lives INT NOT NULL DEFAULT 5,
  guest_lives INT NOT NULL DEFAULT 5,
  host_grid VARCHAR(81) NULL,
  guest_grid VARCHAR(81) NULL,
  host_seconds INT NULL,
  guest_seconds INT NULL,
  host_finished TINYINT(1) NOT NULL DEFAULT 0,
  guest_finished TINYINT(1) NOT NULL DEFAULT 0,
  winner_user_id CHAR(36) NULL,
  CONSTRAINT fk_rooms_host FOREIGN KEY (host_user_id) REFERENCES users(id),
  CONSTRAINT fk_rooms_guest FOREIGN KEY (guest_user_id) REFERENCES users(id),
  CONSTRAINT fk_rooms_winner FOREIGN KEY (winner_user_id) REFERENCES users(id)
);
''');

    // Migrate: add columns nếu DB đã tạo từ bản cũ
    await _tryAddColumn('rooms', 'host_lives', 'INT NOT NULL DEFAULT 5');
    await _tryAddColumn('rooms', 'guest_lives', 'INT NOT NULL DEFAULT 5');
    await _tryAddColumn('rooms', 'host_grid', 'VARCHAR(81) NULL');
    await _tryAddColumn('rooms', 'guest_grid', 'VARCHAR(81) NULL');
    await _tryAddColumn(
      'rooms',
      'host_last_seen',
      'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP',
    );
    await _tryAddColumn('rooms', 'guest_last_seen', 'TIMESTAMP NULL');

    await _query('''
CREATE TABLE IF NOT EXISTS match_history (
  room_code VARCHAR(8) PRIMARY KEY,
  difficulty VARCHAR(10) NOT NULL,
  seed BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  host_user_id CHAR(36) NOT NULL,
  guest_user_id CHAR(36) NOT NULL,
  host_seconds INT NOT NULL,
  guest_seconds INT NOT NULL,
  host_lives INT NOT NULL,
  guest_lives INT NOT NULL,
  winner_user_id CHAR(36) NOT NULL
);
''');
  }

  Future<void> _tryAddColumn(String table, String column, String ddl) async {
    try {
      final rows = await _query('''
SELECT COUNT(*) as c
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = ?
  AND COLUMN_NAME = ?
''', [table, column]);
      final c = rows.first['c'] as int;
      if (c == 0) {
        await _query('ALTER TABLE $table ADD COLUMN $column $ddl');
      }
    } catch (_) {
      // ignore migration errors (ex: permissions)
    }
  }

  Future<Map<String, Object?>> register({
    required String username,
    required String password,
  }) async {
    final existed = await conn.query(
      'SELECT id FROM users WHERE username = ? LIMIT 1',
      [username],
    );
    if (existed.isNotEmpty) {
      throw Exception('Tài khoản đã tồn tại');
    }
    final userId = const Uuid().v4();
    final salt = const Uuid().v4().replaceAll('-', '');
    final hash = _hashPassword(salt, password);
    await conn.query(
      'INSERT INTO users(id, username, salt, password_hash) VALUES (?, ?, ?, ?)',
      [userId, username, salt, hash],
    );
    final token = await _createSession(userId);
    return {'userId': userId, 'username': username, 'token': token};
  }

  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  }) async {
    final rows = await conn.query(
      'SELECT id, salt, password_hash FROM users WHERE username = ? LIMIT 1',
      [username],
    );
    if (rows.isEmpty) {
      throw Exception('Sai tài khoản hoặc mật khẩu');
    }
    final r = rows.first;
    final userId = r['id'] as String;
    final salt = r['salt'] as String;
    final hash = r['password_hash'] as String;
    if (_hashPassword(salt, password) != hash) {
      throw Exception('Sai tài khoản hoặc mật khẩu');
    }
    final token = await _createSession(userId);
    return {'userId': userId, 'username': username, 'token': token};
  }

  Future<String> _createSession(String userId) async {
    final token = const Uuid().v4();
    await conn.query(
      'INSERT INTO sessions(token, user_id) VALUES (?, ?)',
      [token, userId],
    );
    return token;
  }

  Future<AuthedUser?> getUserByToken(String token) async {
    final rows = await conn.query('''
SELECT u.id as user_id, u.username as username
FROM sessions s
JOIN users u ON u.id = s.user_id
WHERE s.token = ?
LIMIT 1
''', [token]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return AuthedUser(
      userId: r['user_id'] as String,
      username: r['username'] as String,
    );
  }

  String _hashPassword(String salt, String password) {
    final bytes = utf8.encode('$salt|$password');
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, Object?>> randomOrCreateRoom({
    required String userId,
    required String difficulty,
  }) async {
    // mysql1 single connection không an toàn khi nhiều request chạy song song.
    // Serialize matchmaking để chắc chắn người bấm sau sẽ thấy phòng waiting vừa tạo.
    return _mmMutex.run<Map<String, Object?>>(() async {
      return _withTx<Map<String, Object?>>((tx) async {
        final pick = await tx.query('''
SELECT code FROM rooms
WHERE status = 'waiting'
  AND guest_user_id IS NULL
  AND host_user_id <> ?
  AND difficulty = ?
ORDER BY created_at ASC
LIMIT 1
FOR UPDATE
''', [userId, difficulty]);

        if (pick.isNotEmpty) {
          final code = pick.first['code'] as String;
          await tx.query(
            "UPDATE rooms SET guest_user_id = ?, status = 'matched' WHERE code = ?",
            [userId, code],
          );
          final room = await _getRoomTx(tx, userId: userId, code: code);
          if (room == null) throw Exception('Không join được phòng');
          return room;
        }

        final code = _newRoomCode();
        final seed = _rand.nextInt(1 << 31);
        await tx.query('''
INSERT INTO rooms(code, difficulty, seed, status, host_user_id)
VALUES(?, ?, ?, 'waiting', ?)
''', [code, difficulty, seed, userId]);

        final room = await _getRoomTx(tx, userId: userId, code: code);
        if (room == null) throw Exception('Không tạo được phòng');
        return room;
      });
    });
  }

  Future<Map<String, Object?>> joinRoomByCode({
    required String userId,
    required String code,
  }) async {
    return _withTx<Map<String, Object?>>((tx) async {
      final rows = await tx.query(
        'SELECT host_user_id, guest_user_id, status FROM rooms WHERE code = ? FOR UPDATE',
        [code],
      );
      if (rows.isEmpty) {
        throw Exception('Không tìm thấy phòng');
      }
      final r = rows.first;
      final host = r['host_user_id'] as String;
      final guest = r['guest_user_id'] as String?;
      final status = r['status'] as String;

      if (host == userId || guest == userId) {
        final room = await _getRoomTx(tx, userId: userId, code: code);
        if (room == null) throw Exception('Không lấy được phòng');
        return room;
      }

      if (status != 'waiting') {
        throw Exception('Phòng đang bận hoặc đã kết thúc');
      }
      if (guest != null) {
        throw Exception('Phòng đã đủ người');
      }

      await tx.query(
        "UPDATE rooms SET guest_user_id = ?, status = 'matched', guest_last_seen = NOW() WHERE code = ?",
        [userId, code],
      );
      final room = await _getRoomTx(tx, userId: userId, code: code);
      if (room == null) throw Exception('Không join được phòng');
      return room;
    });
  }

  Future<Map<String, Object?>?> getRoom({
    required String userId,
    required String code,
  }) async {
    return _getRoomTx(conn, userId: userId, code: code);
  }

  Future<Map<String, Object?>?> submit({
    required String userId,
    required String code,
    required int seconds,
    required bool finished,
    required int? lives,
    required String? grid,
  }) async {
    return _withTx<Map<String, Object?>?>((tx) async {
      final rows = await tx.query(
        'SELECT host_user_id, guest_user_id, status FROM rooms WHERE code = ? FOR UPDATE',
        [code],
      );
      if (rows.isEmpty) return null;
      final r = rows.first;
      final host = r['host_user_id'] as String;
      final guest = r['guest_user_id'] as String?;
      if (guest == null) {
        // chưa đủ người, vẫn cho host gửi tiến độ
      }
      final status = r['status'] as String;
      if (status == 'finished') {
        return _getRoomTx(tx, userId: userId, code: code);
      }

      if (userId == host) {
        await tx.query(
          'UPDATE rooms SET host_seconds = ?, host_finished = ?, host_lives = COALESCE(?, host_lives), host_grid = COALESCE(?, host_grid), host_last_seen = NOW() WHERE code = ?',
          [seconds, finished ? 1 : 0, lives, grid, code],
        );
      } else if (guest != null && userId == guest) {
        await tx.query(
          'UPDATE rooms SET guest_seconds = ?, guest_finished = ?, guest_lives = COALESCE(?, guest_lives), guest_grid = COALESCE(?, guest_grid), guest_last_seen = NOW() WHERE code = ?',
          [seconds, finished ? 1 : 0, lives, grid, code],
        );
      } else {
        throw Exception('Bạn không thuộc phòng này');
      }

      // Nếu đủ 2 người và cả 2 finished thì chốt winner
      final check = await tx.query('''
SELECT difficulty, seed,
       host_user_id, guest_user_id,
       host_seconds, guest_seconds,
       host_lives, guest_lives,
       host_finished, guest_finished,
       status
FROM rooms WHERE code = ? FOR UPDATE
''', [code]);
      final c = check.first;
      final g = c['guest_user_id'] as String?;
      if (g != null &&
          (c['host_finished'] as int) == 1 &&
          (c['guest_finished'] as int) == 1) {
        final hs = (c['host_seconds'] as int?) ?? (1 << 30);
        final gs = (c['guest_seconds'] as int?) ?? (1 << 30);
        final hl = (c['host_lives'] as int?) ?? 0;
        final gl = (c['guest_lives'] as int?) ?? 0;
        final hostId = c['host_user_id'] as String;

        // Winner: ưu tiên mạng còn lại, nếu bằng thì ưu tiên thời gian nhỏ hơn
        final winner = (hl > gl)
            ? hostId
            : (gl > hl)
                ? g
                : (hs <= gs ? hostId : g);
        await tx.query(
          "UPDATE rooms SET status='finished', winner_user_id=? WHERE code=?",
          [winner, code],
        );
        await _insertHistoryIfNeeded(
          tx,
          code: code,
          difficulty: c['difficulty'] as String,
          seed: (c['seed'] as int),
          hostUserId: hostId,
          guestUserId: g,
          hostSeconds: hs,
          guestSeconds: gs,
          hostLives: hl,
          guestLives: gl,
          winnerUserId: winner,
        );
      } else {
        // ensure status matched if guest exists
        if (g != null) {
          await tx.query(
            "UPDATE rooms SET status='matched' WHERE code=? AND status='waiting'",
            [code],
          );
        }
      }

      return _getRoomTx(tx, userId: userId, code: code);
    });
  }

  Future<void> _insertHistoryIfNeeded(
    MySqlConnection tx, {
    required String code,
    required String difficulty,
    required int seed,
    required String hostUserId,
    required String guestUserId,
    required int hostSeconds,
    required int guestSeconds,
    required int hostLives,
    required int guestLives,
    required String winnerUserId,
  }) async {
    // Idempotent: room_code là PK
    await tx.query('''
INSERT INTO match_history(
  room_code, difficulty, seed, host_user_id, guest_user_id,
  host_seconds, guest_seconds, host_lives, guest_lives, winner_user_id, ended_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
ON DUPLICATE KEY UPDATE
  ended_at = VALUES(ended_at),
  host_seconds = VALUES(host_seconds),
  guest_seconds = VALUES(guest_seconds),
  host_lives = VALUES(host_lives),
  guest_lives = VALUES(guest_lives),
  winner_user_id = VALUES(winner_user_id)
''', [
      code,
      difficulty,
      seed,
      hostUserId,
      guestUserId,
      hostSeconds,
      guestSeconds,
      hostLives,
      guestLives,
      winnerUserId,
    ]);
  }

  Future<Map<String, Object?>?> _getRoomTx(
    MySqlConnection q, {
    required String userId,
    required String code,
  }) async {
    final rows = await q.query('''
SELECT r.code, r.difficulty, r.seed, r.status,
       r.host_user_id, r.guest_user_id, r.winner_user_id,
       r.host_lives, r.guest_lives, r.host_grid, r.guest_grid,
       r.host_last_seen, r.guest_last_seen,
       uh.username as host_name,
       ug.username as guest_name
FROM rooms r
JOIN users uh ON uh.id = r.host_user_id
LEFT JOIN users ug ON ug.id = r.guest_user_id
WHERE r.code = ?
LIMIT 1
''', [code]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    final host = r['host_user_id'] as String;
    final guest = r['guest_user_id'] as String?;
    if (userId != host && userId != guest) {
      throw Exception('Bạn không thuộc phòng này');
    }
    final hostName = r['host_name'] as String;
    final guestName = r['guest_name'] as String?;
    final opponent = userId == host ? guestName : hostName;
    final winnerId = r['winner_user_id'] as String?;
    final youWin = (winnerId != null && winnerId == userId);

    final hostLives = (r['host_lives'] as int?) ?? 5;
    final guestLives = (r['guest_lives'] as int?) ?? 5;
    final hostGrid = r['host_grid'] as String?;
    final guestGrid = r['guest_grid'] as String?;

    final oppLives = userId == host ? guestLives : hostLives;
    final oppGrid = userId == host ? guestGrid : hostGrid;

    return {
      'code': r['code'] as String,
      'difficulty': r['difficulty'] as String,
      'seed': (r['seed'] as int),
      'status': r['status'] as String,
      'opponent': opponent,
      'opponentLives': oppLives,
      'opponentGrid': oppGrid,
      'winnerUserId': winnerId,
      'youWin': r['status'] == 'finished' ? youWin : null,
    };
  }

  Future<Map<String, Object?>?> heartbeat({
    required String userId,
    required String code,
    required int? seconds,
    required int? lives,
    required String? grid,
  }) async {
    return _withTx<Map<String, Object?>?>((tx) async {
      final rows = await tx.query(
        'SELECT host_user_id, guest_user_id FROM rooms WHERE code = ? FOR UPDATE',
        [code],
      );
      if (rows.isEmpty) return null;
      final r = rows.first;
      final host = r['host_user_id'] as String;
      final guest = r['guest_user_id'] as String?;

      if (userId == host) {
        await tx.query(
          'UPDATE rooms SET host_last_seen = NOW(), host_seconds = COALESCE(?, host_seconds), host_lives = COALESCE(?, host_lives), host_grid = COALESCE(?, host_grid) WHERE code = ?',
          [seconds, lives, grid, code],
        );
      } else if (guest != null && userId == guest) {
        await tx.query(
          'UPDATE rooms SET guest_last_seen = NOW(), guest_seconds = COALESCE(?, guest_seconds), guest_lives = COALESCE(?, guest_lives), guest_grid = COALESCE(?, guest_grid) WHERE code = ?',
          [seconds, lives, grid, code],
        );
      } else {
        throw Exception('Bạn không thuộc phòng này');
      }
      return _getRoomTx(tx, userId: userId, code: code);
    });
  }

  Future<Map<String, Object?>?> leaveRoom({
    required String userId,
    required String code,
    required int? seconds,
    required int? lives,
    required String? grid,
  }) async {
    return _withTx<Map<String, Object?>?>((tx) async {
      final rows = await tx.query(
        'SELECT difficulty, seed, status, host_user_id, guest_user_id, host_seconds, guest_seconds, host_lives, guest_lives, host_finished, guest_finished FROM rooms WHERE code = ? FOR UPDATE',
        [code],
      );
      if (rows.isEmpty) return null;
      final r = rows.first;
      final status = r['status'] as String;
      final host = r['host_user_id'] as String;
      final guest = r['guest_user_id'] as String?;

      if (status == 'finished') {
        return _getRoomTx(tx, userId: userId, code: code);
      }

      // If waiting and host leaves -> delete room
      if (status == 'waiting' && guest == null && userId == host) {
        await tx.query('DELETE FROM rooms WHERE code = ?', [code]);
        return {
          'code': code,
          'status': 'deleted',
        };
      }

      if (guest == null) {
        throw Exception('Phòng chưa đủ người');
      }

      final youAreHost = userId == host;
      if (!youAreHost && userId != guest) {
        throw Exception('Bạn không thuộc phòng này');
      }

      // Update leaver snapshot then forfeit
      if (youAreHost) {
        await tx.query(
          'UPDATE rooms SET host_seconds = COALESCE(?, host_seconds), host_lives = COALESCE(?, host_lives), host_grid = COALESCE(?, host_grid), host_finished = 1, host_last_seen = NOW() WHERE code = ?',
          [seconds, lives, grid, code],
        );
      } else {
        await tx.query(
          'UPDATE rooms SET guest_seconds = COALESCE(?, guest_seconds), guest_lives = COALESCE(?, guest_lives), guest_grid = COALESCE(?, guest_grid), guest_finished = 1, guest_last_seen = NOW() WHERE code = ?',
          [seconds, lives, grid, code],
        );
      }

      final winner = youAreHost ? guest : host;
      await tx.query(
        "UPDATE rooms SET status='finished', winner_user_id=? WHERE code=?",
        [winner, code],
      );

      final hs = (r['host_seconds'] as int?) ?? (seconds ?? (1 << 30));
      final gs = (r['guest_seconds'] as int?) ?? (seconds ?? (1 << 30));
      final hl = (r['host_lives'] as int?) ?? (lives ?? 0);
      final gl = (r['guest_lives'] as int?) ?? (lives ?? 0);
      await _insertHistoryIfNeeded(
        tx,
        code: code,
        difficulty: r['difficulty'] as String,
        seed: (r['seed'] as int),
        hostUserId: host,
        guestUserId: guest,
        hostSeconds: hs,
        guestSeconds: gs,
        hostLives: hl,
        guestLives: gl,
        winnerUserId: winner,
      );

      return _getRoomTx(tx, userId: userId, code: code);
    });
  }

  void startCleanupJob() {
    Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        await cleanupRooms();
      } catch (_) {}
    });
  }

  Future<void> cleanupRooms() async {
    // waiting: nếu host mất kết nối quá 30s thì xóa phòng
    await _withTx<void>((tx) async {
      await tx.query('''
DELETE FROM rooms
WHERE status='waiting'
  AND guest_user_id IS NULL
  AND host_last_seen < (NOW() - INTERVAL 30 SECOND)
''');

      // matched: nếu 1 bên mất kết nối quá 15s -> bên còn lại thắng
      final stale = await tx.query('''
SELECT code, difficulty, seed, host_user_id, guest_user_id,
       host_seconds, guest_seconds, host_lives, guest_lives,
       host_last_seen, guest_last_seen
FROM rooms
WHERE status='matched' AND guest_user_id IS NOT NULL
FOR UPDATE
''');
      for (final row in stale) {
        final code = row['code'] as String;
        final hostSeen = row['host_last_seen'] as DateTime;
        final guestSeen = row['guest_last_seen'] as DateTime?;
        if (guestSeen == null) continue;
        final now = DateTime.now().toUtc();
        final hostStale = now.difference(hostSeen.toUtc()).inSeconds > 15;
        final guestStale = now.difference(guestSeen.toUtc()).inSeconds > 15;
        if (!hostStale && !guestStale) continue;
        if (hostStale && guestStale) {
          // cả 2 đều out -> đóng và xóa
          await tx.query('DELETE FROM rooms WHERE code=?', [code]);
          continue;
        }
        final host = row['host_user_id'] as String;
        final guest = row['guest_user_id'] as String;
        final winner = hostStale ? guest : host;
        await tx.query(
          "UPDATE rooms SET status='finished', winner_user_id=? WHERE code=?",
          [winner, code],
        );

        final hs = (row['host_seconds'] as int?) ?? (1 << 30);
        final gs = (row['guest_seconds'] as int?) ?? (1 << 30);
        final hl = (row['host_lives'] as int?) ?? 0;
        final gl = (row['guest_lives'] as int?) ?? 0;
        await _insertHistoryIfNeeded(
          tx,
          code: code,
          difficulty: row['difficulty'] as String,
          seed: (row['seed'] as int),
          hostUserId: host,
          guestUserId: guest,
          hostSeconds: hs,
          guestSeconds: gs,
          hostLives: hl,
          guestLives: gl,
          winnerUserId: winner,
        );
      }
    });
  }

  String _newRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final b = StringBuffer();
    for (var i = 0; i < 6; i++) {
      b.write(chars[_rand.nextInt(chars.length)]);
    }
    return b.toString();
  }

  Future<T> _withTx<T>(Future<T> Function(MySqlConnection tx) fn) async {
    await conn.query('START TRANSACTION');
    try {
      final v = await fn(conn);
      await conn.query('COMMIT');
      return v;
    } catch (e) {
      await conn.query('ROLLBACK');
      rethrow;
    }
  }
}

class _AsyncMutex {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() fn) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final v = await fn();
        completer.complete(v);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

