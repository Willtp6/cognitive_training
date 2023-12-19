// // 导入包
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logger/logger.dart';

// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class NotificationHelper {
//   // 使用单例模式进行初始化
//   static final NotificationHelper _instance = NotificationHelper._internal();
//   factory NotificationHelper() => _instance;
//   NotificationHelper._internal();

//   // FlutterLocalNotificationsPlugin是一个用于处理本地通知的插件，它提供了在Flutter应用程序中发送和接收本地通知的功能。
//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // 初始化函数
//   Future<void> initialize() async {
//     // AndroidInitializationSettings是一个用于设置Android上的本地通知初始化的类
//     // 使用了app_icon作为参数，这意味着在Android上，应用程序的图标将被用作本地通知的图标。
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     // 15.1是DarwinInitializationSettings，旧版本好像是IOSInitializationSettings（有些例子中就是这个）
//     // const DarwinInitializationSettings initializationSettingsIOS =
//     //     DarwinInitializationSettings();
//     // 初始化
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       // iOS: initializationSettingsIOS
//     );
//     await _notificationsPlugin.initialize(initializationSettings);
//     //  初始化tz
//     tz.initializeTimeZones();
//   }

// //  显示通知
//   Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     // 安卓的通知
//     // 'your channel id'：用于指定通知通道的ID。
//     // 'your channel name'：用于指定通知通道的名称。
//     // 'your channel description'：用于指定通知通道的描述。
//     // Importance.max：用于指定通知的重要性，设置为最高级别。
//     // Priority.high：用于指定通知的优先级，设置为高优先级。
//     // 'ticker'：用于指定通知的提示文本，即通知出现在通知中心的文本内容。
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'your.channel.id',
//       'your channel name',
//       channelDescription: 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     // ios的通知
//     // const String darwinNotificationCategoryPlain = 'plainCategory';
//     // const DarwinNotificationDetails iosNotificationDetails =
//     //     DarwinNotificationDetails(
//     //   categoryIdentifier: darwinNotificationCategoryPlain, // 通知分类
//     // );
//     // 创建跨平台通知
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidNotificationDetails,
//       // iOS: iosNotificationDetails
//     );

//     // 发起一个通知
//     await _notificationsPlugin.show(
//       1,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   // 周期性通知
//   // Future<void> scheduleNotification(
//   //     // { required int id,
//   //     // required String title,
//   //     // required String body,}
//   //     ) async {
//   //   const AndroidNotificationDetails androidNotificationDetails =
//   //       AndroidNotificationDetails(
//   //     'your.channel.id',
//   //     'your channel name',
//   //     channelDescription: 'your channel description',
//   //     importance: Importance.max,
//   //     priority: Priority.high,
//   //     ticker: 'ticker',
//   //   );

//   //   const NotificationDetails notificationDetails =
//   //       NotificationDetails(android: androidNotificationDetails);
//   //   await _notificationsPlugin.periodicallyShow(
//   //     888,
//   //     'repeating title',
//   //     'repeating body ${TimeOfDay.now()}',
//   //     RepeatInterval.everyMinute,
//   //     notificationDetails,
//   //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   //   );
//   // }

//   // 定时通知
//   Future<void> zonedScheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDateTime,
//   }) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'your.channel.id',
//       'your channel name',
//       channelDescription: 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     Logger().d(DateTime.now());
//     Logger().d(tz.TZDateTime.from(scheduledDateTime, tz.local));

//     for (int i = 0; i < 5; i++) {
//       await _notificationsPlugin.zonedSchedule(
//         i,
//         'scheduled title',
//         'scheduled body',
//         tz.TZDateTime.now(tz.local).add(Duration(seconds: 5, minutes: i)),
//         const NotificationDetails(android: androidNotificationDetails),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );
//     }
//   }

//   // 定时通知
//   Future<void> scheduleNotification({
//     required DateTime scheduledDateTime,
//   }) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'your.channel.id',
//       'your channel name',
//       channelDescription: 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     Logger().d(DateTime.now());
//     Logger().d(tz.TZDateTime.from(scheduledDateTime, tz.local));

//     await _notificationsPlugin.zonedSchedule(
//       10,
//       'scheduled title',
//       'scheduled body',
//       tz.TZDateTime.from(scheduledDateTime, tz.local),
//       const NotificationDetails(android: androidNotificationDetails),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }

//   // Future<void> addLoginRemindNotifications() async {
//   //   // 安卓的通知
//   //   // 'your channel id'：用于指定通知通道的ID。
//   //   // 'your channel name'：用于指定通知通道的名称。
//   //   // 'your channel description'：用于指定通知通道的描述。
//   //   // Importance.max：用于指定通知的重要性，设置为最高级别。
//   //   // Priority.high：用于指定通知的优先级，设置为高优先级。
//   //   // 'ticker'：用于指定通知的提示文本，即通知出现在通知中心的文本内容。
//   //   const AndroidNotificationDetails androidNotificationDetails =
//   //       AndroidNotificationDetails(
//   //     'cognitive.training.app.login.reminder',
//   //     'login reminder',
//   //     channelDescription: 'to remind user login and play',
//   //     importance: Importance.max,
//   //     priority: Priority.high,
//   //     ticker: 'ticker',
//   //   );

//   //   for (int i = 0; i < 7; i++) {
//   //     await _notificationsPlugin.zonedSchedule(
//   //       i,
//   //       '超過三天未進行遊戲了喔$i',
//   //       '記得登入遊玩及領取簽到獎勵',
//   //       tz.TZDateTime.now(tz.local).add(Duration(days: i + 3)),
//   //       const NotificationDetails(android: androidNotificationDetails),
//   //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   //       uiLocalNotificationDateInterpretation:
//   //           UILocalNotificationDateInterpretation.absoluteTime,
//   //     );
//   //   }
//   //   Logger().d('all settled');
//   // }

//   Future<void> showAllNotifications() async {
//     // Below will give you any unpresented/scheduled notifications
//     final List<PendingNotificationRequest> pendingNotificationRequests =
//         await _notificationsPlugin.pendingNotificationRequests();
//     for (int i = 0; i < pendingNotificationRequests.length; i++) {
//       Logger().d(
//           '${pendingNotificationRequests[i].id}_${pendingNotificationRequests[i].body}');
//     }
//   }

//   Future<void> cancelAllNotifications() async {
//     // Below will give you any unpresented/scheduled notifications
//     final List<PendingNotificationRequest> pendingNotificationRequests =
//         await _notificationsPlugin.pendingNotificationRequests();
//     for (int i = 0; i < pendingNotificationRequests.length; i++) {
//       Logger().d('${pendingNotificationRequests[i].id}');
//       _notificationsPlugin.cancel(pendingNotificationRequests[i].id);
//     }
//   }
// }
