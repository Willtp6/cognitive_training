import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
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
  int chosenGame = 0;
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
    '想贏得樂透獎金嗎?那就來猜一猜號碼吧!',
    '想贏得樂透獎金嗎?那就來猜一猜號碼吧!',
    '想贏得樂透獎金嗎?那就來猜一猜號碼吧!',
  ];

  List<String> gameRoutes = [
    '/home/lottery_game_menu',
    '/home/fishing_game_menu',
    '/home/poker_game_menu',
    '/home/route_game_menu',
  ];

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    userCheckinProvider = Provider.of<UserCheckinProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: const Text('home page'),
      //   backgroundColor: Colors.blue[400],
      //   elevation: 0.0,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/global/login_background_1.jpeg'),
            fit: BoxFit.fitWidth,
          ),
        ),
        /*child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/home/lottery_game_menu');
                },
                child: const Text(
                  'Lottery game',
                  style: TextStyle(
                      fontSize: 40, color: Colors.white, fontFamily: 'GSR_B'),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/home/poker_game_menu');
                },
                child: const Text(
                  'Poker game',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              Consumer2<UserInfoProvider, UserCheckinProvider>(
                  builder: (context, infoProvider, checkinProvider, child) {
                return IconButton(
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
                );
              }),
              /*const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  userInfoProvider.coins += 100;
                },
                child: const Text(
                  '++',
                  style: TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 40),
              Consumer<UserInfoProvider>(
                builder: (context, userInfoProvider, child) {
                  return userInfoProvider.fileFunctionNormally
                      ? Column(
                          children: [
                            Text(
                              "持有硬幣: ${userInfoProvider.coins}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 40),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator();
                },
              ),
              const SizedBox(
                height: 40,
              ),
              Consumer<UserCheckinProvider>(
                builder: (context, userCheckinProvider, child) {
                  return Column(
                    children: [
                      Text(
                        'Test: ${userCheckinProvider.test}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 40),
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  userCheckinProvider.test++;
                },
                child: const Text('++test'),
              ),*/
            ],
          ),
        ),*/
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0.0, -0.9),
              child: FractionallySizedBox(
                heightFactor: 0.15,
                child: Image.asset('assets/home_page/choosing_game_title.png'),
              ),
            ),
            for (int i = 0; i < 4; i++) ...[
              // if (!isChosen[i]) ...[
              //   getGameImage(i),
              // ],
              if (i != chosenGame) ...[
                getGameImage(i),
              ],
            ],
            AnimatedAlign(
              key: const ValueKey(1123),
              alignment: isChosen.contains(true)
                  ? const Alignment(0.8, -0.3)
                  : const Alignment(3.0, -0.3),
              duration: const Duration(milliseconds: 300),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    widthFactor: 0.8,
                    heightFactor: 0.8,
                    child: AutoSizeText(
                      gameDescription[
                          isChosen.contains(true) ? isChosen.indexOf(true) : 0],
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'GSR_B',
                        fontSize: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              key: const ValueKey(225),
              alignment: isChosen.contains(true)
                  ? const Alignment(0.5, 0.95)
                  : const Alignment(0.5, 3.0),
              duration: const Duration(milliseconds: 300),
              child: FractionallySizedBox(
                widthFactor: 0.2,
                heightFactor: 0.15,
                child: GestureDetector(
                  onTap: () {
                    Logger().i('tap');
                    GoRouter.of(context)
                        .push(gameRoutes[isChosen.indexOf(true)]);
                  },
                  child: Stack(
                    children: [
                      Center(
                          child:
                              Image.asset('assets/home_page/start_button.png')),
                      const Center(
                        child: FractionallySizedBox(
                          heightFactor: 0.7,
                          widthFactor: 0.7,
                          child: FittedBox(
                            child: Text('開始遊戲',
                                style: TextStyle(
                                    fontFamily: 'GSR_B', fontSize: 100)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // if (isChosen.contains(true)) ...[
            //   getGameImage(isChosen.indexOf(true)),
            // ],
            getGameImage(chosenGame)
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            //   child: Consumer<UserInfoProvider>(
            //     builder: (context, userInfoProvider, child) {
            //       return Text(
            //         "Coins you have: ${userInfoProvider.coins}",
            //         style: const TextStyle(color: Colors.pink, fontSize: 20),
            //       );
            //     },
            //   ),
            // ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                '登出',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
              ),
              onTap: () async {
                _showAlertDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                '登出',
                style: TextStyle(fontFamily: 'GSR_R', fontSize: 40),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget getGameImage(int gameIndex) {
    return AnimatedAlign(
      key: ValueKey(gameIndex),
      alignment: isChosen[gameIndex]
          ? const Alignment(-0.9, 0.0)
          : Alignment(xPositions[gameIndex], 0.2),
      duration: const Duration(milliseconds: 300),
      child: AnimatedFractionallySizedBox(
        heightFactor: isChosen[gameIndex] ? 0.9 : 0.5,
        widthFactor: isChosen[gameIndex] ? 0.4 : 0.2,
        duration: const Duration(milliseconds: 300),
        child: Center(
          child: AspectRatio(
            aspectRatio: 939 / 1054,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / 939 * 1054,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isChosen.contains(true)) {
                          if (isChosen.indexOf(true) == gameIndex) {
                            isChosen[gameIndex] = !isChosen[gameIndex];
                          }
                        } else {
                          isChosen[gameIndex] = !isChosen[gameIndex];
                          chosenGame = gameIndex;
                        }
                      });
                      //GoRouter.of(context).push('/home/lottery_game_menu');
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
                            child: LayoutBuilder(builder: (BuildContext context,
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
                            widthFactor: 0.89,
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
    );
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout ?'),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Once you log out you\'ll need to login again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
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

/*class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'test',
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/login_reward/reward_background.png'),
              fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class AccumulatePlayDialog extends StatelessWidget {
  const AccumulatePlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [Image.asset('assets/login_reward/reward_background.png')],
      ),
    );
  }
}

class CheckinDialog extends StatelessWidget {
  final List<bool> checkin;
  const CheckinDialog({super.key, required this.checkin});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.height;
    final seperateSize = width * 0.05;
    final iconSize = width * 0.13;
    final fontSize = width * 0.05;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.brown[100],
      child: Container(
        padding: EdgeInsets.all(seperateSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '連 續 登 入',
                style: TextStyle(
                    fontSize: fontSize * 2,
                    color: Colors.blue,),
              ),
            ),
            SizedBox(height: seperateSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 4; i++) ...[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange[100]),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: iconSize,
                              color: Colors.orange,
                            ),
                            Opacity(
                              opacity: checkin[i - 1] ? 1 : 0,
                              child: Icon(
                                Icons.check,
                                size: iconSize,
                              ),
                            ),
                          ],
                        ),
                        Text('+${i}00',
                            style: TextStyle(
                              fontSize: fontSize,
                            )),
                      ],
                    ),
                  ),
                  if (i != 4) SizedBox(width: seperateSize),
                ],
              ],
            ),
            SizedBox(height: seperateSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 5; i <= 7; i++) ...[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: iconSize,
                              color: Colors.yellow,
                            ),
                            Opacity(
                              opacity: checkin[i - 1] ? 1 : 0,
                              child: Icon(
                                Icons.check,
                                size: iconSize,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '+${i}00',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  ),
                  if (i != 7) SizedBox(width: seperateSize),
                ],
              ],
            ),
            SizedBox(height: seperateSize),
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '關 閉',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize,),
                )),
          ],
        ),
      ),
    );
  }
}
*/
