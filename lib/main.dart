// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';

import 'package:cognitive_training/app_lifecycle/app_lifecycle.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/check_internet/check_connection_status.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/fishing_game/fishing_game_play.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game_scene.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game_menu.dart';
import 'package:cognitive_training/screens/games/poker_game/poker_game_scene.dart';
import 'package:cognitive_training/screens/games/poker_game/poker_game_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d_play.dart';
import 'package:cognitive_training/screens/home/ranking_page.dart';
import 'package:cognitive_training/screens/home/reward_page.dart';
import 'package:cognitive_training/settings/persistence/local_storage_settings_persistence.dart';
import 'package:cognitive_training/settings/persistence/settings_persistence.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:logger/logger.dart';
import 'background_service/background_service.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screens/games/fishing_game/fishing_game_menu.dart';
import 'settings/setting_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeService();

  runApp(
    MyApp(
      settingsPersistence: LocalStorageSettingsPersistence(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.settingsPersistence});

  final SettingsPersistence settingsPersistence;

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const Wrapper();
        },
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: 'home',
            name: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'reward',
                name: 'reward',
                builder: (context, state) => const RewardPage(),
              ),
              GoRoute(
                path: 'ranking',
                name: 'ranking',
                builder: (context, state) => const RankingPage(),
              ),
              GoRoute(
                name: 'lottery_game_menu',
                path: 'lottery_game_menu',
                builder: (context, state) => const LotteryGameMenu(),
                routes: [
                  GoRoute(
                    name: 'lottery_game',
                    path: 'lottery_game',
                    builder: (context, state) {
                      final parameters = state.queryParams;
                      final isTutorial = parameters['isTutorial'] ?? 'false';

                      final databaseInfoProvider =
                          context.read<DatabaseInfoProvider>();
                      final database = databaseInfoProvider.lotteryGameDatabase;

                      return LotteryGameScene(
                        startLevel: database.currentLevel,
                        startDigit: database.currentDigit,
                        continuousCorrectRateBiggerThan50:
                            database.continuousCorrectRateBiggerThan50,
                        loseInCurrentDigit: database.loseInCurrentDigit,
                        historyContinuousWin: database.historyContinuousWin,
                        historyContinuousLose: database.historyContinuousLose,
                        isTutorial: isTutorial == 'true',
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'fishing_game_menu',
                path: 'fishing_game_menu',
                builder: (context, state) => const FishingGameMenu(),
                routes: [
                  GoRoute(
                    name: 'fishing_game',
                    path: 'fishing_game',
                    builder: (context, state) {
                      final parameters = state.queryParams;
                      final isTutorial = parameters['isTutorial'] ?? 'false';
                      return FishingGamePlay(
                        isTutorial: isTutorial == 'true',
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'poker_game_menu',
                path: 'poker_game_menu',
                builder: (context, state) => const PokerGameMenu(),
                routes: [
                  GoRoute(
                    name: 'poker_game',
                    path: 'poker_game',
                    builder: (context, state) {
                      final parameters = state.queryParams;
                      final isTutorial = parameters['isTutorial'] ?? 'false';
                      final databaseInfoProvider =
                          context.read<DatabaseInfoProvider>();
                      final database = databaseInfoProvider.pokerGameDatabase;
                      return PokerGameScene(
                        startLevel: database.currentLevel,
                        historyContinuousWin: database.historyContinuousWin,
                        historyContinuousLose: database.historyContinuousLose,
                        isTutorial: isTutorial == 'true',
                        responseTimeList: database.responseTimeList,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'route_planning_game_menu',
                path: 'route_planning_game_menu',
                builder: (context, state) =>
                    const RoutePlanningGameForge2dMenu(),
                routes: [
                  GoRoute(
                    name: 'route_planning_game',
                    path: 'route_planning_game',
                    builder: (context, state) {
                      final parameters = state.queryParams;
                      final enterTutotialMode =
                          parameters['isTutorial'] ?? 'false';
                      Logger().i(enterTutotialMode);
                      return RoutePlanningGameForge2dPlay(
                        isTutorial: enterTutotialMode == 'true',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          StreamProvider(
            create: (context) => FirebaseAuth.instance.authStateChanges(),
            initialData: null,
          ),
          Provider<SettingsController>(
            lazy: false,
            create: (context) => SettingsController(
              persistence: LocalStorageSettingsPersistence(),
            )..loadStateFromPersistence(),
          ),
          ChangeNotifierProvider(
            lazy: false,
            create: (_) => DatabaseInfoProvider(),
          ),
          // ProxyProvider<SettingsController, DatabaseInfoProvider>(
          //   lazy: false,
          //   create: (_) => DatabaseInfoProvider(),
          //   update: (_, settings, databaseprovider) {
          //     if (databaseprovider == null) throw ArgumentError.notNull();
          //     databaseprovider.attachSettings(settings);
          //     return databaseprovider;
          //   },
          // ),
          Provider<CheckConnectionStatus>(
            lazy: false,
            create: (context) => CheckConnectionStatus(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            lazy: false,
            create: (context) => AudioController()..initialize(),
            update: (context, settings, lifecycleNotifier, audio) {
              if (audio == null) throw ArgumentError.notNull();
              audio.attachLifecycleNotifier(lifecycleNotifier);
              audio.attachSettings(settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'GSR_B'),
          routerConfig: router,
        ),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User?>(builder: (_, user, child) {
      return user != null ? const HomePage() : const LoginPage();
    });
  }
}
