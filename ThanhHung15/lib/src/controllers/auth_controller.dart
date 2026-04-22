import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/online_api_service.dart';

class AuthController extends ChangeNotifier {
  final LocalStorageService localStorage;
  final OnlineApiService onlineApi;

  AuthController({
    required this.localStorage,
    required this.onlineApi,
  });

  UserProfile? _currentUser;
  String? _token;
  bool _loading = false;
  String? _error;

  UserProfile? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> bootstrap() async {
    _currentUser = await localStorage.loadUser();
    _token = await localStorage.loadToken();
    notifyListeners();
  }

  Future<void> loginOfflineGuest({String username = 'Guest'}) async {
    _setLoading(true);
    try {
      _error = null;
      final user = UserProfile(
        id: const Uuid().v4(),
        username: username.trim().isEmpty ? 'Guest' : username.trim(),
        isGuest: true,
      );
      _currentUser = user;
      _token = null;
      await localStorage.saveUser(user);
      await localStorage.saveToken(null);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerOnline({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _error = null;
      final json = await onlineApi.register(
        username: username.trim(),
        password: password,
      );
      _token = (json['token'] as String?) ?? _token;
      final user = UserProfile(
        id: (json['userId'] as String?) ?? const Uuid().v4(),
        username: (json['username'] as String?) ?? username.trim(),
        isGuest: false,
      );
      _currentUser = user;
      await localStorage.saveUser(user);
      await localStorage.saveToken(_token);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginOnline({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _error = null;
      final json = await onlineApi.login(
        username: username.trim(),
        password: password,
      );
      _token = (json['token'] as String?) ?? _token;
      final user = UserProfile(
        id: (json['userId'] as String?) ?? const Uuid().v4(),
        username: (json['username'] as String?) ?? username.trim(),
        isGuest: false,
      );
      _currentUser = user;
      await localStorage.saveUser(user);
      await localStorage.saveToken(_token);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await localStorage.saveUser(null);
    await localStorage.saveToken(null);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}

