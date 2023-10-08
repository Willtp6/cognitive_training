import 'package:cognitive_training/app_lifecycle/app_lifecycle.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/check_internet/check_connection_status.dart';
import 'package:cognitive_training/models/global_info_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/screens/games/fishing_game/fishing_game_play.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game_scene.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game_menu.dart';
import 'package:cognitive_training/screens/games/poker_game/poker_game_scene.dart';
import 'package:cognitive_training/screens/games/poker_game/poker_game_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d_play.dart';
import 'package:cognitive_training/screens/home/reward_page.dart';
import 'package:cognitive_training/settings/persistence/local_storage_settings_persistence.dart';
import 'package:cognitive_training/settings/persistence/settings_persistence.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:logger/logger.dart';
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
            path: 'home',
            name: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'reward',
                builder: (context, state) => const RewardPage(),
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
                        final startLevel = parameters['startLevel'] ?? '0';
                        final startDigit = parameters['startDigit'] ?? '2';
                        final isTutorial = parameters['isTutorial'] ?? 'false';
                        Logger().i(parameters);
                        Logger().i(startLevel);
                        Logger().i(startDigit);
                        Logger().i(isTutorial);

                        return LotteryGameScene(
                          startLevel: int.tryParse(startLevel) ?? 0,
                          startDigit: int.tryParse(startDigit) ?? 2,
                          isTutorial: isTutorial == 'true',
                        );
                      }),
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
                        final startLevel = parameters['startLevel'] ?? '0';
                        final isTutorial = parameters['isTutorial'] ?? 'false';
                        Logger().i(startLevel);
                        Logger().i(isTutorial);
                        return FishingGamePlay(
                          gameLevel: int.tryParse(startLevel)!,
                          isTutorial: isTutorial == 'true',
                        );
                      }),
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
                      final startLevel = parameters['startLevel'] ?? '0';
                      final isTutorial = parameters['isTutorial'] ?? 'false';
                      final responseTimeList =
                          parameters['responseTimeList'] ?? '[]';
                      Logger().d(responseTimeList);
                      List<int> myList = responseTimeList.length >= 3
                          ? responseTimeList
                              .substring(1, responseTimeList.length - 1)
                              .split(', ')
                              .map<int>((item) => int.parse(item))
                              .toList()
                          : [10000, 10000, 10000, 10000, 10000];
                      return PokerGameScene(
                        startLevel: int.tryParse(startLevel) ?? 0,
                        isTutorial: isTutorial == 'true',
                        responseTimeList: myList,
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
                      // final parameters = state.queryParams;
                      // final startLevel = parameters['startLevel'] ?? '0';
                      // final isTutorial = parameters['isTutorial'] ?? 'false';
                      // final responseTimeList =
                      //     parameters['responseTimeList'] ?? '[]';
                      // Logger().d(responseTimeList);
                      // List<int> myList = responseTimeList.length >= 3
                      //     ? responseTimeList
                      //         .substring(1, responseTimeList.length - 1)
                      //         .split(', ')
                      //         .map<int>((item) => int.parse(item))
                      //         .toList()
                      //     : [10000, 10000, 10000, 10000, 10000];
                      // return PokerGameScene(
                      //   startLevel: int.tryParse(startLevel) ?? 0,
                      //   isTutorial: isTutorial == 'true',
                      //   responseTimeList: myList,
                      // );
                      return RoutePlanningGameForge2dPlay();
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
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
          ChangeNotifierProvider(
            lazy: false,
            create: (_) => UserInfoProvider(),
          ),
          ChangeNotifierProvider(
            lazy: false,
            create: (_) => UserCheckinProvider(),
          ),
          ChangeNotifierProvider(
            lazy: false,
            create: (_) => GlobalInfoProvider(),
          ),
          Provider<SettingsController>(
            lazy: false,
            create: (context) => SettingsController(
              persistence: settingsPersistence,
            )..loadStateFromPersistence(),
          ),
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
          theme: ThemeData(fontFamily: 'GSR_R'),
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
      Logger().d(user);
      return user != null ? const HomePage() : const LoginPage();
    });
  }
}
