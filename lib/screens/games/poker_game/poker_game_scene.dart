import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'poker_game_instance.dart';
import 'poker_game_tutorial.dart';
import '../../../shared/button_with_text.dart';

class PokerGameScene extends StatefulWidget {
  PokerGameScene(
      {super.key,
      required this.startLevel,
      required this.isTutorial,
      required this.responseTimeList});
  final int startLevel;
  bool isTutorial;
  var responseTimeList;
  @override
  State<PokerGameScene> createState() => _PokerGameStateScene();
}

class _PokerGameStateScene extends State<PokerGameScene>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosenPlayer;
  late AnimationController _controllerChosenComputer;
  late AnimationController _controllerChangeMoney;
  late GameInstance game;
  late AudioController audioController;
  Timer? timer;
  bool isPlayerTurn = false;
  bool showWord = false;
  late UserInfoProvider userInfoProvider;
  final PokerGameTutorial _pokerGameTutorial = PokerGameTutorial();

  String playerCoinChange = "";
  String opponentCoinChange = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    _controllerChangeMoney = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    game = GameInstance(
      gameLevel: widget.startLevel,
      responseTimeList: widget.responseTimeList,
      isTutorial: widget.isTutorial,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosenPlayer.dispose();
    _controllerChosenComputer.dispose();
    _controllerChangeMoney.dispose();
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
              .removeAt(game.isChosenComputer.indexWhere((element) => true));
          game.isChosenComputer
              .fillRange(0, game.isChosenComputer.length, false);
          game.start = DateTime.now();
        }
      });
    });
  }

  void roundResult() {
    setState(() {
      game.putBack();
      showWord = false;
      game.backgroundPath = 'assets/poker_game/scene/play_board.png';
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
            String path = game.getRulePath();
            audioController.playInstructionRecord('poker_game/$path');
          });
        });
        break;
      case 2:
        Logger().i('level downgrade');
        _showLevelDowngradeDialog().then((value) {
          setState(() {
            game.cardDealed = false;
            String path = game.getRulePath();
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
    setState(() {
      isPlayerTurn = false;
      game.isChosen.fillRange(0, game.isChosen.length, false);
      playerCoinChange = "-${game.coinLose[game.gameLevel]}";
      opponentCoinChange = "+${game.coinWin[game.gameLevel]}";
    });
    // _controller.forward();
    _controllerChangeMoney.reset();
    _controllerChangeMoney.forward();
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        game.isTie = false;
        game.isPlayerWin = false;
        userInfoProvider.coins -= game.coinLose[game.gameLevel];
        game.opponentCoin += game.coinWin[game.gameLevel];
        // game.changeOpponentCoin();
        game.continuousWinLose();
        game.recordGame();
        audioController.playPokerGameSoundEffect('player_lose.mp3');
        game.backgroundPath = 'assets/poker_game/scene/player_lose.png';
        showWord = true;
      });
    });
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      roundResult();
    });
  }

  void settlement() {
    audioController.stopAudio();
    game.getResult();
    setState(() {
      if (game.isPlayerWin) {
        playerCoinChange = "+${game.coinWin[game.gameLevel]}";
        opponentCoinChange = "-${game.coinLose[game.gameLevel]}";
        _controllerChangeMoney.reset();
        _controllerChangeMoney.forward();
      } else if (!game.isTie) {
        playerCoinChange = "-${game.coinLose[game.gameLevel]}";
        opponentCoinChange = "+${game.coinWin[game.gameLevel]}";
        _controllerChangeMoney.reset();
        _controllerChangeMoney.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        String path;
        if (game.isPlayerWin) {
          userInfoProvider.coins += game.coinWin[game.gameLevel];
          game.opponentCoin -= game.coinLose[game.gameLevel];
          path = 'player_win.wav';
          audioController.playPokerGameSoundEffect(path);
          game.backgroundPath = 'assets/poker_game/scene/player_win.png';
          showWord = true;
        } else {
          if (!game.isTie) {
            userInfoProvider.coins -= game.coinLose[game.gameLevel];
            game.opponentCoin += game.coinWin[game.gameLevel];
            path = 'player_lose.mp3';
            audioController.playPokerGameSoundEffect(path);
            game.backgroundPath = 'assets/poker_game/scene/player_lose.png';
            showWord = true;
          }
        }
      });
    });
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      roundResult();
    });
  }

  void nextTutorialProgress() {
    setState(() {
      switch (_pokerGameTutorial.tutorialProgress) {
        case 0:
        case 1:
        case 2:
          break;
        case 3:
          setState(() {
            game.dealCards();
            game.cardDealed = true;
            _controller.reset();
            _controller.forward();
          });
          break;
        case 4:
          setState(() {
            isPlayerTurn = true;
            game.computerCard = game.computer.hand.removeAt(0);
          });
          break;
        case 5:
          setState(() {
            game.playerCard = game.player.hand.removeAt(0);
          });
          break;
        case 6:
          setState(() {
            isPlayerTurn = false;
          });
          break;
        case 7:
          _showTutorialEndDialog();
          break;
      }
    });
  }

  void emptyFunction() {}

  bool isTutorialModePop() {
    return game.isTutorial;
  }

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    audioController = context.read<AudioController>();
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          audioController.pauseAudio();
          if (isTutorialModePop()) {
            return await _showSkipTutorialDialog();
          } else {
            return await _showAlertDialog();
          }
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
                  opponentCoin(),
                  playerCoin(),
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress <= 3) ...[
                    Container(
                      color: Colors.white.withOpacity(0.7),
                    )
                  ],
                  RuleScreen(
                    game: game,
                    audioController: audioController,
                    pokerGameTutorial: _pokerGameTutorial,
                    callback: startGame,
                  ),
                  computerHandCard(),
                  if (game.computerCard != null) ...[
                    computerChosenCard(game.computerCard!),
                  ],
                  if (game.playerCard != null) ...[
                    playerChosenCard(game.playerCard!),
                  ],
                  if (isPlayerTurn) ...[
                    noCardButton(),
                    if (widget.isTutorial &&
                        (_pokerGameTutorial.tutorialProgress == 4 ||
                            _pokerGameTutorial.tutorialProgress == 5)) ...[
                      Container(
                        color: Colors.white.withOpacity(0.7),
                      )
                    ],
                    AlarmClock(
                      timeInMilliSeconds:
                          game.isTutorial ? 2000 : game.getTimeLimit(),
                      audioController: audioController,
                      isTutorial: game.isTutorial,
                      callback:
                          game.isTutorial ? emptyFunction : timeLimitExceeded,
                    ),
                    if (game.isChosen.contains(true))
                      Align(
                        child: FractionallySizedBox(
                          heightFactor: 0.15,
                          child: ButtonWithText(
                            text: '確定',
                            onTapFunction: chooseCard,
                          ),
                        ),
                      )
                  ],
                  playerHandCard(),
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress == 6) ...[
                    Container(
                      color: Colors.white.withOpacity(0.7),
                    )
                  ],
                  if (showWord) ...[
                    responseWord(),
                  ],
                  OpponentCoinAnimation(
                      controller: _controllerChangeMoney,
                      string: opponentCoinChange),
                  PlayerCoinAnimation(
                      controller: _controllerChangeMoney,
                      string: playerCoinChange),
                  exitButton(),
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress < 7) ...[
                    if (_pokerGameTutorial.tutorialProgress < 6) ...[
                      _pokerGameTutorial.dottedLineContainer(),
                      _pokerGameTutorial.hintArrow(),
                    ],
                    _pokerGameTutorial.tutorialDoctor(),
                    _pokerGameTutorial.chatBubble(),
                    _pokerGameTutorial.getContinueButton(nextTutorialProgress),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align computerChosenCard(PokerCard card) {
    return Align(
      alignment: const Alignment(-0.05, 0.25),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..rotateX(0.5)
            ..rotateZ(0.5),
          child: Image.asset(
            'assets/poker_game/card/${card.suit}_${card.rank}.png',
          ),
        ),
      ),
    );
  }

  Align playerChosenCard(PokerCard card) {
    return Align(
      alignment: const Alignment(0.05, 0.25),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..rotateX(0.5)
            ..rotateZ(-0.5),
          child: Image.asset(
            'assets/poker_game/card/${card.suit}_${card.rank}.png',
          ),
        ),
      ),
    );
  }

  void chooseCard() {
    setState(() {
      isPlayerTurn = false;
      game.playerCard = game.player.hand.removeAt(game.isChosen.indexOf(true));
      game.isChosen.fillRange(0, game.isChosen.length, false);
    });
    settlement();
  }

  void noCardCallBack() {
    setState(() {
      isPlayerTurn = false;
      game.isChosen.fillRange(0, game.isChosen.length, false);
    });
    settlement();
  }

  Align noCardButton() {
    return Align(
      alignment: const Alignment(-0.9, 0.2),
      child: FractionallySizedBox(
          heightFactor: 0.15,
          child: ButtonWithText(text: '沒有', onTapFunction: noCardCallBack)),
    );
  }

  Align responseWord() {
    return Align(
      alignment: const Alignment(-0.6, -0.5),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        widthFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1077 / 352,
          child: Image.asset(game.isPlayerWin
              ? 'assets/poker_game/scene/win_word.png'
              : 'assets/poker_game/scene/lose_word.png'),
        ),
      ),
    );
  }

  Align playerHandCard() {
    return Align(
      alignment: const Alignment(0.0, 0.8),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        widthFactor: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < game.player.hand.length; i++) ...[
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
                            game.isChosen
                                .fillRange(0, game.isChosen.length, false);
                            game.isChosen[i] = true;
                          });
                        } else {
                          setState(() {
                            game.isChosen
                                .fillRange(0, game.isChosen.length, false);
                          });
                        }
                      }
                    },
                    child: Image.asset(
                      'assets/poker_game/card/${game.player.hand[i].suit}_${game.player.hand[i].rank}.png',
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(
                              curve: Interval(i / game.player.hand.length,
                                  (i + 1) / game.player.hand.length)))
                          .chain(ReverseTween(Tween(begin: 1.0, end: 0.0)))
                          .animate(_controller),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Align computerHandCard() {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: FractionallySizedBox(
        heightFactor: 0.2,
        widthFactor: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < game.computer.hand.length; i++) ...[
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
                  child: Image.asset('assets/poker_game/card/card_back.png',
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(
                              curve: Interval(i / game.computer.hand.length,
                                  (i + 1) / game.computer.hand.length)))
                          .animate(_controller)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            onTap: () async {
              if (isTutorialModePop()) {
                if (await _showSkipTutorialDialog()) context.pop();
              } else {
                if (await _showAlertDialog()) context.pop();
              }
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

  // Future<void> _showRoundDialog() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Center(
  //           child: Text(
  //             '結果發表',
  //             style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
  //           ),
  //         ),
  //         // this part can put multiple messages
  //         content: SingleChildScrollView(
  //           child: Center(
  //             child: game.isTie
  //                 ? const Text(
  //                     '本局平手',
  //                     style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
  //                   )
  //                 : game.isPlayerWin
  //                     ? const Text(
  //                         '你贏得本輪!!!',
  //                         style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
  //                       )
  //                     : const Text(
  //                         '你在本輪落敗',
  //                         style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
  //                       ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           Center(
  //             child: TextButton(
  //               child: const Text(
  //                 '繼續下一輪',
  //                 style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showGameEndDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '本局結束',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
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
                '繼續遊戲',
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

  Future<bool> _showAlertDialog() async {
    audioController.pauseAudio();
    bool shouldPop = false;
    await showDialog(
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
        );
      },
    ).then((value) => shouldPop = value);
    return shouldPop;
  }

  Future<bool> _showSkipTutorialDialog() async {
    audioController.pauseAudio();
    bool shouldPop = false;
    await showDialog(
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
                    '要退出教學模式嗎?',
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
                '繼續教學',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //audioController.resumeAudio();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                '確定離開',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //audioController.stopAudio();
                userInfoProvider.pokerGameDoneTutorial();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => shouldPop = value);
    return shouldPop;
  }

  Future<void> _showTutorialEndDialog() async {
    userInfoProvider.pokerGameDatabase = PokerGameDatabase(
      currentLevel: 0,
      doneTutorial: true,
      responseTimeList: [],
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '遊戲教學已完成',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Center(
                  child: Text(
                    '直接開始遊戲嗎?',
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
                '開始遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                game.putBack();
                game.shuffleBack();
                setState(() {
                  widget.isTutorial = false;
                  game = GameInstance(
                    gameLevel: widget.startLevel,
                    responseTimeList: widget.responseTimeList,
                    isTutorial: widget.isTutorial,
                  );
                });
                String path = game.gameLevel <= 1
                    ? 'find_bigger.m4a'
                    : 'find_the_same.m4a';
                audioController.playInstructionRecord('poker_game/$path');
              },
            ),
            TextButton(
              child: const Text(
                '暫時離開',
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
    required this.pokerGameTutorial,
    required this.callback,
  });

  final GameInstance game;
  final AudioController audioController;
  final PokerGameTutorial pokerGameTutorial;
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

  late StreamSubscription<PlayerState> listener;
  bool isAudioOver = false;

  @override
  void initState() {
    if (!widget.game.isTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        String path = widget.game.gameLevel <= 1
            ? 'find_bigger.m4a'
            : 'find_the_same.m4a';
        widget.audioController.playInstructionRecord('poker_game/$path');
      });
    }
    listener =
        widget.audioController.audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.playing:
          if (isAudioOver = true) {
            setState(() => isAudioOver = false);
          }
          break;
        case PlayerState.completed:
          setState(() => isAudioOver = true);
          break;
        default:
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  bool questionIconPressed = false;
  String questionButtonPath = 'assets/poker_game/scene/question_light.png';

  @override
  Widget build(BuildContext context) {
    return Align(
      child: IgnorePointer(
        ignoring: widget.game.cardDealed,
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: AnimatedOpacity(
            opacity: widget.game.cardDealed ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.blue
                        .withOpacity(widget.game.isTutorial ? 0.5 : 1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              widget.pokerGameTutorial.tutorialProgress != 1
                          ? 0.3
                          : 1,
                      child: difficultyStars(),
                    ),
                    if (widget.game.gameLevel <= 1) ...[
                      Opacity(
                        opacity: widget.game.isTutorial ? 0.3 : 1,
                        child: sizeDescriptionButton(),
                      ),
                    ],
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              widget.pokerGameTutorial.tutorialProgress != 2
                          ? 0.3
                          : 1,
                      child: Align(
                        alignment: const Alignment(0.0, 0.9),
                        child: FractionallySizedBox(
                          heightFactor: 0.15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Center(
                                  child: ButtonWithText(
                                      text: '再聽一次', onTapFunction: listenAgain),
                                ),
                              ),
                              Flexible(
                                child: Center(
                                  child: ButtonWithText(
                                      text: isAudioOver ? '開始' : '跳過並開始',
                                      onTapFunction: startGame),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              widget.pokerGameTutorial.tutorialProgress != 0
                          ? 0.3
                          : 1,
                      child: ruleText(),
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

  Align difficultyStars() {
    return Align(
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
                    child: Image.asset(
                        i <= widget.game.gameLevel ? starLight : starDark),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void startGame() {
    if (!widget.game.isTutorial) {
      widget.audioController.stopAudio();
      widget.callback();
    }
  }

  void listenAgain() {
    if (!widget.game.isTutorial) {
      String path =
          widget.game.gameLevel <= 1 ? 'find_bigger.m4a' : 'find_the_same.m4a';
      widget.audioController.playInstructionRecord('poker_game/$path');
    }
  }

  Align sizeDescriptionButton() {
    return Align(
      alignment: const Alignment(0.9, -0.3),
      child: FractionallySizedBox(
        widthFactor: 0.1,
        child: GestureDetector(
          onTapDown: (_) {
            questionButtonPath = 'assets/poker_game/scene/question_dark.png';
            setState(() => questionIconPressed = true);
          },
          onTapUp: (_) {
            questionButtonPath = 'assets/poker_game/scene/question_light.png';
            setState(() => questionIconPressed = false);
          },
          onPanEnd: (_) {
            questionButtonPath = 'assets/poker_game/scene/question_light.png';
            setState(() => questionIconPressed = false);
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(questionButtonPath),
          ),
        ),
      ),
    );
  }

  Align ruleText() {
    return Align(
      alignment: const Alignment(0.0, 0.2),
      child: FractionallySizedBox(
        heightFactor: 0.5,
        widthFactor: 0.9,
        child: questionIconPressed
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
                child:
                    widget.game.gameLevel <= 1 ? getBigger : getSameRankOrSuit,
              ),
      ),
    );
  }
}

class AlarmClock extends StatefulWidget {
  const AlarmClock({
    super.key,
    required this.timeInMilliSeconds,
    required this.audioController,
    required this.isTutorial,
    required this.callback,
  });

  final int timeInMilliSeconds;
  final AudioController audioController;
  final bool isTutorial;
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
    if (widget.isTutorial) {
      animation = Tween<double>(begin: 10.0, end: 10.0).animate(_controller);
      _timer = Timer(const Duration(seconds: 1), () {});
    } else {
      animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
      startTimer();
    }
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
                      'assets/poker_game/scene/AlarmClock.png',
                    )),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OpponentCoinAnimation extends StatefulWidget {
  const OpponentCoinAnimation(
      {super.key, required this.controller, required this.string});
  final AnimationController controller;
  final String string;
  @override
  State<OpponentCoinAnimation> createState() => _OpponentCoinAnimationState();
}

class _OpponentCoinAnimationState extends State<OpponentCoinAnimation> {
  final opacitySequence = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]);
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacitySequence.animate(widget.controller),
      child: AlignTransition(
        alignment: Tween(
                begin: const Alignment(-0.625, -0.5),
                end: const Alignment(-0.625, -0.8))
            .animate(widget.controller),
        child: FractionallySizedBox(
          heightFactor: 0.1,
          widthFactor: 0.15,
          child: AutoSizeText(
            widget.string,
            style: const TextStyle(
                fontFamily: 'GSR_B', fontSize: 100, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class PlayerCoinAnimation extends StatefulWidget {
  const PlayerCoinAnimation(
      {super.key, required this.controller, required this.string});
  final AnimationController controller;
  final String string;
  @override
  State<PlayerCoinAnimation> createState() => _PlayerCoinAnimationState();
}

class _PlayerCoinAnimationState extends State<PlayerCoinAnimation> {
  final opacitySequence = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]);
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacitySequence.animate(widget.controller),
      child: AlignTransition(
        alignment: Tween(
                begin: const Alignment(0.65, -0.5),
                end: const Alignment(0.65, -0.8))
            .animate(widget.controller),
        child: FractionallySizedBox(
          heightFactor: 0.1,
          widthFactor: 0.1,
          child: AutoSizeText(
            widget.string,
            style: const TextStyle(
                fontFamily: 'GSR_B', fontSize: 100, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
