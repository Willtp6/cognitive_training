import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/home/home_tutorial.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:cognitive_training/check_internet/check_connection_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final HomeTutorial _homeTutorial = HomeTutorial();
  late UserInfoProvider userInfoProvider;
  late UserCheckinProvider userCheckinProvider;
  late AudioController _audioController;
  AudioPlayer player = AudioPlayer();

  // // !
  // final checker = CheckConnectionStatus();
  // // !

  List<bool> isChosen = [false, false, false, false];
  List<double> xPositions = [-0.95, -0.3166, 0.3166, 0.95];
  int? chosenGame;
  String? chosenLanguage;
  List<String> gameImagePaths = [
    'assets/home_page/choosing_game_lottery.png',
    'assets/home_page/choosing_game_fishing.png',
    'assets/home_page/choosing_game_poker.png',
    'assets/home_page/choosing_game_route.png',
  ];
  List<String> gameName = [
    '樂透彩券',
    '釣魚',
    '撲克牌',
    '路線規劃',
  ];
  List<String> gameDescriptionString = [
    '廟裡的神明會給你一組樂透彩券號碼，將號碼記憶下來，去彩券行下注贏取獎金!想成為樂透得主嗎？那就試著記下中獎號碼吧！',
    '到海邊釣魚，水面上漣漪越大，水底下的魚越大。選擇正確的釣竿，一起來釣大魚吧！',
    '公園散步巧遇朋友，展開一場撲克牌遊戲，想在這場遊戲中勝利，就要選擇適合的牌打出去！一起來挑戰吧！',
    '接到家人的電話請求幫忙出門辦事。請用最快的速度完成家人交辦的各項任務，再回到家中！我們出發吧！',
  ];
  List<String> gameTrainingArea = [
    '注意力/工作記憶',
    '執行功能',
    '注意力',
    '執行功能',
  ];

  List<String> gameRoutes = [
    '/home/lottery_game_menu',
    '/home/fishing_game_menu',
    '/home/poker_game_menu',
    '/home/route_game_menu',
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
    player.dispose();
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

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    userCheckinProvider = Provider.of<UserCheckinProvider>(context);
    final settings = context.watch<SettingsController>();
    chosenLanguage = settings.language.value;
    _audioController = context.read<AudioController>();
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: drawerItem(settings, context),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/global/login_background_1.jpeg'),
              fit: BoxFit.fitWidth,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              title(),
              settingAndCheckinReward(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isChosen = List.generate(4, (index) => false);
                    chosenGame = null;
                    _homeTutorial.isTutorial = true;
                    _audioController.playInstructionRecord(
                        'tutorial/self_introduction.m4a');
                  });
                },
                child: _homeTutorial.tutorialButton(),
              ),
              for (int i = 0; i < 4; i++)
                if (i != chosenGame) getGameImage(i),

              // mask of background
              if (_homeTutorial.isTutorial)
                Container(color: Colors.white.withOpacity(0.7)),

              gameDescription(),
              startButton(context),
              if (chosenGame != null) getGameImage(chosenGame!),

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
          child:
              Consumer<UserInfoProvider>(builder: ((context, provider, child) {
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
                        'assets/global/coin_without_tap.png',
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
            value: chosenLanguage,
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
                chosenLanguage = value!;
                settings.setLanguage(value);
              });
            },
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Align settingAndCheckinReward() {
    return Align(
      alignment: const Alignment(-0.9, -0.9),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.15,
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
                child: Consumer2<UserInfoProvider, UserCheckinProvider>(
                    builder: (context, infoProvider, checkinProvider, child) {
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
                                color: checkinProvider.haveCheckinReward ||
                                        checkinProvider.haveAccumulatePlayReward
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
                                      checkinProvider.haveCheckinReward ||
                                              checkinProvider
                                                  .haveAccumulatePlayReward
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
            ],
          ),
        ),
      ),
    );
  }

  Align title() {
    return Align(
      alignment: const Alignment(0.0, -0.9),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.5,
        child: Image.asset(
          'assets/home_page/choosing_game_title.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  AnimatedAlign gameDescription() {
    return AnimatedAlign(
      key: const ValueKey('description'),
      alignment: isChosen.contains(true)
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
                ),
                Expanded(
                  flex: 8,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 0.9,
                    child: AutoSizeText(
                      chosenGame != null
                          ? gameDescriptionString[chosenGame!]
                          : '',
                      style: const TextStyle(
                          fontSize: 1000,
                          color: Colors.black,
                          fontFamily: 'GSR_B'),
                    ),
                  ),
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
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 0.9,
                    child: AutoSizeText(
                      chosenGame != null ? gameTrainingArea[chosenGame!] : '',
                      style: const TextStyle(
                          fontSize: 1000,
                          color: Colors.black,
                          fontFamily: 'GSR_B'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IgnorePointer continueButton() {
    return IgnorePointer(
      ignoring: !_homeTutorial.isTutorial,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_homeTutorial.tutorialProgress < 2) {
              _homeTutorial.tutorialProgress++;
              if (_homeTutorial.tutorialProgress == 1) {
                chosenGame = 0;
                _audioController
                    .playInstructionRecord('tutorial/choose_game.m4a');
                //player.play(AssetSource(
                //    'instruction_record/chinese/tutorial/choose_game.m4a'));
              } else if (_homeTutorial.tutorialProgress == 2) {
                isChosen[0] = true;
                _audioController
                    .playInstructionRecord('tutorial/start_game.m4a');
                //player.play(AssetSource(
                //    'instruction_record/chinese/tutorial/start_game.m4a'));
              }
            } else {
              _audioController.stopAudio();
              Future.delayed(const Duration(milliseconds: 500), () {
                _homeTutorial.tutorialProgress = 0;
              });
              isChosen = List.generate(4, (index) => false);
              _homeTutorial.isTutorial = false;
            }
          });
        },
        child: _homeTutorial.getContinueButton(),
      ),
    );
  }

  AnimatedAlign startButton(BuildContext context) {
    return AnimatedAlign(
      key: const ValueKey('start_button'),
      alignment: isChosen.contains(true)
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
          child: AspectRatio(
            aspectRatio: 835 / 353,
            child: GestureDetector(
              onTap: () {
                final status = context.read<CheckConnectionStatus>();
                if (status.connectionStatus.value == ConnectivityResult.none) {
                  Logger().w('lost connection');
                  lostConnectionDialog(context);
                } else if (!_homeTutorial.isTutorial &&
                    (chosenGame == 0 || chosenGame == 2)) {
                  final audioController = context.read<AudioController>();
                  audioController.stopAudio();
                  String route = gameRoutes[isChosen.indexOf(true)];
                  GoRouter.of(context).push(route);
                }
              },
              child: Stack(
                children: [
                  Center(
                    child: Image.asset('assets/global/continue_button.png'),
                  ),
                  const Center(
                    child: FractionallySizedBox(
                      heightFactor: 0.7,
                      widthFactor: 0.6,
                      child: FittedBox(
                        child: Text(
                          '開始遊戲',
                          style: TextStyle(
                            fontFamily: 'GSR_B',
                            fontSize: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getGameImage(int gameIndex) {
    return AnimatedAlign(
      key: ValueKey(gameIndex),
      alignment: isChosen[gameIndex]
          ? const Alignment(-0.95, 0.0)
          : Alignment(xPositions[gameIndex], 0.4),
      duration: const Duration(milliseconds: 300),
      child: AnimatedFractionallySizedBox(
        widthFactor: isChosen[gameIndex] ? 0.4 : 0.225,
        duration: const Duration(milliseconds: 300),
        child: AspectRatio(
          aspectRatio: 939 / 1054,
          child: DottedBorder(
            color:
                _homeTutorial.tutorialProgress == 1 && gameIndex == chosenGame
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
                  final audioController = context.read<AudioController>();
                  setState(() {
                    if (isChosen.contains(true)) {
                      if (isChosen.indexOf(true) == gameIndex) {
                        isChosen[gameIndex] = false;
                        audioController.stopAudio();
                      }
                    } else {
                      isChosen[gameIndex] = !isChosen[gameIndex];
                      chosenGame = gameIndex;
                      audioController.playGameDescription(gameIndex);
                    }
                  });
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/home_page/choosing_game_banner.png'),
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
                          gameName[gameIndex],
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
                          gameImagePaths[gameIndex],
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
              style: TextStyle(fontFamily: 'GSR_R', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  '確定要登出嗎?\n登出後需要重新登入',
                  style: TextStyle(fontFamily: 'GSR_R', fontSize: 40),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '否',
                style: TextStyle(fontFamily: 'GSR_R', fontSize: 40),
              ),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '是',
                style: TextStyle(fontFamily: 'GSR_R', fontSize: 40),
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
}
