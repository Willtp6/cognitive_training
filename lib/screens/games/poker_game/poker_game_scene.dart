import 'dart:math';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/models/database_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:provider/provider.dart';
import 'poker_game_instance.dart';
import 'poker_game_tutorial.dart';
import '../../../shared/button_with_text.dart';
import 'widgets/alarm_clock.dart';
import 'widgets/chosen_card.dart';
import 'widgets/coin_animation.dart';
import 'widgets/computer_handcard.dart';
import 'widgets/no_card_button.dart';
import 'widgets/poker_game_rule.dart';
import 'widgets/response_word.dart';
import 'widgets/showed_coins.dart';
import 'widgets/exit_button.dart';

class PokerGameScene extends StatefulWidget {
  const PokerGameScene({
    super.key,
    required this.startLevel,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.enterWithTutorialMode,
    required this.responseTimeList,
  });
  final int startLevel;
  final int historyContinuousWin;
  final int historyContinuousLose;

  final bool enterWithTutorialMode;
  final List<int> responseTimeList;
  @override
  State<PokerGameScene> createState() => _PokerGameStateScene();
}

class _PokerGameStateScene extends State<PokerGameScene>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosenPlayer;
  late AnimationController _controllerChosenComputer;
  late AnimationController _controllerChangeMoney;
  late AnimationController _controllerAlarmClock;
  late GameInstance game;
  late AudioController audioController;
  PausableTimer? countdownTimer;
  bool isPlayerTurn = false;
  bool showWord = false;
  late DatabaseInfoProvider databaseInfoProvider;
  final PokerGameTutorial _pokerGameTutorial = PokerGameTutorial();

  String playerCoinChange = "";
  String opponentCoinChange = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _controllerChosenPlayer = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controllerChosenComputer = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controllerChangeMoney = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _controllerAlarmClock = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    game = widget.enterWithTutorialMode
        ? GameInstance()
        : GameInstance(
            gameLevel: widget.startLevel,
            continuousWin: widget.historyContinuousWin,
            continuousLose: widget.historyContinuousLose,
            responseTimeList: widget.responseTimeList,
            isTutorial: false,
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosenPlayer.dispose();
    _controllerChosenComputer.dispose();
    _controllerChangeMoney.dispose();
    _controllerAlarmClock.dispose();
    countdownTimer?.cancel();
    audioController.stopAllAudio();
    super.dispose();
  }

  void simulatePlayerAction() {
    int randomTime =
        game.computer.hand.length >= 3 ? 3 : game.computer.hand.length;
    //random 1-3 times choose card
    final int numberOfRandomChoice = Random().nextInt(randomTime) + 1;
    int counter = 0;
    countdownTimer = PausableTimer.periodic(const Duration(seconds: 1), () {
      if (counter < numberOfRandomChoice) {
        setState(() {
          game.isChosenComputer
              .fillRange(0, game.isChosenComputer.length, false);
          game.isChosenComputer[Random().nextInt(game.computer.hand.length)] =
              true;
          counter++;
        });
      } else {
        countdownTimer?.cancel();
        setState(() {
          isPlayerTurn = true;
          game.computerCard = game.computer.hand
              .removeAt(game.isChosenComputer.indexWhere((element) => true));
          game.isChosenComputer
              .fillRange(0, game.isChosenComputer.length, false);
          game.start = DateTime.now();
        });

        int timeInMilliseconds = game.getTimeLimit();
        if (timeInMilliseconds >= 3000) {
          countdownTimer = PausableTimer(
              Duration(milliseconds: timeInMilliseconds - 3000 + 1), () {
            audioController.playSfx(PokerGameConst.ticTokSfx);
            _controllerAlarmClock.forward();
            countdownTimer =
                PausableTimer(const Duration(milliseconds: 3000), () {
              timeLimitExceeded();
            })
                  ..start();
          })
            ..start();
        } else {
          audioController.playSfx(PokerGameConst.ticTokSfx);
          _controllerAlarmClock.forward();
          countdownTimer =
              PausableTimer(Duration(milliseconds: timeInMilliseconds), () {
            timeLimitExceeded();
          })
                ..start();
        }
      }
    })
      ..start();
  }

  void roundResult() {
    setState(() {
      game.putBack();
      showWord = false;
      game.backgroundPath = PokerGameConst.backgroundImage;
      isPlayerTurn = false;
    });
    switch (game.gameLevelChange()) {
      case LevelChangeResult.noChange:
        if (game.computer.hand.isEmpty) {
          _showGameEndDialog();
        } else {
          simulatePlayerAction();
        }
        break;
      case LevelChangeResult.upgrade:
        Logger().i('level upgrade');
        _showLevelUpgradeDialog();
        break;
      case LevelChangeResult.downgrade:
        Logger().i('level downgrade');
        _showLevelDownGradeDialog();

        break;
    }
    databaseInfoProvider.pokerGameDatabase = PokerGameDatabase(
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
        countdownTimer = PausableTimer(const Duration(seconds: 2), () {
          simulatePlayerAction();
        })
          ..start();
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
    _controller.forward().whenComplete(() => simulatePlayerAction());
  }

  void timeLimitExceeded() {
    audioController.stopPlayingInstruction();
    audioController.stopAllSfx();
    _controllerAlarmClock.reset();
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
    databaseInfoProvider.coins -= game.coinLose[game.gameLevel];
    game.opponentCoin += game.coinWin[game.gameLevel];
    //* start the animation for money value change
    _controllerChangeMoney.reset();
    _controllerChangeMoney.forward();

    countdownTimer = PausableTimer(const Duration(milliseconds: 750), () {
      setState(() {
        game.resultType = ResultType.lose;
        game.continuousWinLose();
        game.recordGame();
        audioController.playSfx(PokerGameConst.loseSfx);
        game.backgroundPath = PokerGameConst.playerLoseBackground;
        showWord = true;
      });
      countdownTimer =
          PausableTimer(const Duration(seconds: 1, milliseconds: 750), () {
        roundResult();
      })
            ..start();
    })
      ..start();
  }

  void settlement() {
    audioController.stopPlayingInstruction();
    audioController.stopAllSfx();
    _controllerAlarmClock.reset();
    countdownTimer?.cancel();
    setState(() {
      game.getResult();
      databaseInfoProvider.addPlayTime(game.start, game.end);
    });
    //* get the value about reward & penalty
    //* also change money in database here
    //* although the animation hasn't start yet while the value won't change before setstate called
    //* thus the value of money is always correct and seperate by the aniamtion status
    if (game.resultType == ResultType.win) {
      playerCoinChange = "+${game.coinWin[game.gameLevel]}";
      opponentCoinChange = "-${game.coinLose[game.gameLevel]}";
      databaseInfoProvider.coins += game.coinWin[game.gameLevel];
      game.opponentCoin -= game.coinLose[game.gameLevel];
    } else if (game.resultType == ResultType.lose) {
      playerCoinChange = "-${game.coinLose[game.gameLevel]}";
      opponentCoinChange = "+${game.coinWin[game.gameLevel]}";
      databaseInfoProvider.coins -= game.coinLose[game.gameLevel];
      game.opponentCoin += game.coinWin[game.gameLevel];
    } else if (game.resultType == ResultType.tie) {
      playerCoinChange = "+0";
      opponentCoinChange = "-0";
    }
    //* start animation
    _controllerChangeMoney.reset();
    _controllerChangeMoney.forward();
    countdownTimer = PausableTimer(const Duration(milliseconds: 750), () {
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
      countdownTimer =
          PausableTimer(const Duration(seconds: 1, milliseconds: 750), () {
        roundResult();
      })
            ..start();
    })
      ..start();
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
    databaseInfoProvider = context.read<DatabaseInfoProvider>();
    audioController = context.read<AudioController>();
    return SafeArea(
      child: PopScope(
        canPop: false,
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
                  if (game.isTutorial &&
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
                    if (game.isTutorial &&
                        (_pokerGameTutorial.tutorialProgress == 5 ||
                            _pokerGameTutorial.tutorialProgress == 6)) ...[
                      Container(
                        color: Colors.white.withOpacity(0.7),
                      )
                    ],
                    AlarmClock(
                      animationController: _controllerAlarmClock,
                      isTutorial: game.isTutorial,
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
                  if (game.isTutorial &&
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
                  if (game.isTutorial &&
                      _pokerGameTutorial.tutorialProgress < 8) ...[
                    if (_pokerGameTutorial.tutorialProgress < 7) ...[
                      _pokerGameTutorial.dottedLineContainer(),
                      _pokerGameTutorial.hintArrow(),
                    ],
                    _pokerGameTutorial.tutorialDoctor(),
                    _pokerGameTutorial.chatBubble(),
                    _pokerGameTutorial.getContinueButton(nextTutorialProgress),
                  ],
                  ExitButton(
                    callback: () {
                      if (isTutorialModePop()) {
                        _showSkipTutorialDialog();
                      } else {
                        _showExitDialog();
                      }
                    },
                    alignment: const Alignment(0.95, -0.5),
                  ),
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

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
            title: '本局結束',
            subTitle: '',
            option1: '回到選單',
            option1Callback: () {
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            option2: '繼續遊戲',
            option2Callback: () {
              Navigator.of(context).pop();
              resetBoard();
            });
      },
    );
  }

  void _showLevelUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '難度提升',
          subTitle: '連續獲勝五次咯',
          option1: '返回選單',
          option1Callback: () {
            audioController.stopAllAudio();
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '繼續遊戲',
          option2Callback: () {
            game.shuffleBack();
            Navigator.of(context).pop();
            setState(() {
              game.cardDealed = false;
              final path = game.getRulePath();
              audioController.playInstructionRecord(path);
            });
          },
        );
      },
    );
  }

  void _showLevelDownGradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '難度下降',
          subTitle: '連續落敗五次咯',
          option1: '返回選單',
          option1Callback: () {
            audioController.stopAllAudio();
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '繼續遊戲',
          option2Callback: () {
            game.shuffleBack();
            Navigator.of(context).pop();
            setState(() {
              game.cardDealed = false;
              final path = game.getRulePath();
              audioController.playInstructionRecord(path);
            });
          },
        );
      },
    );
  }

  void _showExitDialog() {
    audioController.pauseAllAudio();
    countdownTimer?.pause();
    bool controllerAnimating = false,
        controllerChosenPlayerAnimating = false,
        controllerChosenComputerAnimating = false,
        controllerChangeMoneyAnimating = false,
        controllerAlarmClockAnimating = false;
    if (_controller.isAnimating) {
      controllerAnimating = true;
      _controller.stop();
    }
    if (_controllerChangeMoney.isAnimating) {
      controllerChangeMoneyAnimating = true;
      _controllerChangeMoney.stop();
    }
    if (_controllerChosenComputer.isAnimating) {
      controllerChosenComputerAnimating = true;
      _controllerChosenComputer.stop();
    }
    if (_controllerChosenPlayer.isAnimating) {
      controllerChosenPlayerAnimating = true;
      _controllerChosenPlayer.stop();
    }
    if (_controllerAlarmClock.isAnimating) {
      controllerAlarmClockAnimating = true;
      _controllerAlarmClock.stop();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '確定要離開嗎?',
          subTitle: '遊戲將不會被記錄下來喔!!!',
          option1: '確定離開',
          option1Callback: () {
            audioController.stopAllSfx();
            audioController.stopPlayingInstruction();
            Navigator.of(context).pop();
            context.pop();
          },
          option2: '繼續遊戲',
          option2Callback: () {
            audioController.resumeAllAudio();
            countdownTimer?.start();
            if (controllerAnimating) _controller.forward();
            if (controllerChangeMoneyAnimating) {
              _controllerChangeMoney.forward();
            }
            if (controllerChosenComputerAnimating) {
              _controllerChosenComputer.forward();
            }
            if (controllerChosenPlayerAnimating) {
              _controllerChosenPlayer.forward();
            }
            if (controllerAlarmClockAnimating) _controllerAlarmClock.forward();

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSkipTutorialDialog() {
    audioController.pauseAllAudio();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '確定要離開嗎?',
          subTitle: '直接離開會跳過教學模式喔!!!',
          option1: '確定離開',
          option1Callback: () {
            audioController.stopAllAudio();
            databaseInfoProvider.pokerGameDoneTutorial();
            Navigator.of(context).pop();
            context.pop();
          },
          option2: '繼續教學',
          option2Callback: () {
            audioController.resumeAllAudio();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showTutorialEndDialog() {
    databaseInfoProvider.pokerGameDoneTutorial();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '遊戲教學已完成',
          subTitle: '直接開始遊戲嗎?',
          option1: '暫時離開',
          option1Callback: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '開始遊戲',
          option2Callback: () {
            Navigator.of(context).pop();
            game.putBack();
            game.shuffleBack();
            setState(() {
              game = GameInstance(
                gameLevel: widget.startLevel,
                continuousWin: widget.historyContinuousWin,
                continuousLose: widget.historyContinuousLose,
                responseTimeList: widget.responseTimeList,
                isTutorial: false,
              );
            });
            final path = game.gameLevel <= 1
                ? PokerGameConst.gameRuleFindBiggerAudio
                : PokerGameConst.gameRuleFindTheSameAudio;
            audioController.playInstructionRecord(path);
          },
        );
      },
    );
  }
}
