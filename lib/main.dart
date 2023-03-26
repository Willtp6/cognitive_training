import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game_menu.dart';
import 'package:cognitive_training/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:cognitive_training/screens/splash/splash_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
        builder: (context, state) => const Wrapper(),
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
                    path: 'lottery_game',
                    builder: (context, state) => const LotteryGame(),
                  ),
                ],
              )
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
