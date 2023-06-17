import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
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
  final responseTimeList;
  const PokerGame(
      {super.key,
      required this.startLevel,
      required this.isTutorial,
      required this.responseTimeList});

  @override
  State<PokerGame> createState() => _PokerGameState();
}

class _PokerGameState extends State<PokerGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosenPlayer;
  late AnimationController _controllerChosenComputer;
  late AnimationController _controllerPlay;
  late GameInstance game;
  late AudioController audioController;
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
    game = GameInstance(
      gameLevel: widget.startLevel,
      responseTimeList: widget.responseTimeList,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosenPlayer.dispose();
    _controllerChosenComputer.dispose();
    _controllerPlay.dispose();
    timer?.cancel();
    audioController.stopAudio();
    super.dispose();
  }

  void simulatePlayerAction() {
    int randomTime =
        game.computer.hand.length >= 3 ? 3 : game.computer.hand.length;
    //random 1-3 times choose card
    final int numberOfRandomChoice = Random().nextInt(randomTime) + 1;
    int counter = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _showRoundDialog().then((value) {
      setState(() {
        game.putBack();
        showWord = false;
        game.backgroundPath = 'assets/poker_game_scene/play_board.png';
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
            setState(() {
              game.cardDealed = false;
              String path =
                  game.gameLevel < 1 ? 'find_bigger.m4a' : 'find_the_same.m4a';
              audioController.playInstructionRecord('poker_game/$path');
            });
          });
          break;
        case 2:
          Logger().i('level downgrade');
          _showLevelDowngradeDialog().then((value) {
            setState(() {
              game.cardDealed = false;
              String path =
                  game.gameLevel < 1 ? 'find_bigger.m4a' : 'find_the_same.m4a';
              audioController.playInstructionRecord('poker_game/$path');
            });
          });
          break;
      }
      userInfoProvider.pokerGameDatabase = PokerGameDatabase(
        currentLevel: game.gameLevel,
        doneTutorial: true,
        responseTimeList: game.responseTimeList,
      );
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

  void startGame() {
    setState(() {
      game.dealCards();
      game.cardDealed = true;
    });
    _controller.reset();
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () => simulatePlayerAction());
  }

  void timeLimitExceeded() {
    Logger().d('time limit');
    setState(() {
      isPlayerTurn = false;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        game.isTie = false;
        game.isPlayerWin = false;
        String path;
        userInfoProvider.coins -= game.coinLose[game.gameLevel];
        game.changeOpponentCoin();
        game.continuousWinLose();
        game.end = DateTime.now();
        game.recordGame();
        path = 'player_lose.mp3';
        audioController.playPokerGameSoundEffect(path);
        game.backgroundPath = 'assets/poker_game_scene/player_lose.png';
        showWord = true;
      });
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      roundResult();
    });
  }

  bool isPlayerTurn = false;
  bool showWord = false;
  late UserInfoProvider userInfoProvider;

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    audioController = context.read<AudioController>();
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          audioController.pauseAudio();
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
                        audioController.resumeAudio();
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
        child: Scaffold(
          body: SizedBox(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(game.backgroundPath),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  exitButton(),
                  opponentCoin(),
                  playerCoin(),
                  Align(
                    alignment: const Alignment(0.0, -0.2),
                    child: FractionallySizedBox(
                      heightFactor: 0.2,
                      widthFactor: 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0;
                              i < game.computer.hand.length;
                              i++) ...[
                            Flexible(
                              child: SlideTransition(
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
                                    opacity: Tween(begin: 0.0, end: 1.0)
                                        .chain(CurveTween(
                                            curve: Interval(
                                                i / game.computer.hand.length,
                                                (i + 1) /
                                                    game.computer.hand.length)))
                                        .animate(_controller)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      ignoring: game.cardDealed,
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: RuleScreen(
                          game: game,
                          audioController: audioController,
                          callback: startGame,
                        ),
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
                    if (isPlayerTurn) ...[
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
                                settlement();
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
                      AlarmClock(
                        timeInMilliSeconds: game.getTimeLimit(),
                        audioController: audioController,
                        callback: timeLimitExceeded,
                      ),
                    ],
                  ] else ...[
                    Container(),
                  ],
                  if (game.cardDealed) ...[
                    Align(
                      alignment: const Alignment(0.0, 0.8),
                      child: FractionallySizedBox(
                        heightFactor: 0.25,
                        widthFactor: 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0;
                                i < game.player.hand.length;
                                i++) ...[
                              Flexible(
                                child: SlideTransition(
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
                                          settlement();
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
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (showWord) ...[
                    Align(
                      alignment: const Alignment(-0.6, -0.5),
                      child: FractionallySizedBox(
                        heightFactor: 0.25,
                        widthFactor: 0.3,
                        child: AspectRatio(
                          aspectRatio: 1077 / 352,
                          child: Image.asset(game.isPlayerWin
                              ? 'assets/poker_game_scene/win_word.png'
                              : 'assets/poker_game_scene/lose_word.png'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void settlement() {
    audioController.stopAudio();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        game.getResult();
        String path;
        if (game.isPlayerWin) {
          userInfoProvider.coins += game.coinWin[game.gameLevel];
          path = 'player_win.wav';
          audioController.playPokerGameSoundEffect(path);
          game.backgroundPath = 'assets/poker_game_scene/player_win.png';
          showWord = true;
        } else {
          if (!game.isTie) {
            userInfoProvider.coins -= game.coinLose[game.gameLevel];
            path = 'player_lose.mp3';
            audioController.playPokerGameSoundEffect(path);
            game.backgroundPath = 'assets/poker_game_scene/player_lose.png';
            showWord = true;
          }
        }
      });
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      roundResult();
    });
  }

  Align playerCoin() {
    return Align(
      alignment: const Alignment(0.65, -0.825),
      child: FractionallySizedBox(
        heightFactor: 0.08,
        widthFactor: 0.1,
        child: Consumer<UserInfoProvider>(builder: (context, provider, child) {
          return Center(
            child: AutoSizeText(
              provider.coins.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'GSR_B',
                fontSize: 100,
              ),
              textAlign: TextAlign.end,
            ),
          );
        }),
      ),
    );
  }

  Align opponentCoin() {
    return Align(
      alignment: const Alignment(-0.625, -0.825),
      child: FractionallySizedBox(
        heightFactor: 0.08,
        widthFactor: 0.1,
        child: Center(
          child: AutoSizeText(
            game.opponentCoin.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'GSR_B',
              fontSize: 100,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
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

  Future<void> _showRoundDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '結果發表',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: Center(
              child: game.isTie
                  ? const Text(
                      '本局平手',
                      style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                    )
                  : game.isPlayerWin
                      ? const Text(
                          '你贏得本輪!!!',
                          style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                        )
                      : const Text(
                          '你在本輪落敗',
                          style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                        ),
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text(
                  '繼續下一輪',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
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
          title: const Center(
              child: Text('本局結束',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 40))),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '回到選單',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '繼續下一場遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
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
          title: const Center(
              child: Text(
            '難度提升',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          )),
          content: const SingleChildScrollView(
            child: Center(
              child: Text(
                '連續獲勝五次咯',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '返回選單',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                game.shuffleBack();
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
          title: const Center(
              child: Text(
            '難度下降',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          )),
          content: const SingleChildScrollView(
            child: Center(
              child: Text(
                '連續落敗五次咯',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '返回選單',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                game.shuffleBack();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertDialog() async {
    audioController.pauseAudio();
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
                audioController.resumeAudio();
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

class RuleScreen extends StatefulWidget {
  const RuleScreen({
    super.key,
    required this.game,
    required this.audioController,
    required this.callback,
  });

  final GameInstance game;
  final AudioController audioController;
  final Function() callback;

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  List<Alignment> starPosition = [
    const Alignment(-0.9, -0.5),
    const Alignment(-0.3, -0.5),
    const Alignment(0.3, -0.5),
    const Alignment(0.9, -0.5),
  ];
  String starLight = 'assets/global/star_light.png';
  String starDark = 'assets/global/star_dark.png';
  AutoSizeText getBigger = const AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請從牌中挑選出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '比我數字還大', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的牌！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '只要你在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(text: '找到這張牌就是你贏了！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: '如果牌裡面沒有比我數字還大的牌，請按下', style: TextStyle(color: Colors.black)),
        TextSpan(text: '「沒有」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的按鈕！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  AutoSizeText getSameRankOrSuit = const AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請從牌中挑選出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '數字或花色一樣', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的牌！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '只要你在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(text: '找到這張牌就是你贏了！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: '如果牌裡面沒有跟我一樣數字或花色的牌，請按下',
            style: TextStyle(color: Colors.black)),
        TextSpan(text: '「沒有」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的按鈕！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  AutoSizeText getSizeRule = const AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '比大小規則:', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '黑桃>愛心>方塊>梅花', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: 'A>K>Q>J>10>9>8>7>6>5>4>3>2',
            style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 3,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  List<String> difficulties = ['一', '二', '三', '四'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String path =
          widget.game.gameLevel <= 1 ? 'find_bigger.m4a' : 'find_the_same.m4a';
      widget.audioController.playInstructionRecord('poker_game/$path');
    });
  }

  bool questionTapped = false;
  String questionButtonPath = 'assets/poker_game_scene/question_light.png';

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.game.cardDealed ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border.all(
              color: Colors.blue,
              width: 5,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.3,
                  child: Stack(
                    children: [
                      for (int i = 0; i < 4; i++) ...[
                        Align(
                          alignment: starPosition[i],
                          child: FractionallySizedBox(
                            widthFactor: 0.2,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(i <= widget.game.gameLevel
                                  ? starLight
                                  : starDark),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Align(
              //   alignment: const Alignment(0.0, -0.2),
              //   child: FractionallySizedBox(
              //     heightFactor: 0.1,
              //     child: AutoSizeText(
              //       '難度${difficulties[game.gameLevel]}',
              //       style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              // ),
              Align(
                alignment: const Alignment(0.0, 0.2),
                child: FractionallySizedBox(
                  heightFactor: 0.5,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: questionTapped
                        ? Center(
                            child: FractionallySizedBox(
                              heightFactor: 0.7,
                              widthFactor: 0.8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 3,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                child: Center(child: getSizeRule),
                              ),
                            ),
                          )
                        : Center(
                            child: widget.game.gameLevel <= 1
                                ? getBigger
                                : getSameRankOrSuit,
                          ),
                  ),
                ),
              ),
              if (widget.game.gameLevel <= 1) ...[
                Align(
                  alignment: const Alignment(0.9, -0.3),
                  child: FractionallySizedBox(
                    widthFactor: 0.1,
                    child: GestureDetector(
                      onTapDown: (_) {
                        questionButtonPath =
                            'assets/poker_game_scene/question_dark.png';
                        setState(() => questionTapped = true);
                      },
                      onTapUp: (_) {
                        questionButtonPath =
                            'assets/poker_game_scene/question_light.png';
                        setState(() => questionTapped = false);
                      },
                      onPanEnd: (_) {
                        questionButtonPath =
                            'assets/poker_game_scene/question_light.png';
                        setState(() => questionTapped = false);
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(questionButtonPath),
                      ),
                    ),
                  ),
                ),
              ],
              Align(
                alignment: const Alignment(0.0, 0.9),
                child: FractionallySizedBox(
                  heightFactor: 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 835 / 353,
                            child: GestureDetector(
                              onTap: () {
                                String path = widget.game.gameLevel <= 1
                                    ? 'find_bigger.m4a'
                                    : 'find_the_same.m4a';
                                widget.audioController
                                    .playInstructionRecord('poker_game/$path');
                              },
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/global/continue_button.png',
                                    ),
                                  ),
                                  const Center(
                                    child: FractionallySizedBox(
                                      heightFactor: 0.8,
                                      widthFactor: 0.8,
                                      child: Center(
                                        child: AutoSizeText(
                                          '再聽一次',
                                          style: TextStyle(
                                            fontFamily: 'GSR_B',
                                            fontSize: 100,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 835 / 353,
                            child: GestureDetector(
                              onTap: () {
                                widget.audioController.stopAudio();
                                widget.callback();
                              },
                              child: Image.asset(
                                'assets/lottery_game_scene/start_button.png',
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmClock extends StatefulWidget {
  const AlarmClock(
      {super.key,
      required this.timeInMilliSeconds,
      required this.audioController,
      required this.callback});

  final int timeInMilliSeconds;
  final AudioController audioController;
  final Function() callback;

  @override
  State<AlarmClock> createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
    startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    if (widget.timeInMilliSeconds >= 3000) {
      _timer =
          Timer(Duration(milliseconds: widget.timeInMilliSeconds - 3000), () {
        widget.audioController.playPokerGameSoundEffect('tictoc.mp3');
        _controller.forward().whenComplete(() {
          widget.audioController.stopAudio();
          widget.callback();
        });
      });
    } else {
      _controller.forward();
      widget.audioController.playPokerGameSoundEffect('tictoc.mp3');
      _timer = Timer(Duration(milliseconds: widget.timeInMilliSeconds), () {
        _controller.reset();
        widget.audioController.stopAudio();
        widget.callback();
      });
    }
  }

  int getAngle(double value) {
    int stamp = value.toInt();
    if (stamp == 1 || stamp == 5 || stamp == 9) {
      return 1;
    } else if (stamp == 3 || stamp == 7) {
      return -1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.85, -0.25),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: getAngle(animation.value) * 2 * pi / 40,
                child: Opacity(
                    opacity: animation.value > 0 ? 1 : 0,
                    child: Image.asset(
                      'assets/poker_game_scene/AlarmClock.png',
                    )),
              );
            },
          ),
        ),
      ),
    );
  }
}
