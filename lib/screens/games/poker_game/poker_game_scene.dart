import 'dart:async';
import 'dart:math';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'poker_game_instance.dart';
import 'poker_game_tutorial.dart';
import '../../../shared/button_with_text.dart';
import 'widgets/alarm_clock.dart';
import 'widgets/chosen_card.dart';
import 'widgets/coin_animation.dart';
import 'widgets/computer_handcard.dart';
import 'widgets/no_card_button.dart';
import 'widgets/player_hand_card.dart';
import 'widgets/poker_game_rule.dart';
import 'widgets/response_word.dart';
import 'widgets/showed_coins.dart';

class PokerGameScene extends StatefulWidget {
  PokerGameScene(
      {super.key,
      required this.startLevel,
      required this.historyContinuousWin,
      required this.historyContinuousLose,
      required this.isTutorial,
      required this.responseTimeList});
  final int startLevel;
  final int historyContinuousWin;
  final int historyContinuousLose;

  bool isTutorial;
  List<int> responseTimeList;
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
  Timer? timerForDelayingResult;
  Timer? timerForDelayingRoundresult;
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
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    game = GameInstance(
      gameLevel: widget.startLevel,
      continuousWin: widget.historyContinuousWin,
      continuousLose: widget.historyContinuousLose,
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
    timerForDelayingResult?.cancel();
    timerForDelayingRoundresult?.cancel();
    audioController.stopPlayingInstruction();
    audioController.stopAllSfx();
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
      game.backgroundPath = PokerGameConst.backgroundImage;
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
        _showLevelChangedDialog(upgrade: true).then((value) {
          setState(() {
            game.cardDealed = false;
            final path = game.getRulePath();
            audioController.playInstructionRecord(path);
          });
        });
        break;
      case 2:
        Logger().i('level downgrade');
        _showLevelChangedDialog(upgrade: false).then((value) {
          setState(() {
            game.cardDealed = false;
            final path = game.getRulePath();
            audioController.playInstructionRecord(path);
          });
        });
        break;
    }
    userInfoProvider.pokerGameDatabase = PokerGameDatabase(
      currentLevel: game.gameLevel,
      historyContinuousWin: game.continuousWin,
      historyContinuousLose: game.continuousLose,
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
    audioController.stopPlayingInstruction();
    audioController.stopAllSfx();
    //* set board first to prevent any other interaction
    setState(() {
      isPlayerTurn = false;
      game.isChosen.fillRange(0, game.isChosen.length, false);
    });
    //* get the value about reward & penalty
    //* also change money in database here
    //* although the animation hasn't start yet while the value won't change before setstate called
    //* thus the value of money is always correct and seperate by the aniamtion status
    playerCoinChange = "-${game.coinLose[game.gameLevel]}";
    opponentCoinChange = "+${game.coinWin[game.gameLevel]}";
    userInfoProvider.coins -= game.coinLose[game.gameLevel];
    game.opponentCoin += game.coinWin[game.gameLevel];
    //* start the animation for money value change
    _controllerChangeMoney.reset();
    _controllerChangeMoney.forward();
    //todo modify this to prevent from setstate after dispose
    timerForDelayingResult = Timer(const Duration(milliseconds: 750), () {
      setState(() {
        game.resultType = ResultType.lose;
        game.continuousWinLose();
        game.recordGame();
        audioController.playSfx(PokerGameConst.loseSfx);
        game.backgroundPath = PokerGameConst.playerLoseBackground;
        showWord = true;
      });
    });
    // Future.delayed(const Duration(milliseconds: 750), () {

    // });
    timerForDelayingRoundresult =
        Timer(const Duration(seconds: 2, milliseconds: 500), () {
      roundResult();
    });
    // Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
    //   roundResult();
    // });
  }

  void settlement() {
    audioController.stopPlayingInstruction();
    audioController.stopAllSfx();
    setState(() {
      game.getResult();
    });
    //* get the value about reward & penalty
    //* also change money in database here
    //* although the animation hasn't start yet while the value won't change before setstate called
    //* thus the value of money is always correct and seperate by the aniamtion status
    if (game.resultType == ResultType.win) {
      playerCoinChange = "+${game.coinWin[game.gameLevel]}";
      opponentCoinChange = "-${game.coinLose[game.gameLevel]}";
      userInfoProvider.coins += game.coinWin[game.gameLevel];
      game.opponentCoin -= game.coinLose[game.gameLevel];
    } else if (game.resultType == ResultType.lose) {
      playerCoinChange = "-${game.coinLose[game.gameLevel]}";
      opponentCoinChange = "+${game.coinWin[game.gameLevel]}";
      userInfoProvider.coins -= game.coinLose[game.gameLevel];
      game.opponentCoin += game.coinWin[game.gameLevel];
    } else if (game.resultType == ResultType.tie) {
      playerCoinChange = "+0";
      opponentCoinChange = "-0";
    }
    //* start animation
    _controllerChangeMoney.reset();
    _controllerChangeMoney.forward();
    timerForDelayingResult = Timer(const Duration(milliseconds: 750), () {
      setState(() {
        if (game.resultType == ResultType.win) {
          audioController.playSfx(PokerGameConst.winSfx);
          game.backgroundPath = PokerGameConst.playerWinBackground;
          showWord = true;
        } else if (game.resultType == ResultType.lose) {
          audioController.playSfx(PokerGameConst.loseSfx);
          game.backgroundPath = PokerGameConst.playerLoseBackground;
          showWord = true;
        }
      });
    });

    timerForDelayingRoundresult =
        Timer(const Duration(seconds: 2, milliseconds: 500), () {
      roundResult();
    });
  }

  void nextTutorialProgress() {
    setState(() {
      switch (_pokerGameTutorial.tutorialProgress) {
        case 0:
        case 1:
        case 2:
        case 3:
          break;
        case 4:
          setState(() {
            game.dealCards();
            game.cardDealed = true;
            _controller.reset();
            _controller.forward();
          });
          break;
        case 5:
          setState(() {
            isPlayerTurn = true;
            game.computerCard = game.computer.hand.removeAt(0);
          });
          break;
        case 6:
          setState(() {
            game.playerCard = game.player.hand.removeAt(0);
          });
          break;
        case 7:
          setState(() {
            isPlayerTurn = false;
          });
          break;
        case 8:
          _showTutorialEndDialog();
          break;
      }
    });
  }

  bool isTutorialModePop() {
    return game.isTutorial;
  }

  @override
  Widget build(BuildContext context) {
    userInfoProvider = context.read<UserInfoProvider>();
    audioController = context.read<AudioController>();
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
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
                  OpponentCoin(game: game),
                  const PlayerCoin(),
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress <= 4) ...[
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
                  ComputerHandCard(
                    game: game,
                    controllerChosenComputer: _controllerChosenComputer,
                    controller: _controller,
                  ),
                  ComputerChosenCard(card: game.computerCard),
                  PlayerChosenCard(card: game.playerCard),
                  if (isPlayerTurn) ...[
                    NoCardButton(
                      callBack: noCardCallBack,
                    ),
                    if (widget.isTutorial &&
                        (_pokerGameTutorial.tutorialProgress == 5 ||
                            _pokerGameTutorial.tutorialProgress == 6)) ...[
                      Container(
                        color: Colors.white.withOpacity(0.7),
                      )
                    ],
                    AlarmClock(
                      timeInMilliSeconds:
                          game.isTutorial ? 2000 : game.getTimeLimit(),
                      audioController: audioController,
                      isTutorial: game.isTutorial,
                      callback: game.isTutorial ? () {} : timeLimitExceeded,
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
                  // PlayerHandCard(
                  //   game: game,
                  //   controllerChosenPlayer: _controllerChosenPlayer,
                  //   controller: _controller,
                  //   callback: playerCardOnTap,
                  // ),
                  Align(
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
                                    playerCardOnTap(i);
                                  },
                                  child: Image.asset(
                                    PokerGameConst.cardImageList[game
                                        .player
                                        .hand[i]
                                        .suit]![game.player.hand[i].rank - 1],
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
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress == 7) ...[
                    Container(
                      color: Colors.white.withOpacity(0.7),
                    )
                  ],
                  if (showWord) ...[
                    ResponseWord(game: game),
                  ],
                  OpponentCoinAnimation(
                      controller: _controllerChangeMoney,
                      string: opponentCoinChange),
                  PlayerCoinAnimation(
                      controller: _controllerChangeMoney,
                      string: playerCoinChange),
                  exitButton(),
                  if (widget.isTutorial &&
                      _pokerGameTutorial.tutorialProgress < 8) ...[
                    if (_pokerGameTutorial.tutorialProgress < 7) ...[
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

  void playerCardOnTap(int index) {
    if (isPlayerTurn) {
      if (!game.isChosen[index]) {
        setState(() {
          game.isChosen.fillRange(0, game.isChosen.length, false);
          game.isChosen[index] = true;
        });
      } else {
        setState(() {
          game.isChosen.fillRange(0, game.isChosen.length, false);
        });
      }
    }
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
              if (isTutorialModePop()) {
                _showAlertDialog(isTutorial: true);
              } else {
                _showAlertDialog();
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

  Future<void> _showLevelChangedDialog({bool upgrade: true}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            upgrade ? '難度提升' : '難度下降',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          )),
          content: SingleChildScrollView(
            child: Center(
              child: Text(
                upgrade ? '連續獲勝五次咯' : '連續落敗五次咯',
                style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
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

  void _showAlertDialog({bool isTutorial = false}) {
    audioController.pauseAudio();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Globals.exitDialog(
          continueCallback: () {
            //game.isPaused = false;
            audioController.resumeAudio();
            // Navigator.of(context).pop(false);
            Navigator.of(context).pop(false);
            // context.pop();
          },
          exitCallback: () {
            audioController.stopAllSfx();
            audioController.stopPlayingInstruction();
            //* if is tutorial mode which means skipping tutorual
            if (isTutorial) userInfoProvider.pokerGameDoneTutorial();
            Navigator.of(context).pop(false);
            context.pop();
          },
          isTutorialMode: isTutorial,
        );
      },
    );
  }

  Future<void> _showTutorialEndDialog() async {
    userInfoProvider.pokerGameDoneTutorial();
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
                '暫時離開',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
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
                    continuousWin: widget.historyContinuousWin,
                    continuousLose: widget.historyContinuousLose,
                    responseTimeList: widget.responseTimeList,
                    isTutorial: widget.isTutorial,
                  );
                });
                final path = game.gameLevel <= 1
                    ? PokerGameConst.gameRuleFindBiggerAudio
                    : PokerGameConst.gameRuleFindTheSameAudio;
                audioController.playInstructionRecord(path);
              },
            ),
          ],
        );
      },
    );
  }
}
