import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

late final Future<SharedPreferences> instanceFuture;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  instanceFuture = SharedPreferences.getInstance();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
    ),
  );

  await service.startService();
}

// AndroidInitializationSettings是一个用于设置Android上的本地通知初始化的类
// 使用了app_icon作为参数，这意味着在Android上，应用程序的图标将被用作本地通知的图标。
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

// 初始化
const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
const AndroidNotificationDetails androidCustomizeNotificationDetails =
    AndroidNotificationDetails(
  'cognitive.training.app.customizer.notification',
  'user customize notification',
  channelDescription: 'to remind user',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
);
const AndroidNotificationDetails androidLoginReminderNotificationDetails =
    AndroidNotificationDetails(
  'cognitive.training.app.login.reminder',
  'login reminder',
  channelDescription: 'to remind user login and play',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
);

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // if (service is AndroidServiceInstance) {
  //   service.on('setAsForeground').listen((event) {
  //     service.setAsForegroundService();
  //   });

  //   service.on('setAsBackground').listen((event) {
  //     service.setAsBackgroundService();
  //   });
  // }

  Logger().d('start');

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await notificationsPlugin.initialize(initializationSettings);
  //  初始化tz
  tz.initializeTimeZones();

  service.on('stopService').listen((event) async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await notificationsPlugin.pendingNotificationRequests();
    for (int i = 0; i < pendingNotificationRequests.length; i++) {
      Logger().d('${pendingNotificationRequests[i].id}');
      notificationsPlugin.cancel(pendingNotificationRequests[i].id);
    }
    service.stopSelf();
  });

  setCustomizedNotification(notificationsPlugin);
  setLoginRemindNotification(notificationsPlugin);
  Timer.periodic(const Duration(days: 1), (timer) {
    setCustomizedNotification(notificationsPlugin);
    setLoginRemindNotification(notificationsPlugin);
  });
}

void restartBackgroundService() async {
  final service = FlutterBackgroundService();
  FlutterBackgroundService().invoke("stopService");
  do {
    // Check the condition, and decide whether to continue the loop
    if (await service.isRunning() == false) {
      service.startService();
    }

    // You can add a delay if you want to avoid busy waiting
    await Future.delayed(const Duration(seconds: 1));
  } while (await service.isRunning() == false);
}

Future<void> setCustomizedNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
) async {
  Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();
  final pref = await instanceFuture;

  if (pref.getBool('statusOfDailyNotification') ?? false) {
    final List<String> timeList = [
      pref.getString('timeOfDailyNotification1') ?? '',
      pref.getString('timeOfDailyNotification2') ?? '',
      pref.getString('timeOfDailyNotification3') ?? '',
    ];
    for (int i = 0; i < timeList.length; i++) {
      // Logger().d(timeList[i]);
      if (timeList[i].isNotEmpty) {
        final hour = int.parse(timeList[i].split(':')[0]);
        final minute = int.parse(timeList[i].split(':')[1]);
        final now = DateTime.now();
        DateTime timeForNotification =
            DateTime(now.year, now.month, now.day, hour, minute);

        if (timeForNotification.isBefore(now)) {
          timeForNotification =
              timeForNotification.add(const Duration(days: 1));
        }
        await notificationsPlugin.zonedSchedule(
          10 + i,
          '遊戲時間到了喔！',
          '趕快點我繼續遊戲吧！',
          tz.TZDateTime.from(timeForNotification, tz.local),
          const NotificationDetails(
              android: androidCustomizeNotificationDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}

Future<void> setLoginRemindNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
) async {
  Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();
  final pref = await instanceFuture;
  final time = pref.getString('timeOfLastDatabaseUpdate') ?? '';
  if (time.isNotEmpty) {
    final now = DateTime.now();
    List<DateTime> timeList = [
      DateTime(now.year, now.month, now.day, 7, 30),
      DateTime(now.year, now.month, now.day, 12, 30),
      DateTime(now.year, now.month, now.day, 17, 30),
    ];
    final lastUpdateTime = DateTime.tryParse(time);
    for (int i = 0; i < timeList.length; i++) {
      if (timeList[i].difference(lastUpdateTime!).inDays < 3) continue;
      if (timeList[i].isBefore(now)) {
        timeList[i] = timeList[i].add(const Duration(days: 1));
      }
      await notificationsPlugin.zonedSchedule(
        20 + i,
        '叮咚！你已經三天沒有上線了！',
        '點我進入並完成遊戲！',
        tz.TZDateTime.from(timeList[i], tz.local),
        const NotificationDetails(android: androidCustomizeNotificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
