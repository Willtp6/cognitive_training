// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';

import 'dart:async';

import 'package:cognitive_training/app_lifecycle/app_lifecycle.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/check_internet/check_connection_status.dart';
import 'package:cognitive_training/models/global_info_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/notifications_util/notification_helper.dart';
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
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_service/background_service.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screens/games/fishing_game/fishing_game_menu.dart';
import 'settings/setting_controller.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  await initializeService();

  runApp(
    MyApp(
      settingsPersistence: LocalStorageSettingsPersistence(),
    ),
  );
}

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: false,
//     ),
//   );

//   await service.startService();
// }

// // AndroidInitializationSettings是一个用于设置Android上的本地通知初始化的类
// // 使用了app_icon作为参数，这意味着在Android上，应用程序的图标将被用作本地通知的图标。
// const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');

// // 初始化
// const InitializationSettings initializationSettings =
//     InitializationSettings(android: initializationSettingsAndroid);
// const AndroidNotificationDetails androidCustomizeNotificationDetails =
//     AndroidNotificationDetails(
//   'cognitive.training.app.customizer.notification',
//   'user customize notification',
//   channelDescription: 'to remind user',
//   importance: Importance.max,
//   priority: Priority.high,
//   ticker: 'ticker',
// );
// const AndroidNotificationDetails androidLoginReminderNotificationDetails =
//     AndroidNotificationDetails(
//   'cognitive.training.app.login.reminder',
//   'login reminder',
//   channelDescription: 'to remind user login and play',
//   importance: Importance.max,
//   priority: Priority.high,
//   ticker: 'ticker',
// );
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });

//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }

//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await notificationsPlugin.initialize(initializationSettings);
//   //  初始化tz
//   tz.initializeTimeZones();

//   service.on('stopService').listen((event) async {
//     final List<PendingNotificationRequest> pendingNotificationRequests =
//         await notificationsPlugin.pendingNotificationRequests();
//     for (int i = 0; i < pendingNotificationRequests.length; i++) {
//       Logger().d('${pendingNotificationRequests[i].id}');
//       notificationsPlugin.cancel(pendingNotificationRequests[i].id);
//     }
//     service.stopSelf();
//   });
//   setNotification(notificationsPlugin, androidCustomizeNotificationDetails);
//   Timer.periodic(const Duration(days: 1), (timer) {
//     setNotification(notificationsPlugin, androidCustomizeNotificationDetails);
//   });
// }

// Future<void> setNotification(
//   FlutterLocalNotificationsPlugin notificationsPlugin,
//   AndroidNotificationDetails androidNotificationDetails,
// ) async {
//   Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();
//   final pref = await instanceFuture;

//   if (pref.getBool('statusOfDailyNotification') ?? false) {
//     final List<String> timeList = [
//       pref.getString('timeOfDailyNotification') ?? '',
//       pref.getString('timeOfDailyNotification2') ?? '',
//       pref.getString('timeOfDailyNotification3') ?? '',
//     ];
//     for (int i = 0; i < timeList.length; i++) {
//       if (timeList[i].isNotEmpty) {
//         int hour = int.parse(timeList[i].split(':')[0]);
//         int minute = int.parse(timeList[i].split(':')[1]);
//         DateTime timeForNotification;

//         DateTime now = DateTime.now();
//         timeForNotification =
//             DateTime(now.year, now.month, now.day, hour, minute);

//         if (timeForNotification.isBefore(now)) {
//           timeForNotification =
//               timeForNotification.add(const Duration(days: 1));
//         }
//         await notificationsPlugin.zonedSchedule(
//           10 + i,
//           '每日提醒',
//           '記得登入遊玩及領取獎勵',
//           tz.TZDateTime.from(timeForNotification, tz.local),
//           NotificationDetails(android: androidNotificationDetails),
//           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//         );
//       }
//     }
//   }
// }

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
                        // final startLevel = parameters['startLevel'] ?? '0';
                        // final startDigit = parameters['startDigit'] ?? '2';
                        // final continuousWin =
                        //     parameters['historyContinuousWin'] ?? '0';
                        // final continuousLose =
                        //     parameters['historyContinuousLose'] ?? '0';
                        final isTutorial = parameters['isTutorial'] ?? 'false';

                        final userInfoProvider =
                            context.read<UserInfoProvider>();
                        final database = userInfoProvider.lotteryGameDatabase;

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
                        final isTutorial = parameters['isTutorial'] ?? 'false';
                        final userInfoProvider =
                            context.read<UserInfoProvider>();
                        final database = userInfoProvider.fishingGameDatabase;
                        return FishingGamePlay(
                          gameLevel: database.currentLevel,
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
                      final userInfoProvider = context.read<UserInfoProvider>();
                      final database = userInfoProvider.pokerGameDatabase;

                      final parameters = state.queryParams;
                      // final startLevel = parameters['startLevel'] ?? '0';
                      // final historyContinuousWin =
                      //     parameters['historyContinuousWin'] ?? '0';
                      // final historyContinuousLose =
                      //     parameters['historyContinuousLose'] ?? '0';
                      final isTutorial = parameters['isTutorial'] ?? 'false';
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
                      // final startLevel = parameters['startLevel'] ?? '0';
                      final enterTutotialMode =
                          parameters['isTutorial'] ?? 'false';
                      Logger().i(enterTutotialMode);
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
              persistence: LocalStorageSettingsPersistence(),
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
      // Logger().d(user);
      return user != null ? const HomePage() : const LoginPage();
    });
  }
}
