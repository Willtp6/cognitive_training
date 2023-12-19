import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/home_page_const.dart';
import 'package:cognitive_training/constants/login_page_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/shared/exit_button_template.dart';
import 'package:cognitive_training/screens/home/home_tutorial.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:cognitive_training/check_internet/check_connection_status.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../background_service/background_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final HomeTutorial _homeTutorial = HomeTutorial();

  late AudioController _audioController;
  late SettingsController _settings;

  List<bool> _isChosen = [false, false, false, false];
  final List<double> _xPositions = [-0.95, -0.3166, 0.3166, 0.95];
  int? _chosenGame;
  String? _chosenLanguage;
  String? _chosenTime;
  String? _chosenTime2;
  String? _chosenTime3;
  bool? _dailyNotificationStatus;

  final List<String> _gameRoutes = [
    'lottery_game_menu',
    'fishing_game_menu',
    'poker_game_menu',
    'route_planning_game_menu',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Logger().d('disconnnected');
    } else {
      Logger().d('connected');
    }
  }

  void playTutorialAudio(int step) {
    _audioController.playInstructionRecord(HomePageConst.tutorialAudio[step]);
  }

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<SettingsController>();
    _audioController = context.read<AudioController>();
    _chosenLanguage = _settings.language.value;
    _chosenTime = _settings.timeOfDailyNotification1.value;
    _chosenTime2 = _settings.timeOfDailyNotification2.value;
    _chosenTime3 = _settings.timeOfDailyNotification3.value;
    _dailyNotificationStatus = _settings.statusOfDailyNotification.value;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: drawerItem(_settings, context),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(LoginPageConst.loginBackground),
              fit: BoxFit.fitWidth,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              const HomePageTitle(),
              settingAndCheckinReward(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isChosen = List.generate(4, (index) => false);
                    _chosenGame = null;
                    _homeTutorial.isTutorial = true;
                    _audioController
                        .playInstructionRecord(HomePageConst.tutorialAudio[0]);
                  });
                },
                child: _homeTutorial.tutorialButton(),
              ),
              for (int i = 0; i < 4; i++)
                if (i != _chosenGame) getGameImage(i),

              // mask of background
              if (_homeTutorial.isTutorial)
                Container(color: Colors.white.withOpacity(0.7)),

              gameDescription(),
              startButton(context),
              if (_chosenGame != null) getGameImage(_chosenGame!),

              // mask of background
              if (_homeTutorial.isTutorial &&
                  _homeTutorial.tutorialProgress == 2)
                Container(color: Colors.white.withOpacity(0.7)),

              _homeTutorial.tutorialDoctor(),
              _homeTutorial.chatBubble(),
              if (_homeTutorial.isTutorial &&
                  _homeTutorial.tutorialProgress >= 1)
                _homeTutorial.hintArrow(),
              continueButton(),
            ],
          ),
        ),
      ),
    );
  }

  ListView drawerItem(SettingsController settings, BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          margin: const EdgeInsets.only(bottom: 50),
          child: Consumer<DatabaseInfoProvider>(
              builder: ((context, provider, child) {
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: AutoSizeText(
                    provider.userName,
                    style: const TextStyle(
                      fontFamily: "GSR_B",
                      fontSize: 100,
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Image.asset(
                        Globals.coinWithoutTap,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                        child: AutoSizeText(
                          '${provider.coins}\$',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontFamily: 'GSR_B',
                              color: Colors.white,
                              fontSize: 100),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          })),
        ),
        ListTile(
          leading: const Icon(
            Icons.language,
            size: 40,
            color: Colors.black,
          ),
          title: const Text(
            '語音',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          trailing: DropdownButton(
            value: _chosenLanguage,
            items: <String>[
              '國語',
              '台語',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontFamily: 'GSR_B', fontSize: 40),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _chosenLanguage = value!;
                settings.setLanguage(value);
              });
            },
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.exit_to_app,
        //     size: 40,
        //     color: Colors.black,
        //   ),
        //   title: const Text(
        //     '退出',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.exit_to_app,
        //     size: 40,
        //     color: Colors.black,
        //   ),
        //   title: const Text(
        //     '定時通知',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     if (await Permission.notification.isDenied ||
        //         await Permission.notification.isPermanentlyDenied) {
        //       Logger().d('open setting');

        //       openAppSettings();
        //     } else {
        //       PermissionStatus status = await Permission.notification.request();
        //       if (status.isGranted) {
        //         // _notificationHelper.addLoginRemindNotifications();
        //         // _notificationHelper.scheduleNotification();
        //         _notificationHelper.scheduleNotification(
        //             scheduledDateTime:
        //                 DateTime.now().add(const Duration(seconds: 10)));
        //       } else {
        //         Logger().d(status);
        //       }
        //     }
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.exit_to_app,
        //     size: 40,
        //     color: Colors.black,
        //   ),
        //   title: const Text(
        //     '取消',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     if (await Permission.notification.isDenied ||
        //         await Permission.notification.isPermanentlyDenied) {
        //       Logger().d('open setting');

        //       openAppSettings();
        //     } else {
        //       PermissionStatus status = await Permission.notification.request();
        //       if (status.isGranted) {
        //         // notification permission is granted
        //         _notificationHelper.cancelAllNotifications();
        //       } else {
        //         Logger().d(status);
        //       }
        //     }
        //   },
        // ),
        // ListTile(
        //   title: const Text(
        //     'foreground',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     FlutterBackgroundService().invoke("setAsForeground");
        //   },
        // ),
        // ListTile(
        //   title: const Text(
        //     'background',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     FlutterBackgroundService().invoke("setAsBackground");
        //   },
        // ),
        // ListTile(
        //   title: const Text(
        //     'start/stop',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     final service = FlutterBackgroundService();
        //     var isRunning = await service.isRunning();
        //     if (isRunning) {
        //       FlutterBackgroundService().invoke("stopService");
        //     } else {
        //       service.startService();
        //     }
        //   },
        // ),
        ListTile(
          title: const Text(
            '每日提醒',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          trailing: SizedBox(
            width: 70,
            height: 40,
            child: FlutterSwitch(
              value: _dailyNotificationStatus ?? false,
              onToggle: (value) {
                setState(() {
                  _dailyNotificationStatus = value;
                });
                settings.setStatusOfDailyNotification(value);
                if (value) {
                  FlutterBackgroundService().startService();
                } else {
                  FlutterBackgroundService().invoke("stopService");
                }
              },
            ),
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.access_time,
            size: 40,
            color: Colors.black,
          ),
          title: Text(
            '提醒時間$_chosenTime',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          onTap: () async {
            TimeOfDay initialTime = _chosenTime != null
                ? TimeOfDay(
                    hour: int.parse(_chosenTime!.split(':')[0]),
                    minute: int.parse(_chosenTime!.split(':')[1]))
                : TimeOfDay.now();
            TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                ) ??
                initialTime;
            String hourAndMin = newTime.toString().split('(')[1].split(')')[0];
            settings.setDailyNotificationTime1(hourAndMin);
            restartBackgroundService();
            setState(() {});
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.access_time,
            size: 40,
            color: Colors.black,
          ),
          title: Text(
            '提醒時間$_chosenTime2',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          onTap: () async {
            TimeOfDay initialTime = _chosenTime2 != null
                ? TimeOfDay(
                    hour: int.parse(_chosenTime2!.split(':')[0]),
                    minute: int.parse(_chosenTime2!.split(':')[1]))
                : TimeOfDay.now();
            TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                ) ??
                initialTime;
            String hourAndMin = newTime.toString().split('(')[1].split(')')[0];
            settings.setDailyNotificationTime2(hourAndMin);
            restartBackgroundService();
            setState(() {});
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.access_time,
            size: 40,
            color: Colors.black,
          ),
          title: Text(
            '提醒時間$_chosenTime3',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          onTap: () async {
            TimeOfDay initialTime = _chosenTime3 != null
                ? TimeOfDay(
                    hour: int.parse(_chosenTime3!.split(':')[0]),
                    minute: int.parse(_chosenTime3!.split(':')[1]))
                : TimeOfDay.now();
            TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                ) ??
                initialTime;
            String hourAndMin = newTime.toString().split('(')[1].split(')')[0];
            settings.setDailyNotificationTime3(hourAndMin);
            restartBackgroundService();
            setState(() {});
          },
        ),

        // ListTile(
        //   leading: const Icon(
        //     Icons.exit_to_app,
        //     size: 40,
        //     color: Colors.black,
        //   ),
        //   title: const Text(
        //     '顯示通知',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     NotificationHelper not = NotificationHelper();
        //     not.showAllNotifications();
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.exit_to_app,
        //     size: 40,
        //     color: Colors.black,
        //   ),
        //   title: const Text(
        //     '時間',
        //     style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        //   ),
        //   onTap: () async {
        //     final Future<SharedPreferences> instanceFuture =
        //         SharedPreferences.getInstance();
        //     final pref = await instanceFuture;
        //     final String time =
        //         pref.getString('timeOfLastDatabaseUpdate') ?? '';
        //     Logger().d(DateTime.tryParse(time));
        //   },
        // ),
        ListTile(
          leading: const Icon(
            Icons.exit_to_app,
            size: 40,
            color: Colors.black,
          ),
          title: const Text(
            '登出',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          ),
          onTap: () async {
            _showAlertDialog(context);
          },
        ),
      ],
    );
  }

  Align settingAndCheckinReward() {
    return Align(
      alignment: const Alignment(-0.9, -0.9),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.2,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: IconButton(
                        iconSize: 100,
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        icon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // chceckin reward page
              Expanded(
                child: Consumer<DatabaseInfoProvider>(
                    builder: (context, databaseInfoProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      children: [
                        Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: IconButton(
                              iconSize: 100,
                              onPressed: () {
                                GoRouter.of(context).push('/home/reward');
                              },
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: databaseInfoProvider.haveCheckinReward ||
                                        databaseInfoProvider.haveBonusReward
                                    ? Colors.amber
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: IgnorePointer(
                            child: FractionallySizedBox(
                              child: AutoSizeText(
                                '!',
                                style: TextStyle(
                                  fontSize: 100,
                                  color: Colors.red.withOpacity(
                                      databaseInfoProvider.haveCheckinReward ||
                                              databaseInfoProvider
                                                  .haveBonusReward
                                          ? 1
                                          : 0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: IconButton(
                        iconSize: 100,
                        onPressed: () {
                          context.pushNamed('ranking');
                        },
                        icon: const Icon(
                          Icons.emoji_events,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedAlign gameDescription() {
    return AnimatedAlign(
      key: const ValueKey('description'),
      alignment: _isChosen.contains(true)
          ? const Alignment(0.85, -0.6)
          : const Alignment(4.0, -0.6),
      duration: const Duration(milliseconds: 300),
      child: FractionallySizedBox(
        widthFactor: 0.55,
        heightFactor: 0.7,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            border: Border.all(color: Colors.black, width: 5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.95,
            heightFactor: 0.9,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(-0.95, 0.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.3,
                          heightFactor: 0.85,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: const FractionallySizedBox(
                              widthFactor: 0.8,
                              heightFactor: 0.9,
                              child: Center(
                                child: AutoSizeText(
                                  '遊戲介紹',
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 100,
                                      color: Colors.white,
                                      fontFamily: 'GSR_B'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ExitButton(callBackFunction: () {
                          _audioController.stopPlayingInstruction();
                          setState(() {
                            _isChosen[_isChosen.indexOf(true)] = false;
                          });
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: _chosenGame != null
                      ? FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.9,
                          child: AutoSizeText(
                            HomePageConst.gameDescription[_chosenGame!],
                            style: const TextStyle(
                                fontSize: 1000,
                                color: Colors.black,
                                fontFamily: 'GSR_B'),
                          ),
                        )
                      : Container(),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: const Alignment(-0.95, 0.0),
                    child: FractionallySizedBox(
                      widthFactor: 0.3,
                      heightFactor: 0.85,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.9,
                          child: Center(
                            child: AutoSizeText(
                              '訓練領域',
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 100,
                                  color: Colors.white,
                                  fontFamily: 'GSR_B'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _chosenGame != null
                      ? FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.9,
                          child: AutoSizeText(
                            HomePageConst.gameTrainingArea[_chosenGame!],
                            style: const TextStyle(
                                fontSize: 1000,
                                color: Colors.black,
                                fontFamily: 'GSR_B'),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void nextTutorialProgress() {
    setState(() {
      if (_homeTutorial.tutorialProgress < 2) {
        _homeTutorial.tutorialProgress++;
        if (_homeTutorial.tutorialProgress == 1) {
          _chosenGame = 0;
          playTutorialAudio(_homeTutorial.tutorialProgress);
        } else if (_homeTutorial.tutorialProgress == 2) {
          _isChosen[0] = true;
          playTutorialAudio(_homeTutorial.tutorialProgress);
        }
      } else {
        _audioController.stopPlayingInstruction();
        Future.delayed(const Duration(milliseconds: 500), () {
          _homeTutorial.tutorialProgress = 0;
        });
        _isChosen = List.generate(4, (index) => false);
        _homeTutorial.isTutorial = false;
      }
    });
  }

  IgnorePointer continueButton() {
    return IgnorePointer(
      ignoring: !_homeTutorial.isTutorial,
      child: _homeTutorial.getContinueButton(callback: nextTutorialProgress),
    );
  }

  AnimatedAlign startButton(BuildContext context) {
    return AnimatedAlign(
      key: const ValueKey('start_button'),
      alignment: _isChosen.contains(true)
          ? const Alignment(0.5, 0.9)
          : const Alignment(0.5, 3.0),
      duration: const Duration(milliseconds: 300),
      child: FractionallySizedBox(
        heightFactor: 0.2,
        child: DottedBorder(
          color: _homeTutorial.tutorialProgress == 2
              ? Colors.red
              : Colors.white.withOpacity(0),
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          strokeWidth: 2,
          dashPattern: const [8, 4],
          padding: const EdgeInsets.all(1),
          strokeCap: StrokeCap.round,
          child: ButtonWithText(text: '開始遊戲', onTapFunction: checkForStartGame),
        ),
      ),
    );
  }

  Widget getGameImage(int gameIndex) {
    return AnimatedAlign(
      key: ValueKey(gameIndex),
      alignment: _isChosen[gameIndex]
          ? const Alignment(-0.95, 0.0)
          : Alignment(_xPositions[gameIndex], 0.4),
      duration: const Duration(milliseconds: 300),
      child: AnimatedFractionallySizedBox(
        widthFactor: _isChosen[gameIndex] ? 0.4 : 0.225,
        duration: const Duration(milliseconds: 300),
        child: AspectRatio(
          aspectRatio: 939 / 1054,
          child: DottedBorder(
            color:
                _homeTutorial.tutorialProgress == 1 && gameIndex == _chosenGame
                    ? Colors.red
                    : Colors.white.withOpacity(0),
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            strokeWidth: 2,
            dashPattern: const [8, 4],
            padding: const EdgeInsets.all(10),
            strokeCap: StrokeCap.round,
            child: GestureDetector(
              onTap: () {
                if (!_homeTutorial.isTutorial) {
                  setState(() {
                    if (_isChosen.contains(true)) {
                      if (_isChosen.indexOf(true) == gameIndex) {
                        _isChosen[gameIndex] = false;
                        _audioController.stopPlayingInstruction();
                      }
                    } else {
                      _isChosen[gameIndex] = !_isChosen[gameIndex];
                      _chosenGame = gameIndex;
                      // audioController.playGameDescription(gameIndex);
                      _audioController.playGameDescription(gameIndex);
                      // FlameAudio.playLongAudio(
                      //     'home_page/chinese/fishing_game_description.m4a');
                    }
                  });
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(HomePageConst.choosingGameBanner),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0.0, -0.7),
                      child: FractionallySizedBox(
                        heightFactor: 0.2,
                        child: AutoSizeText(
                          HomePageConst.gameName[gameIndex],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 100),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.0, 0.65),
                      child: FractionallySizedBox(
                        heightFactor: 0.44,
                        widthFactor: 0.885,
                        child: Image.asset(
                          HomePageConst.gameImagePaths[gameIndex],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '登出帳號',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  '確定要登出嗎?\n登出後需要重新登入',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '否',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
              ),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '是',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
              ),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) {
                  GoRouter.of(context).pop();
                  GoRouter.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> lostConnectionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '沒有網路連線',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  '遊戲內紀錄需要網路連線',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '請確保網路連線正常',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '關閉',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
              ),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void checkForStartGame() {
    final status = context.read<CheckConnectionStatus>();
    if (status.connectionStatus.value == ConnectivityResult.none) {
      Logger().w('lost connection');
      lostConnectionDialog(context);
    } else if (!_homeTutorial.isTutorial) {
      final audioController = context.read<AudioController>();
      audioController.stopPlayingInstruction();
      String route = _gameRoutes[_isChosen.indexOf(true)];
      GoRouter.of(context).pushNamed(route);
    }
    _audioController.playSfx(Globals.clickButtonSound);
  }
}

class HomePageTitle extends StatelessWidget {
  const HomePageTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, -0.9),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.5,
        child: Image.asset(
          HomePageConst.choosingGameTitle,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class ExitButton extends ExitButtonTemplate {
  final Function callBackFunction;
  const ExitButton({super.key, required this.callBackFunction});

  @override
  void onTapFunction() {
    callBackFunction();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () {
          onTapFunction();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pink,
            border: Border.all(color: Colors.black, width: 1),
            shape: BoxShape.circle,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.8,
            widthFactor: 0.8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double iconSize = constraints.maxWidth;
                return Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: iconSize,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
