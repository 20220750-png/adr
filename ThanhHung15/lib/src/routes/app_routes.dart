import 'package:flutter/material.dart';

import '../views/screens/game_screen.dart';
import '../views/screens/history_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/register_screen.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const history = '/history';
  static const game = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case game:
        return MaterialPageRoute(builder: (_) => const GameScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Không tìm thấy')),
            body: Center(child: Text('Route không tồn tại: ${settings.name}')),
          ),
        );
    }
  }
}

