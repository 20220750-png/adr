import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/online_match_controller.dart';
import 'routes/app_routes.dart';
import 'services/local_storage_service.dart';
import 'services/online_api_service.dart';

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = LocalStorageService();
    final onlineApi = OnlineApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            localStorage: localStorage,
            onlineApi: onlineApi,
          )..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(localStorage: localStorage)..load(),
        ),
        ChangeNotifierProxyProvider<AuthController, GameController>(
          create: (_) => GameController(),
          update: (_, auth, game) => game!..setPlayer(auth.currentUser),
        ),
        ChangeNotifierProxyProvider<AuthController, OnlineMatchController>(
          create: (_) => OnlineMatchController(onlineApi: onlineApi),
          update: (_, auth, online) => online!..setAuth(auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sudoku',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

