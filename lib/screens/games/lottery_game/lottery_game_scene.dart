import 'dart:async';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/lottery_game_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/database_models.dart';
import 'package:rive/rive.dart';
import '../../../shared/design_type.dart';
import 'lottery_game_tutorial.dart';
import 'widgets/correct_rate_bar.dart';
import 'widgets/cost_money_animation.dart';
import 'widgets/lottery_game_rule.dart';
import 'widgets/money_animation.dart';
import 'widgets/show_number.dart';
import 'widgets/top_coin.dart';

class LotteryGameScene extends StatefulWidget {
  final int startLevel;
  final int startDigit;
  final bool isTutorial;
  final int continuousCorrectRateBiggerThan50;
  final int loseInCurrentDigit;
  final int historyContinuousWin;
  final int historyContinuousLose;

  const LotteryGameScene({
    super.key,
    required this.startLevel,
    required this.startDigit,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.continuousCorrectRateBiggerThan50,
    required this.loseInCurrentDigit,
    required this.isTutorial,
  });

  @override
  State<LotteryGameScene> createState() => _LotteryGameSceneState();
}

class _LotteryGameSceneState extends State<LotteryGameScene>
    with TickerProviderStateMixin {
  PausableTimer? countdownTimer;
  final formKey = GlobalKey<FormState>();

  late AudioController audioController;

  late DatabaseInfoProvider databaseInfoProvider;

  late LotteryGame game;
  late AnimationController _controller;

  final _lotteryGameTutorial = LotteryGameTutorial();

  bool pagePaused = false;

  @override
  void initState() {
    super.initState();

    game = widget.isTutorial
        ? LotteryGame()
        : LotteryGame(
            gameLevel: widget.startLevel,
            numberOfDigits: widget.startDigit,
            continuousCorrectRateBiggerThan50:
                widget.continuousCorrectRateBiggerThan50,
            loseInCurrentDigit: widget.loseInCurrentDigit,
            continuousWin: widget.historyContinuousWin,
            continuousLose: widget.historyContinuousLose,
            isTutorial: false,
          );

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    Future.delayed(Duration.zero, () {
      for (var imagePath in game.imagePath) {
        precacheImage(AssetImage(imagePath), context);
      }
      precacheImage(AssetImage(game.imagePathWin), context);
      precacheImage(AssetImage(game.imagePathLose), context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  void _playInstruction() {
    final path = game.getInstructionAudioPath();
    if (path != null) {
      audioController.playInstructionRecord(path);
    }
  }

  void startGame() {
    setState(() {
      game.changeCurrentImage();
    });
  }

  void setPeriodicTimer() {
    countdownTimer = PausableTimer(const Duration(seconds: 2), () {
      Logger().d('time up');
      _playNumberSound();
    });
    countdownTimer?.start();
  }

  void _playNumberSound() async {
    if (game.currentIndex < game.numberOfDigits) {
      audioController.playInstructionRecord(
          LotteryGameConst.numbers[game.numArray[game.currentIndex] - 1]);
      setState(() {
        game.showNumber = game.numArray[game.currentIndex].toString();
      });
      countdownTimer = PausableTimer(const Duration(seconds: 1), () {
        setState(() => game.showNumber = '');
        setPeriodicTimer();
      });
      countdownTimer?.start();
    } else {
      cancelTimer();
    }
    game.currentIndex++;
  }

  void startTimer() {
    setPeriodicTimer();
    setState(() {
      game.isCaseFunctioned = true;
      game.disableButton = true;
    });
  }

  void cancelTimer() {
    countdownTimer?.cancel();
    setState(() {
      game.disableButton = false;
      game.changeCurrentImage();
    });
  }

  void gameFunctions() {
    if (!game.isCaseFunctioned) {
      game.isCaseFunctioned = true;
      switch (game.gameProgress) {
        case 0:
          game.setGame();
          game.setArrays(1, 49);
          Logger().d(game.numArray);
          _playInstruction();
          break;
        case 1:
          startTimer();
          break;
        case 2:
          if (game.gameLevel == 4 &&
              (game.specialRules == 1 || game.specialRules == 2)) {
            _playInstruction();
          }
          game.start = DateTime.now();
          break;
        case 3:
          game.end = DateTime.now();
          if (!game.isTutorial) {
            game.record();
            databaseInfoProvider.addPlayTime(game.start, game.end);
          }
          _controller.forward();
          countdownTimer =
              PausableTimer(const Duration(seconds: 1, milliseconds: 300), () {
            audioController.playSfx(LotteryGameConst.spendMoney);
            setState(() {
              databaseInfoProvider.coins -= 200;
            });
            countdownTimer = PausableTimer(
                const Duration(seconds: 1, milliseconds: 200), () {
              setState(() {
                game.changeCurrentImage();
                _controller.reset();
              });
            })
              ..start();
          })
                ..start();
          break;
        case 4:
          countdownTimer = PausableTimer(const Duration(seconds: 2), () {
            setState(
              () => game.changeCurrentImage(),
            );
          })
            ..start();
          break;
        case 5:
          countdownTimer = PausableTimer(const Duration(milliseconds: 250), () {
            if (game.playerWin) {
              databaseInfoProvider.coins += game.gameReward;
              audioController.playSfx(LotteryGameConst.winApplause);
              audioController.playSfx(LotteryGameConst.winFireworks);
            } else {
              audioController.playSfx(LotteryGameConst.loseAudio);
            }
            countdownTimer = PausableTimer(
              const Duration(seconds: 3, milliseconds: 250),
              () => _showGameEndDialog(),
            )..start();
          })
            ..start();
          game.changeDigitByResult();
          databaseInfoProvider.lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: game.gameLevel,
            currentDigit: game.numberOfDigits,
            continuousCorrectRateBiggerThan50:
                game.continuousCorrectRateBiggerThan50,
            loseInCurrentDigit: game.loseInCurrentDigit,
            historyContinuousWin: game.continuousWin,
            historyContinuousLose: game.continuousLose,
            doneTutorial:
                databaseInfoProvider.lotteryGameDatabase.doneTutorial ||
                    game.isTutorial,
          );
          break;
      }
    }
  }

  void _nextTutorialProgress() {
    setState(() {
      switch (_lotteryGameTutorial.tutorialProgress) {
        case 6:
          game.showNumber = 27.toString();
          game.changeCurrentImage();
          break;
        case 8:
          game.showNumber = '';
          game.changeCurrentImage();
          break;
        case 10:
          databaseInfoProvider.lotteryGameDoneTutorial();
          _showTutorialEndDialog();
          break;
        default:
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
    if (!game.isTutorial) {
      gameFunctions();
    }
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(game.currentImagePath),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  //* mask for tutorial
                  if (game.isTutorial) ...[
                    Container(
                      color: Colors.white.withOpacity(0.7),
                    )
                  ],
                  if (game.gameLevel != 1) ...[
                    ShowNumber(number: game.showNumber),
                  ],
                  //* rule screen
                  RuleScreen(
                    game: game,
                    audioController: audioController,
                    lotteryGameTutorial: _lotteryGameTutorial,
                    callback: startGame,
                  ),
                  //* input form
                  if (game.gameProgress == 2) ...[
                    Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        child: _getForm(),
                      ),
                    ),
                  ],
                  TopCoin(game: game),
                  CostMoneyAnimation(controller: _controller),
                  MoneyAnimation(controller: _controller),
                  //* game result animation
                  if (game.gameProgress == 5) ...[
                    if (game.playerWin) ...[
                      const IgnorePointer(
                        child: Align(
                          alignment: Alignment(-0.5, -0.8),
                          child: FractionallySizedBox(
                            widthFactor: 0.25,
                            child: RiveAnimation.asset(
                              LotteryGameConst.fireworkAnimation1,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      const IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            child: RiveAnimation.asset(
                              LotteryGameConst.fireworkAnimation2,
                              alignment: Alignment.bottomLeft,
                            ),
                          ),
                        ),
                      ),
                      const IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.3,
                            child: RiveAnimation.asset(
                              LotteryGameConst.fireworkAnimation3,
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Align(
                          alignment: const Alignment(0.25, 0.3),
                          child: FractionallySizedBox(
                            widthFactor: 0.3,
                            child: RiveAnimation.asset(
                              game.gameReward == 200
                                  ? LotteryGameConst.reward200
                                  : game.gameReward == 400
                                      ? LotteryGameConst.reward400
                                      : LotteryGameConst.reward800,
                            ),
                          ),
                        ),
                      )
                    ] else if (!game.playerWin) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          child: Image.asset(LotteryGameConst.leafWithWind),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.25,
                          child: Image.asset(LotteryGameConst.leafWithWind),
                        ),
                      ),
                      const IgnorePointer(
                        child: RiveAnimation.asset(
                          LotteryGameConst.fallenLeaf,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                    if (game.gameLevel <= 3 ||
                        (game.gameLevel == 4 &&
                            (game.specialRules == 0 ||
                                game.specialRules == 3))) ...[
                      CorrectRateBar(game: game),
                    ],
                  ],
                  //* tutorial part
                  if (widget.isTutorial &&
                      _lotteryGameTutorial.tutorialProgress < 10) ...[
                    _lotteryGameTutorial.dottedLineContainer(),
                    _lotteryGameTutorial.hintArrow(),
                    if (_lotteryGameTutorial.tutorialProgress < 6) ...[
                      if (_lotteryGameTutorial.tutorialProgress == 2) ...[
                        _lotteryGameTutorial.extraDottedLineContainer(),
                        _lotteryGameTutorial.extraHintArrow(),
                      ],
                    ],
                    _lotteryGameTutorial.tutorialDoctor(),
                    _lotteryGameTutorial.chatBubble(),
                    _lotteryGameTutorial
                        .getContinueButton(_nextTutorialProgress),
                  ],
                  exitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align exitButton() {
    return Align(
      alignment: const Alignment(0.95, -0.9),
      child: FractionallySizedBox(
        widthFactor: 0.5 * 1 / 7,
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () async {
              pagePaused = true;
              countdownTimer?.pause();
              if (isTutorialModePop()) {
                _showSkipTutorialDialog();
              } else {
                _showExitDialog();
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

  Row _getForm() {
    return Row(
      children: [
        Flexible(flex: 1, child: Container()),
        Flexible(
          flex: 5,
          child: LayoutBuilder(
            builder: (buildContext, boxConstraints) {
              double lotteryHeight = boxConstraints.maxHeight * 20 / 28;
              double lotteryWidth = boxConstraints.maxWidth * 7 / 9;
              if (game.gameLevel < 2) {
                return Row(
                  children: [
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                      flex: 7,
                      child: Column(
                        children: [
                          Flexible(flex: 2, child: Container()),
                          Expanded(
                            flex: 4,
                            child: Opacity(
                              opacity: game.isTutorial ? 0.3 : 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Center(
                                      child: LayoutBuilder(builder:
                                          (buildContext, boxConstraints) {
                                        return AutoSizeText(
                                          '彩 券 單',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'NotoSansTC_Bold',
                                              fontSize:
                                                  boxConstraints.maxHeight),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0.2 * lotteryHeight / 8,
                                horizontal: 0.2 * lotteryWidth / 8,
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 7,
                                padding: EdgeInsets.zero,
                                crossAxisSpacing: 0.2 * lotteryWidth / 8,
                                mainAxisSpacing: 0.2 * lotteryHeight / 8,
                                childAspectRatio: (lotteryWidth * 0.8) /
                                    (lotteryHeight * 0.8),
                                children: [
                                  for (int i = 0; i < 49; i++) ...[
                                    Opacity(
                                      opacity: game.isTutorial &&
                                              (_lotteryGameTutorial
                                                          .tutorialProgress !=
                                                      8 ||
                                                  (i ~/ 7 < 3 || i % 7 < 3))
                                          ? 0.3
                                          : 1,
                                      child: GestureDetector(
                                        onTap: game.isTutorial
                                            ? null
                                            : () => tapANumber(i),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            color: game.isChosen[i + 1]
                                                ? Colors.yellow
                                                : Colors.white,
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              "${i + 1}",
                                              style: const TextStyle(
                                                fontSize: 100,
                                                fontFamily: 'GSR_R',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Flexible(flex: 2, child: Container()),
                        ],
                      ),
                    ),
                    Flexible(flex: 1, child: Container()),
                  ],
                );
              } else {
                int lenOfForm = game.gameLevel == 4 &&
                        (game.specialRules == 1 || game.specialRules == 2)
                    ? 1
                    : game.numberOfDigits;
                return Form(
                  key: formKey,
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                        flex: 13,
                        child: Column(
                          children: <Widget>[
                            Expanded(flex: 1, child: Container()),
                            Expanded(
                              flex: 6,
                              child: LayoutBuilder(
                                builder: (BuildContext buildContext,
                                    BoxConstraints constraints) {
                                  return GridView.count(
                                    crossAxisCount: 3,
                                    padding: const EdgeInsets.all(20),
                                    crossAxisSpacing:
                                        constraints.maxHeight * 0.1,
                                    mainAxisSpacing:
                                        constraints.maxHeight * 0.1,
                                    childAspectRatio: 1,
                                    children: [
                                      for (int i = 0; i < lenOfForm; i++) ...[
                                        TextFormField(
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 30),
                                            decoration:
                                                inputNumberDecoration.copyWith(
                                                    hintText: '',
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            5)),
                                            keyboardType: TextInputType.number,
                                            // * if in level 4 & rule is even or odd than don't validate
                                            validator: (game.gameLevel == 4 &&
                                                    (game.specialRules == 0 ||
                                                        game.specialRules == 3))
                                                ? (_) => null
                                                : (val) => val!.isEmpty
                                                    ? '輸入數字'
                                                    : null,
                                            textInputAction: i != lenOfForm - 1
                                                ? TextInputAction.next
                                                : TextInputAction.done,
                                            onChanged: (val) {
                                              game.userArray[i] = val.isEmpty
                                                  ? -1
                                                  : int.parse(val);
                                            }),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 11,
                        child: Align(
                          alignment: Alignment.center,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: ButtonWithText(
                              text: '決定好了',
                              onTapFunction: confirmNumber,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: game.gameLevel < 2
              ? Opacity(
                  opacity: game.isTutorial ? 0.3 : 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: FractionallySizedBox(
                        child: ButtonWithText(
                            text: '填好了',
                            onTapFunction: game.disableButton || game.isTutorial
                                ? () {}
                                : () {
                                    game.getResult();
                                    setState(() {
                                      game.changeCurrentImage();
                                    });
                                  }),
                      ),
                    ),
                  ),
                )
              : Container(),
        ),
      ],
    );
  }

  void tapANumber(int i) {
    setState(() {
      if (game.numOfChosen == game.numberOfDigits &&
          game.isChosen[i + 1] == false) {
        pagePaused = true;
        countdownTimer?.pause();
        //* show that need to cancel one of them first
        _showExceedLimitDialog();
      } else {
        game.isChosen[i + 1] = !game.isChosen[i + 1];
        audioController.playInstructionRecord(LotteryGameConst.numbers[i]);
        Logger().d(game.isChosen.length);
        Logger().d(i);
        if (game.isChosen[i + 1]) {
          game.numOfChosen++;
        } else {
          game.numOfChosen--;
        }
      }
    });
  }

  void confirmNumber() {
    if (formKey.currentState!.validate()) {
      game.end = DateTime.now();
      //* judge the result
      game.getResult();
      setState(() {
        game.changeCurrentImage();
      });
    }
  }

  void _showExitDialog() {
    audioController.pauseAllAudio();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '確定要離開嗎?',
          subTitle: '遊戲將不會被記錄下來喔!!!\n而且猜中也能拿到獎勵',
          option1: '確定離開',
          option1Callback: () {
            audioController.stopPlayingInstruction();
            audioController.stopAllSfx();
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '繼續遊戲',
          option2Callback: () {
            pagePaused = false;
            countdownTimer?.start();
            audioController.resumeAllAudio();
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
          subTitle: '要退出教學模式嗎?',
          option1: '確定離開',
          option1Callback: () {
            databaseInfoProvider.lotteryGameDoneTutorial();
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '繼續教學',
          option2Callback: () {
            pagePaused = false;
            countdownTimer?.start();
            audioController.resumeAllAudio();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showExceedLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '劃記太多了喔',
          subTitle: '最多只能劃記${game.numberOfDigits}個數字',
          option1: 'OK',
          option1Callback: () {
            pagePaused = false;
            countdownTimer?.start();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Globals.dialogTemplate(
          title: '結果發表',
          subTitle: game.playerWin ? '你贏得遊戲了!!!' : '真可惜下次努力吧',
          option1: '回到選單',
          option1Callback: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          option2: '繼續遊戲',
          option2Callback: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(seconds: 1), () {
              game.setNextGame();
              setState(() {
                game.changeCurrentImage();
              });
            });
          },
        );
      },
    );
  }

  void _showTutorialEndDialog() {
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
            game = LotteryGame(
              gameLevel: databaseInfoProvider.lotteryGameDatabase.currentLevel,
              numberOfDigits:
                  databaseInfoProvider.lotteryGameDatabase.currentDigit,
              continuousCorrectRateBiggerThan50: databaseInfoProvider
                  .lotteryGameDatabase.continuousCorrectRateBiggerThan50,
              loseInCurrentDigit:
                  databaseInfoProvider.lotteryGameDatabase.loseInCurrentDigit,
              continuousWin:
                  databaseInfoProvider.lotteryGameDatabase.historyContinuousWin,
              continuousLose: databaseInfoProvider
                  .lotteryGameDatabase.historyContinuousLose,
              isTutorial: false,
            );
            game.setNextGame();
            setState(() {
              game.changeCurrentImage();
            });
          },
        );
      },
    );
  }
}
