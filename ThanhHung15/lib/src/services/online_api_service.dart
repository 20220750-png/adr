import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class OnlineApiService {
  /// Server mặc định chạy local.
  /// Bạn có thể đổi sang IP máy chạy server trong màn hình Home.
  String baseUrl = kIsWeb ? 'http://127.0.0.1:8080' : 'http://10.0.2.2:8080';

  static const Duration _shortTimeout = Duration(seconds: 3);
  static const Duration _requestTimeout = Duration(seconds: 12);

  Future<bool> ping() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(_shortTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, Object?>> register({
    required String username,
    required String password,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Đăng ký thất bại');
    }
    return json;
  }

  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Đăng nhập thất bại');
    }
    return json;
  }

  Future<Map<String, Object?>> randomRoom({
    required String token,
    required String difficulty,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/room/random'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'difficulty': difficulty}),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Không tạo/join được phòng');
    }
    return json;
  }

  Future<Map<String, Object?>> joinRoom({
    required String token,
    required String code,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/room/join'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Join phòng thất bại');
    }
    return json;
  }

  Future<Map<String, Object?>> getRoom({
    required String token,
    required String code,
  }) async {
    final res = await _get(
      Uri.parse('$baseUrl/room/$code'),
      headers: {'authorization': 'Bearer $token'},
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Không lấy được trạng thái');
    }
    return json;
  }

  Future<Map<String, Object?>> submitRoom({
    required String token,
    required String code,
    required int seconds,
    required bool finished,
    int? lives,
    String? grid,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/room/$code/submit'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'seconds': seconds,
        'finished': finished,
        ...?((lives != null) ? {'lives': lives} : null),
        ...?((grid != null) ? {'grid': grid} : null),
      }),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Gửi kết quả thất bại');
    }
    return json;
  }

  Future<Map<String, Object?>> heartbeatRoom({
    required String token,
    required String code,
    int? seconds,
    int? lives,
    String? grid,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/room/$code/heartbeat'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ...?((seconds != null) ? {'seconds': seconds} : null),
        ...?((lives != null) ? {'lives': lives} : null),
        ...?((grid != null) ? {'grid': grid} : null),
      }),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Heartbeat thất bại');
    }
    return json;
  }

  Future<Map<String, Object?>> leaveRoom({
    required String token,
    required String code,
    int? seconds,
    int? lives,
    String? grid,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/room/$code/leave'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ...?((seconds != null) ? {'seconds': seconds} : null),
        ...?((lives != null) ? {'lives': lives} : null),
        ...?((grid != null) ? {'grid': grid} : null),
      }),
    );
    final json = _decodeBody(res);
    if (res.statusCode >= 400) {
      throw Exception((json['message'] as String?) ?? 'Leave thất bại');
    }
    return json;
  }

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) async {
    try {
      return await http.get(uri, headers: headers).timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception(
        'Hết thời gian chờ (${_requestTimeout.inSeconds}s). '
        'Kiểm tra server đã chạy và URL trong Home có đúng không.',
      );
    }
  }

  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .post(uri, headers: headers, body: body)
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception(
        'Hết thời gian chờ (${_requestTimeout.inSeconds}s). '
        'Kiểm tra server đã chạy và URL trong Home có đúng không.',
      );
    }
  }

  Map<String, Object?> _decodeBody(http.Response res) {
    final text = res.body;
    if (text.trim().isEmpty) {
      return {'message': 'Máy chủ không trả dữ liệu (mã ${res.statusCode})'};
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
      return {'message': 'Phản hồi không hợp lệ'};
    } catch (_) {
      return {'message': 'Lỗi phản hồi máy chủ (mã ${res.statusCode})'};
    }
  }
}
