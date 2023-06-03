import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'poker_game_instance.dart';

class PokerGame extends StatefulWidget {
  final startLevel;
  final isTutorial;
  const PokerGame(
      {super.key, required this.startLevel, required this.isTutorial});

  @override
  State<PokerGame> createState() => _PokerGameState();
}

class _PokerGameState extends State<PokerGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosenPlayer;
  late AnimationController _controllerChosenComputer;
  late AnimationController _controllerPlay;
  late GameInstance game;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controllerChosenPlayer = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerChosenComputer = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerPlay = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    game = GameInstance(gameLevel: widget.startLevel);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosenPlayer.dispose();
    _controllerChosenComputer.dispose();
    _controllerPlay.dispose();
    timer?.cancel();
    super.dispose();
  }

  void simulatePlayerAction() {
    int randomTime =
        game.computer.hand.length >= 3 ? 3 : game.computer.hand.length;
    //random 1-3 times choose card
    final int numberOfRandomChoice = Random().nextInt(randomTime) + 1;
    int counter = 0;
    timer =
        Timer.periodic(const Duration(seconds: 1, milliseconds: 500), (timer) {
      setState(() {
        if (counter < numberOfRandomChoice) {
          game.isChosenComputer
              .fillRange(0, game.isChosenComputer.length, false);
          game.isChosenComputer[Random().nextInt(game.computer.hand.length)] =
              true;
          counter++;
        } else {
          timer.cancel();
          isPlayerTurn = true;
          game.computerCard = game.computer.hand
              .removeAt(game.computer.hand.indexWhere((element) => true));
          game.isChosenComputer
              .fillRange(0, game.isChosenComputer.length, false);
          game.start = DateTime.now();
        }
      });
    });
  }

  void roundResult() {
    userInfoProvider.pokerGameDatabase =
        PokerGameDatabase(currentLevel: game.gameLevel, doneTutorial: true);
    _showRoundDialog().then((value) {
      setState(() {
        game.putBack();
        isPlayerTurn = false;
      });
      switch (game.gameLevelChange()) {
        case 0:
          if (game.computer.hand.isEmpty) {
            _showGameEndDialog().then((value) {
              resetBoard();
            });
          } else {
            simulatePlayerAction();
          }
          break;
        case 1:
          Logger().i('level upgrade');
          _showLevelUpgradeDialog().then((value) {
            resetBoard();
          });
          break;
        case 2:
          Logger().i('level downgrade');
          _showLevelDowngradeDialog().then((value) {
            resetBoard();
          });
          break;
      }
    });
  }

  void resetBoard() {
    _controller.reverse().whenComplete(() {
      setState(() {
        game.shuffleBack();
        game.dealCards();
        Timer(const Duration(seconds: 2), () {
          simulatePlayerAction();
        });
      });
      _controller.forward();
    });
  }

  bool isPlayerTurn = false;
  late UserInfoProvider userInfoProvider;

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return DefaultTextStyle(
                style: const TextStyle(fontFamily: 'NotoSansTC_Regular'),
                child: AlertDialog(
                  title: const Center(
                    child: Text(
                      '確定要離開嗎?',
                      style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
                    ),
                  ),
                  // this part can put multiple messages
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Center(
                          child: Text(
                            '遊戲將不會被記錄下來喔!!!',
                            style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        '繼續遊戲',
                        style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text(
                        '確定離開',
                        style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              );
            },
          ).then((value) {
            if (value == true) {
              Navigator.of(context).pop();
            }
          });
          return false;
        },
        child: SizedBox(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/poker_game_scene/play_board.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                exitButton(),
                Align(
                  alignment: const Alignment(0.0, -0.2),
                  child: FractionallySizedBox(
                    heightFactor: 0.2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < game.computer.hand.length; i++) ...[
                          SlideTransition(
                            position: game.isChosenComputer[i]
                                ? Tween(
                                        begin: const Offset(0.0, -0.2),
                                        end: const Offset(0.0, 0.0))
                                    .animate(_controllerChosenComputer)
                                : Tween(
                                        begin: const Offset(0.0, 0.0),
                                        end: const Offset(0.0, -0.2))
                                    .animate(_controllerChosenComputer),
                            child: Image.asset(
                                'assets/poker_game_card/card_back.png',
                                //scale: 5,
                                opacity: Tween(begin: 0.0, end: 1.0)
                                    .chain(CurveTween(
                                        curve: Interval(
                                            i / game.computer.hand.length,
                                            (i + 1) /
                                                game.computer.hand.length)))
                                    .animate(_controller)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                if (game.computerCard != null) ...[
                  Align(
                    alignment: const Alignment(-0.05, 0.25),
                    child: FractionallySizedBox(
                      heightFactor: 0.15,
                      child: Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.identity()
                          ..rotateX(0.5)
                          ..rotateZ(0.5),
                        child: Image.asset(
                          'assets/poker_game_card/${game.computerCard!.suit}_${game.computerCard!.rank}.png',
                        ),
                      ),
                    ),
                  ),
                  if (game.playerCard != null) ...[
                    Align(
                      alignment: const Alignment(0.05, 0.25),
                      child: FractionallySizedBox(
                        heightFactor: 0.15,
                        child: Transform(
                          alignment: FractionalOffset.center,
                          transform: Matrix4.identity()
                            ..rotateX(0.5)
                            ..rotateZ(-0.5),
                          child: Image.asset(
                            'assets/poker_game_card/${game.playerCard!.suit}_${game.playerCard!.rank}.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (isPlayerTurn)
                    Align(
                      alignment: const Alignment(-0.9, 0.2),
                      child: FractionallySizedBox(
                        heightFactor: 0.15,
                        child: AspectRatio(
                          aspectRatio: 835 / 353,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPlayerTurn = false;
                              });
                              Future.delayed(const Duration(seconds: 1), () {
                                game.getResult();
                                roundResult();
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/global/continue_button.png'),
                                ),
                              ),
                              child: const FractionallySizedBox(
                                heightFactor: 0.6,
                                widthFactor: 0.8,
                                child: Center(
                                  child: AutoSizeText(
                                    '沒有',
                                    style: TextStyle(
                                      fontFamily: 'GSR_B',
                                      color: Colors.white,
                                      fontSize: 100,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Align(
                  //   alignment: const Alignment(0.8, 0.25),
                  //   child: FractionallySizedBox(
                  //     heightFactor: 0.15,
                  //     child: AspectRatio(
                  //       aspectRatio: 1,
                  //       child: Image.asset('assets/poker_game_scene/AlarmClock.png'),
                  //     ),
                  //   ),
                  // ),
                ] else
                  Container(),
                if (game.cardDealed)
                  Align(
                    alignment: const Alignment(0.0, 0.8),
                    child: FractionallySizedBox(
                      heightFactor: 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < game.player.hand.length; i++) ...[
                            SlideTransition(
                              position: game.isChosen[i]
                                  ? Tween(
                                          begin: const Offset(0.0, -0.2),
                                          end: const Offset(0.0, 0.0))
                                      .animate(_controllerChosenPlayer)
                                  : Tween(
                                          begin: const Offset(0.0, 0.0),
                                          end: const Offset(0.0, -0.2))
                                      .animate(_controllerChosenPlayer),
                              child: GestureDetector(
                                onTap: () {
                                  if (isPlayerTurn) {
                                    if (!game.isChosen[i]) {
                                      setState(() {
                                        game.isChosen.fillRange(
                                            0, game.isChosen.length, false);
                                        game.isChosen[i] = true;
                                      });
                                    } else {
                                      setState(() {
                                        isPlayerTurn = false;
                                        game.playerCard =
                                            game.player.hand.removeAt(i);
                                        game.isChosen.fillRange(
                                            0, game.isChosen.length, false);
                                      });
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        game.getResult();
                                        roundResult();
                                      });
                                    }
                                  }
                                },
                                child: Image.asset(
                                  'assets/poker_game_card/${game.player.hand[i].suit}_${game.player.hand[i].rank}.png',
                                  opacity: Tween(begin: 0.0, end: 1.0)
                                      .chain(CurveTween(
                                          curve: Interval(
                                              i / game.player.hand.length,
                                              (i + 1) /
                                                  game.player.hand.length)))
                                      .chain(ReverseTween(
                                          Tween(begin: 1.0, end: 0.0)))
                                      .animate(_controller),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: const Alignment(0.0, 0.7),
                    child: FractionallySizedBox(
                      heightFactor: 0.2,
                      child: AspectRatio(
                        aspectRatio: 835 / 353,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              game.dealCards();
                              game.cardDealed = true;
                            });
                            _controller.reset();
                            _controller.forward();
                            Future.delayed(const Duration(seconds: 2),
                                () => simulatePlayerAction());
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/global/continue_button.png'),
                              ),
                            ),
                            child: const FractionallySizedBox(
                              heightFactor: 0.6,
                              widthFactor: 0.8,
                              child: Center(
                                child: AutoSizeText(
                                  '發牌',
                                  style: TextStyle(
                                    fontFamily: 'GSR_B',
                                    color: Colors.white,
                                    fontSize: 100,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  Future<void> _showRoundDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('結果發表'),
          // this part can put multiple messages
          content: game.isTie
              ? const Text('本局平手')
              : game.isPlayerWin
                  ? const Text('你贏得本輪!!!')
                  : const Text('你在本輪落敗'),
          actions: <Widget>[
            TextButton(
              child: const Text('繼續下一輪'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGameEndDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('本局結束'),
          // this part can put multiple messages
          // content: isTie
          //     ? const Text('本局平手')
          //     : isPlayerWin
          //         ? const Text('你贏得遊戲了!!!')
          //         : const Text('真可惜下次努力吧'),
          actions: <Widget>[
            TextButton(
              child: const Text('回到選單'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('繼續下一場遊戲'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLevelUpgradeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('難度提升'),
          content: const Text('連續獲勝五次咯'),
          actions: <Widget>[
            TextButton(
              child: const Text('返回選單'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('重新發牌'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLevelDowngradeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('難度下降'),
          content: const Text('連續落敗五次咯'),
          actions: <Widget>[
            TextButton(
              child: const Text('返回選單'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('重新發牌'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Align exitButton() {
    return Align(
      alignment: const Alignment(-0.95, -0.5),
      child: FractionallySizedBox(
        widthFactor: 0.5 * 1 / 7,
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () {
              //game.isPaused = true;
              _showAlertDialog();
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
        ),
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '確定要離開嗎?',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Center(
                  child: Text(
                    '遊戲將不會被記錄下來喔!!!',
                    style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //game.isPaused = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '確定離開',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
