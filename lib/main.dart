import 'package:cognitive_training/models/userinfo_provider.dart';
import 'package:cognitive_training/screens/gmaes/fishing_game/fishing_game.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game_menu.dart';
import 'package:cognitive_training/screens/gmaes/poker_game/poker_game.dart';
import 'package:cognitive_training/screens/gmaes/poker_game/poker_game_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:cognitive_training/screens/splash/splash_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screens/gmaes/fishing_game/fishing_game_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final userInfoProvider = UserInfoProvider();
  runApp(ChangeNotifierProvider.value(
    value: userInfoProvider,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return Consumer<UserInfoProvider>(
            builder: (context, userInfoProvider, child) {
              return userInfoProvider.usr != null &&
                      userInfoProvider.fileFunctionNormally
                  ? HomePage()
                  : LoginPage();
            },
          );
        },
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
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
                        final isTutorial = parameters['isTutorial'] ?? 'true';
                        return LotteryGame(
                          startLevel: int.tryParse(startLevel),
                          startDigit: int.tryParse(startDigit),
                          isTutorial: isTutorial == 'true',
                        );
                      }),
                ],
              ),
              GoRoute(
                path: 'poker_game_menu',
                builder: (context, state) => const PokerGameMenu(),
                routes: [
                  GoRoute(
                    path: 'poker_game',
                    builder: (context, state) {
                      final parameters = state.queryParams;
                      final startLevel = parameters['startLevel'] ?? '0';
                      final isTutorial = parameters['isTutorial'] ?? 'true';
                      return PokerGame(
                        startLevel: int.tryParse(startLevel),
                        isTutorial: isTutorial == 'true',
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'fishing_game_menu',
                builder: (context, state) => FishingGameMenu(),
                routes: [
                  GoRoute(
                    path: 'fishing_game',
                    builder: (context, state) => FishingGame(),
                  )
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginPage(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (context) => AuthService().userStream,
          initialData: null,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
