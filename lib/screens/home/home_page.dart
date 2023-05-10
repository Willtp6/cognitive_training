import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final AuthService _authService = AuthService();
  late UserInfoProvider userInfoProvider;
  late UserCheckinProvider userCheckinProvider;
  bool expanded = false;

  List<bool> isChosen = [false, false, false, false];
  List<double> xPositions = [-0.9, -0.3, 0.3, 0.9];
  int? chosenGame = 0;
  String chosenLanguage = '中文';
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
  List<String> gameDescription = [
    '想贏得樂透獎金嗎?那就來猜一猜號碼吧!',
    '遊戲暫未開放',
    '遊戲暫未開放',
    '遊戲暫未開放',
  ];
  List<String> gameRoutes = [
    '/home/lottery_game_menu',
    '/home/fishing_game_menu',
    '/home/poker_game_menu',
    '/home/route_game_menu',
  ];
  bool isTutorial = false;
  int tutorialProgress = 0;
  List<String> tutorialMessage = [
    '我是小幫手，現在要選擇想玩的遊戲!',
    '點選想玩的遊戲，會出現遊戲的介紹及訓練內容',
    '最後按下開始遊戲，就可以開始囉!',
  ];
  List<String> arrowPath = [
    'assets/home_page/tutorial_left_arrow.png',
    'assets/home_page/tutorial_right_arrow.png',
  ];
  List<Alignment> arrowAlignment = [
    const Alignment(-0.4, 0.0),
    const Alignment(0.0, 1.0)
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    userCheckinProvider = Provider.of<UserCheckinProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              margin: const EdgeInsets.only(bottom: 50),
              child: Consumer<UserInfoProvider>(
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
                  '中文',
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
                  });
                },
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
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
            Align(
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
                            padding: const EdgeInsets.all(8.0),
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
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Consumer2<UserInfoProvider,
                                      UserCheckinProvider>(
                                  builder: (context, infoProvider,
                                      checkinProvider, child) {
                                return IconButton(
                                  iconSize: 100,
                                  onPressed: () {
                                    GoRouter.of(context).push('/home/reward');
                                  },
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: checkinProvider.haveCheckinReward ||
                                            checkinProvider
                                                .haveAccumulatePlayReward
                                        ? Colors.amber
                                        : Colors.black,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // title
            Align(
              alignment: const Alignment(0.0, -0.9),
              child: FractionallySizedBox(
                heightFactor: 0.15,
                widthFactor: 0.5,
                child: Image.asset(
                  'assets/home_page/choosing_game_title.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            //tutorial button
            AnimatedOpacity(
              opacity: isTutorial ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              child: Align(
                alignment: const Alignment(1.0, -0.85),
                child: Padding(
                  padding: EdgeInsets.only(right: width * 0.05),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isChosen = List.generate(4, (index) => false);
                        chosenGame = null;
                        isTutorial = true;
                      });
                    },
                    child: SizedBox(
                      width: width * 0.15,
                      height: width * 0.15 * 236 / 578,
                      child:
                          Image.asset('assets/login_page/tutorial_button.png'),
                    ),
                  ),
                ),
              ),
            ),
            for (int i = 0; i < 4; i++) ...[
              if (i != chosenGame) ...[
                getGameImage(i),
              ],
            ],
            if (isTutorial) ...[
              Container(
                color: Colors.white.withOpacity(0.7),
              ),
            ],
            // game description
            AnimatedAlign(
              key: const ValueKey('description'),
              alignment: isChosen.contains(true)
                  ? const Alignment(0.85, -0.4)
                  : const Alignment(4.0, -0.4),
              duration: const Duration(milliseconds: 300),
              child: FractionallySizedBox(
                widthFactor: 0.55,
                heightFactor: 0.65,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    border: Border.all(color: Colors.black, width: 5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.center,
                    widthFactor: 0.6,
                    heightFactor: 0.6,
                    child: AutoSizeText(
                      chosenGame != null ? gameDescription[chosenGame!] : '',
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'GSR_B',
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              key: const ValueKey('start_button'),
              alignment: isChosen.contains(true)
                  ? const Alignment(0.5, 0.9)
                  : const Alignment(0.5, 3.0),
              duration: const Duration(milliseconds: 300),
              child: FractionallySizedBox(
                widthFactor: 0.2,
                heightFactor: 0.2,
                child: DottedBorder(
                  color: tutorialProgress == 2
                      ? Colors.red
                      : Colors.white.withOpacity(0),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  padding: const EdgeInsets.all(1),
                  strokeCap: StrokeCap.round,
                  child: GestureDetector(
                    onTap: () {
                      if (!isTutorial) {
                        String route = gameRoutes[isChosen.indexOf(true)];
                        GoRouter.of(context).push(route);
                      }
                    },
                    child: Stack(
                      children: [
                        Center(
                          child:
                              Image.asset('assets/global/continue_button.png'),
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
            if (chosenGame != null) getGameImage(chosenGame!),
            // tutorial doctor
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: isTutorial ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Align(
                  alignment: tutorialProgress < 2
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Container(
                    height: height * 0.4,
                    width: width * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/login_page/tutorial_doctors.png',
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // chat bubble
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: isTutorial ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Align(
                  alignment: tutorialProgress < 2
                      ? const Alignment(1, -0.9)
                      : const Alignment(-1, -0.9),
                  child: Container(
                    height: height * 0.65,
                    width: height * 0.65,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/login_page/tutorial_chat_bubble.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Align(
                      alignment: const Alignment(0, -0.2),
                      child: FractionallySizedBox(
                        heightFactor: 0.4,
                        widthFactor: 0.6,
                        child: Align(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            tutorialMessage[tutorialProgress],
                            maxLines: 4,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 100,
                              fontFamily: 'GSR_R',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isTutorial && tutorialProgress >= 1)
              Align(
                alignment: arrowAlignment[tutorialProgress - 1],
                child: FractionallySizedBox(
                  heightFactor: 0.3,
                  child: Image.asset(arrowPath[tutorialProgress - 1]),
                ),
              ),
            //continue button
            IgnorePointer(
              ignoring: !isTutorial,
              child: getContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedOpacity getContinueButton() {
    return AnimatedOpacity(
      opacity: isTutorial ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: tutorialProgress < 2
            ? const Alignment(0.5, 0.9)
            : const Alignment(-0.5, 0.9),
        child: FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 0.2,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (tutorialProgress < 2) {
                  tutorialProgress++;
                  if (tutorialProgress == 1) {
                    chosenGame = 0;
                  } else if (tutorialProgress == 2) {
                    isChosen[0] = true;
                  }
                } else {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    tutorialProgress = 0;
                  });
                  isChosen = List.generate(4, (index) => false);
                  isTutorial = false;
                }
              });
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
                        '點我繼續',
                        style: TextStyle(
                          fontFamily: 'GSR_B',
                          fontSize: 100,
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
    );
  }

  Widget getGameImage(int gameIndex) {
    return AnimatedAlign(
      key: ValueKey(gameIndex),
      alignment: isChosen[gameIndex]
          ? const Alignment(-0.95, 0.0)
          : Alignment(xPositions[gameIndex], 0.2),
      duration: const Duration(milliseconds: 300),
      child: AnimatedFractionallySizedBox(
        heightFactor: isChosen[gameIndex] ? 0.9 : 0.5,
        widthFactor: isChosen[gameIndex] ? 0.4 : 0.2,
        duration: const Duration(milliseconds: 300),
        child: Center(
          child: AspectRatio(
            aspectRatio: 939 / 1054,
            child: DottedBorder(
              color: tutorialProgress == 1 && gameIndex == chosenGame
                  ? Colors.red
                  : Colors.white.withOpacity(0),
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              strokeWidth: 2,
              dashPattern: const [8, 4],
              padding: const EdgeInsets.all(10),
              strokeCap: StrokeCap.round,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxWidth / 939 * 1054,
                    child: GestureDetector(
                      onTap: () {
                        if (!isTutorial) {
                          setState(() {
                            if (isChosen.contains(true)) {
                              if (isChosen.indexOf(true) == gameIndex) {
                                isChosen[gameIndex] = false;
                              }
                            } else {
                              isChosen[gameIndex] = !isChosen[gameIndex];
                              chosenGame = gameIndex;
                            }
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                                'assets/home_page/choosing_game_banner.png'),
                          ),
                          Align(
                            alignment: const Alignment(0.0, -0.8),
                            child: FractionallySizedBox(
                              heightFactor: 0.3,
                              widthFactor: 0.9,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                return Center(
                                  child: Text(
                                    gameName[gameIndex],
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth / 4.5),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0.0, 0.7),
                            child: FractionallySizedBox(
                              widthFactor: 0.885,
                              child: Image.asset(
                                gameImagePaths[gameIndex],
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
}
