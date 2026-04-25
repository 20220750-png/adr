import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/routing/app_routes.dart';
import 'screens/about_screen.dart';
import 'screens/difficulty_screen.dart';
import 'screens/game_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _location = AppRoutes.splash;

  void _go(String location) {
    if (!mounted) return;
    const allowed = {
      AppRoutes.splash,
      AppRoutes.home,
      AppRoutes.difficulty,
      AppRoutes.game,
      AppRoutes.login,
      AppRoutes.history,
      AppRoutes.settings,
      AppRoutes.about,
      AppRoutes.result,
    };
    setState(() => _location = allowed.contains(location) ? location : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_location) {
      AppRoutes.home => HomeScreen(onNavigate: _go),
      AppRoutes.difficulty => DifficultyScreen(onNavigate: _go),
      AppRoutes.game => GameScreen(onNavigate: _go),
      AppRoutes.login => LoginScreen(onNavigate: _go),
      AppRoutes.history => HistoryScreen(onNavigate: _go),
      AppRoutes.settings => SettingsScreen(onNavigate: _go),
      AppRoutes.about => AboutScreen(onNavigate: _go),
      AppRoutes.result => ResultScreen(onNavigate: _go),
      _ => SplashScreen(onNavigate: _go),
    };

    return AnimatedSwitcher(
      duration: 260.ms,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        final slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(fade);
        return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
      },
      child: KeyedSubtree(
        key: ValueKey(_location),
        child: screen,
      ),
    );
  }
}

