import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:rive/rive.dart';
import '../../../shared/design_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lottery_game_tutorial.dart';

class LotteryGameScene extends StatefulWidget {
  final int startLevel;
  final int startDigit;
  final bool isTutorial;

  const LotteryGameScene({
    super.key,
    required this.startLevel,
    required this.startDigit,
    required this.isTutorial,
  });

  @override
  State<LotteryGameScene> createState() => _LotteryGameSceneState();
}

class _LotteryGameSceneState extends State<LotteryGameScene>
    with TickerProviderStateMixin {
  Timer? mytimer;
  final formKey = GlobalKey<FormState>();

  AudioPlayer tmpPlayer = AudioPlayer();

  late AudioController audioController;

  late UserInfoProvider userInfoProvider;

  late final LotteryGame game;
  late AnimationController _controller;

  final _lotteryGameTutorial = LotteryGameTutorial();

  @override
  void initState() {
    super.initState();

    game = LotteryGame(
      gameLevel: widget.startLevel,
      numberOfDigits: widget.startDigit,
      isTutorial: widget.isTutorial,
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
    mytimer?.cancel();
    tmpPlayer.dispose();
    super.dispose();
  }

  void _playInstruction() {
    String path = game.getInstructionAudioPath();
    audioController.playInstructionRecord(path);
  }

  void startGame() {
    setState(() {
      game.changeCurrentImage();
    });
  }

  //Todo add chinese audio
  void _playNumberSound() async {
    if (game.currentIndex < game.numberOfDigits) {
      audioController.playLotteryGameNumber(
          '${game.numArray[game.currentIndex].toString()}.mp3');
      setState(() {
        game.showNumber = game.numArray[game.currentIndex].toString();
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          game.showNumber = "";
        });
      });
    } else {
      cancelTimer();
    }
    game.currentIndex++;
  }

  void startTimer() {
    mytimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!game.isPaused) _playNumberSound();
    });
    setState(() {
      game.isCaseFunctioned = true;
      game.disableButton = true;
    });
  }

  void cancelTimer() {
    if (mytimer != null) {
      mytimer!.cancel();
      setState(() {
        game.disableButton = false;
        game.changeCurrentImage();
      });
    }
  }

  void gameFunctions(BuildContext context) {
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
          // player.stop();
          // player.release();
          game.end = DateTime.now();
          if (!game.isTutorial) {
            game.record();
          }
          Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
            setState(() {
              game.changeCurrentImage();
              _controller.reset();
            });
          });
          _controller.forward();
          Future.delayed(const Duration(seconds: 1, milliseconds: 300), () {
            audioController.playLotteryGameSoundEffect('SpendMoney_casher.mp3');
            setState(() {
              userInfoProvider.coins -= 200;
            });
          });
          break;
        case 4:
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              game.changeCurrentImage();
            });
          });
          break;
        case 5:
          Future.delayed(const Duration(milliseconds: 250), () {
            if (game.playerWin) {
              userInfoProvider.coins += game.gameReward;
              audioController.playLotteryGameSoundEffect('Applause.mp3');
              tmpPlayer.play(
                  AssetSource('lottery_game_sound/Lotter_win_firework.wav'));
            } else {
              audioController.playLotteryGameSoundEffect('horror_lose.wav');
            }
          });
          game.changeDigitByResult();
          // ignore: ToDo
          //TODO done tutorial need modify
          // * this part is for record the digit and level of current game
          if (game.isTutorial) {
            userInfoProvider.lotteryGameDatabaseTutorial = true;
          } else {
            userInfoProvider.lotteryGameDatabase = LotteryGameDatabase(
              currentLevel: game.gameLevel,
              currentDigit: game.numberOfDigits,
              doneTutorial: userInfoProvider.lotteryGameDatabase.doneTutorial ||
                  game.isTutorial,
            );
          }
          Future.delayed(const Duration(seconds: 3, milliseconds: 500),
              () => _showGameEndDialog());
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
          _showTutorialEndDialog();
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //listen and reset the state
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    audioController = context.read<AudioController>();
    if (!game.isTutorial) {
      gameFunctions(context);
    }
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          audioController.pauseAudio();
          showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              game.isPaused = true;
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
                      )),
                      Center(
                          child: Text(
                        '而且猜中也能拿到獎勵',
                        style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                      )),
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
                      game.isPaused = false;
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
                      game.isPaused = false;
                      audioController.stopAudio();
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
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
                  if (widget.isTutorial) ...[
                    Container(
                      color: Colors.white.withOpacity(0.7),
                    )
                  ],
                  exitButton(),
                  if (game.gameLevel != 1) ...[
                    _showNumber(game.showNumber),
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
                  topCoin(),
                  costMoneyAnimation(),
                  moneyAnimation(),
                  //* game result animation
                  if (game.gameProgress == 5) ...[
                    if (game.playerWin) ...[
                      const IgnorePointer(
                        child: Align(
                          alignment: Alignment(-0.5, -0.8),
                          child: FractionallySizedBox(
                            widthFactor: 0.25,
                            child: RiveAnimation.asset(
                              'assets/lottery_game_scene/feedback/firework_1.riv',
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
                              'assets/lottery_game_scene/feedback/firework_2.riv',
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
                              'assets/lottery_game_scene/feedback/firework_3.riv',
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
                              'assets/lottery_game_scene/feedback/${game.gameReward}.riv',
                            ),
                          ),
                        ),
                      )
                    ] else if (!game.playerWin) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          child: Image.asset(
                              'assets/lottery_game_scene/feedback/leaf_with_wind.png'),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.25,
                          child: Image.asset(
                              'assets/lottery_game_scene/feedback/leaf_with_wind.png'),
                        ),
                      ),
                      const IgnorePointer(
                        child: RiveAnimation.asset(
                          'assets/lottery_game_scene/feedback/fallen_leaf.riv',
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ]
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
      alignment: const Alignment(-0.95, -0.9),
      child: FractionallySizedBox(
        widthFactor: 0.5 * 1 / 7,
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () {
              game.isPaused = true;
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

  IgnorePointer moneyAnimation() {
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.4)))
            .animate(_controller),
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: const Interval(0.7, 1.0)))
              .animate(_controller),
          child: SlideTransition(
            position: Tween(
                    begin: const Offset(0.0, 0.5), end: const Offset(0.0, 0.3))
                .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                .animate(_controller),
            child: SlideTransition(
              position: Tween(
                      begin: const Offset(0.0, 0.3),
                      end: const Offset(0.0, -0.3))
                  .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                  .animate(_controller),
              child: FractionallySizedBox(
                widthFactor: 0.3,
                child: AspectRatio(
                  aspectRatio: 902 / 710,
                  child:
                      Image.asset('assets/lottery_game_scene/SpendMoney.png'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IgnorePointer costMoneyAnimation() {
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.4)))
            .animate(_controller),
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: const Interval(0.7, 1.0)))
              .animate(_controller),
          child: SlideTransition(
            position: Tween(
                    begin: const Offset(2.0, 1.0), end: const Offset(2.0, 0.1))
                .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                .animate(_controller),
            child: SlideTransition(
              position: Tween(
                      begin: const Offset(2.0, 0.1),
                      end: const Offset(2.0, -2.0))
                  .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                  .animate(_controller),
              child: const FractionallySizedBox(
                widthFactor: 0.15,
                heightFactor: 0.1,
                child: AutoSizeText(
                  '-200',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IgnorePointer topCoin() {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0.05, -0.95),
        child: FractionallySizedBox(
          widthFactor: 0.12,
          heightFactor: 0.1,
          child: Consumer<UserInfoProvider>(
            builder: (context, value, child) {
              return AutoSizeText(
                value.coins.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withOpacity(
                      game.gameProgress == 3 || game.gameProgress == 5 ? 1 : 0),
                  fontSize: 100,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getForm() {
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
                                                  _lotteryGameTutorial
                                                          .tutorialProgress !=
                                                      8 ||
                                              (i ~/ 7 < 3 || i % 7 < 3)
                                          ? 0.3
                                          : 1,
                                      child: InkWell(
                                        onTap: game.isTutorial
                                            ? null
                                            : () {
                                                setState(() {
                                                  if (game.numOfChosen ==
                                                          game.numberOfDigits &&
                                                      game.isChosen[i + 1] ==
                                                          false) {
                                                    game.isPaused = true;
                                                    //show that need to cancel one of them first
                                                    _exceedLimitAlertDialog()
                                                        .then((_) => game
                                                            .isPaused = false);
                                                  } else {
                                                    game.isChosen[i + 1] =
                                                        !game.isChosen[i + 1];
                                                    audioController
                                                        .playLotteryGameNumber(
                                                            '${i + 1}.mp3');
                                                    //_playPathSound('$language/$i.mp3');
                                                    if (game.isChosen[i + 1]) {
                                                      game.numOfChosen++;
                                                    } else {
                                                      game.numOfChosen--;
                                                    }
                                                  }
                                                });
                                              },
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
                          child: Column(children: <Widget>[
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
                          ])),
                      Expanded(
                        flex: 11,
                        child: Align(
                          alignment: Alignment.center,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: AspectRatio(
                              aspectRatio: 835 / 353,
                              child: GestureDetector(
                                onTap: () {
                                  if (formKey.currentState!.validate()) {
                                    game.end = DateTime.now();
                                    //judge the result
                                    game.getResult();
                                    setState(() {
                                      game.changeCurrentImage();
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/global/continue_button.png'),
                                    ),
                                  ),
                                  child: const FractionallySizedBox(
                                    heightFactor: 0.5,
                                    widthFactor: 0.8,
                                    child: Center(
                                      child: AutoSizeText(
                                        '決定好了',
                                        style: TextStyle(
                                          fontFamily: 'GSR_B',
                                          color: Colors.white,
                                          fontSize: 100,
                                        ),
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
                );
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: game.gameLevel < 2
              ? Opacity(
                  opacity: game.isTutorial &&
                          _lotteryGameTutorial.tutorialProgress != 9
                      ? 0.3
                      : 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: GestureDetector(
                        onTap: game.disableButton || game.isTutorial
                            ? null
                            : () {
                                game.getResult();
                                setState(() {
                                  game.changeCurrentImage();
                                });
                              },
                        child: Align(
                          alignment: const Alignment(0.0, 0.0),
                          child: FractionallySizedBox(
                            child: AspectRatio(
                              aspectRatio: 835 / 353,
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/global/continue_button.png'),
                                  ),
                                ),
                                child: FractionallySizedBox(
                                  heightFactor: 0.5,
                                  widthFactor: 0.8,
                                  child: LayoutBuilder(
                                    builder: (BuildContext buildContext,
                                        BoxConstraints boxConstraints) {
                                      double width = boxConstraints.maxWidth;
                                      return Center(
                                        child: AutoSizeText(
                                          '填好了',
                                          style: TextStyle(
                                            fontSize: width / 4,
                                            color: Colors.white,
                                            fontFamily: 'GSR_B',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ),
      ],
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
                Center(
                  child: Text(
                    '而且猜中也能拿到獎勵',
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
                game.isPaused = false;
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
                audioController.stopAudio();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exceedLimitAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('劃記太多了喔'),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('最多只能劃記${game.numberOfDigits}個數字'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
          title: const Center(
              child: Text(
            '結果發表',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
          )),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(children: [
              game.playerWin
                  ? const Center(
                      child: Text(
                        '你贏得遊戲了!!!',
                        style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                      ),
                    )
                  : const Center(
                      child: Text(
                        '真可惜下次努力吧',
                        style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                      ),
                    ),
            ]),
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
            if (!game.isTutorial) ...[
              TextButton(
                child: const Text(
                  '繼續遊戲',
                  style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Timer(const Duration(seconds: 1), () {
                    game.setNextGame();
                    setState(() {
                      game.changeCurrentImage();
                    });
                  });
                },
              ),
            ]
          ],
        );
      },
    );
  }

  Align _showNumber(String number) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: number != '' ? 1.0 : 0.0,
        curve: Curves.linear,
        duration: const Duration(
          milliseconds: 500,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AutoSizeText(
                  number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 200,
                    color: Colors.red,
                    fontFamily: 'GSR_B',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                game.isTutorial = false;
                game.numberOfDigits = 2;
                game.setNextGame();
                setState(() {
                  game.changeCurrentImage();
                });
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
    required this.lotteryGameTutorial,
    required this.callback,
  });

  final LotteryGame game;
  final AudioController audioController;
  final LotteryGameTutorial lotteryGameTutorial;
  final Function() callback;

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  List<Alignment> starPosition = [
    const Alignment(-1.0, -0.6),
    const Alignment(-0.5, -0.8),
    const Alignment(0.0, -1.0),
    const Alignment(0.5, -0.8),
    const Alignment(1.0, -0.6),
  ];
  String starLight = 'assets/global/star_light.png';
  String starDark = 'assets/global/star_dark.png';
  List<AutoSizeText> rules = [
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請把出現的', style: TextStyle(color: Colors.black)),
          TextSpan(text: '所有數字', style: TextStyle(color: Colors.red)),
          TextSpan(text: '記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請把「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '聽到', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」的所有數字記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '按照出現順序', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」把所有數字記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有數字由「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '小到大排列', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  List<AutoSizeText> specialRules = [
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '雙數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '最大的兩個數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '最小的兩個數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '單數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  List<String> difficulties = ['一', '二', '三', '四', '五'];

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: IgnorePointer(
          ignoring: widget.game.gameProgress != 0,
          child: AnimatedOpacity(
            opacity: widget.game.gameProgress == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.purple
                        .withOpacity(widget.game.isTutorial ? 0.3 : 1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    //difficultyStars(),
                    for (int i = 0; i < 5; i++) ...[
                      Opacity(
                        opacity: widget.game.isTutorial &&
                                    (widget.lotteryGameTutorial
                                                .tutorialProgress !=
                                            2 &&
                                        i == 0) ||
                                i != 0
                            ? 0.3
                            : 1,
                        child: Align(
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
                      ),
                    ],
                    difficultyLabel(),
                    gameRule(),
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              widget.lotteryGameTutorial.tutorialProgress != 5
                          ? 0.3
                          : 1,
                      child: Align(
                        alignment: const Alignment(0.0, 0.9),
                        child: FractionallySizedBox(
                          heightFactor: 0.15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _listenAgainButton(),
                              _startGameButton(),
                            ],
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
      ),
    );
  }

  Opacity gameRule() {
    return Opacity(
      opacity: widget.game.isTutorial &&
              widget.lotteryGameTutorial.tutorialProgress != 1
          ? 0.3
          : 1,
      child: Align(
        alignment: const Alignment(0.0, 0.5),
        child: FractionallySizedBox(
          heightFactor: 0.25,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Center(
              child: widget.game.gameLevel < 4
                  ? rules[widget.game.gameLevel]
                  : specialRules[widget.game.specialRules],
            ),
          ),
        ),
      ),
    );
  }

  Align difficultyLabel() {
    return Align(
      alignment: const Alignment(0.0, 0.0),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Opacity(
                opacity: widget.game.isTutorial &&
                        widget.lotteryGameTutorial.tutorialProgress != 2
                    ? 0.3
                    : 1,
                child: AutoSizeText(
                  '難度${difficulties[widget.game.gameLevel]} ',
                  style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
                  maxFontSize: 100,
                  minFontSize: 5,
                  stepGranularity: 5,
                  maxLines: 1,
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Opacity(
                opacity: widget.game.isTutorial &&
                        (widget.lotteryGameTutorial.tutorialProgress != 3 &&
                            widget.lotteryGameTutorial.tutorialProgress != 4)
                    ? 0.3
                    : 1,
                child: AutoSizeText(
                  '號碼數量${widget.game.numberOfDigits}',
                  style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
                  maxFontSize: 100,
                  minFontSize: 5,
                  stepGranularity: 5,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align difficultyStars() {
    return Align(
      //alignment: Alignment.topCenter,
      //child: FractionallySizedBox(
      //heightFactor: 1,
      child: Stack(
        children: [
          for (int i = 0; i < 5; i++) ...[
            Opacity(
              opacity: widget.game.isTutorial &&
                          (widget.lotteryGameTutorial.tutorialProgress != 2 &&
                              i == 0) ||
                      i != 0
                  ? 0.3
                  : 1,
              child: Align(
                alignment: starPosition[i],
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    //child: Image.asset(
                    //    i <= widget.game.gameLevel ? starLight : starDark),
                    child: Placeholder(),
                  ),
                ),
              ),
            ),
          ],
        ],
        // ),
      ),
    );
  }

  Flexible _startGameButton() {
    return Flexible(
      flex: 1,
      child: Center(
        child: AspectRatio(
          aspectRatio: 835 / 353,
          child: GestureDetector(
            onTap: widget.game.isTutorial
                ? null
                : () {
                    widget.audioController.stopAudio();
                    widget.callback();
                  },
            child: Image.asset(
              'assets/lottery_game_scene/start_button.png',
            ),
          ),
        ),
      ),
    );
  }

  Flexible _listenAgainButton() {
    return Flexible(
      flex: 1,
      child: Center(
        child: AspectRatio(
          aspectRatio: 835 / 353,
          child: GestureDetector(
            onTap: widget.game.isTutorial
                ? null
                : () {
                    String path = widget.game.getInstructionAudioPath();
                    widget.audioController.playInstructionRecord(path);
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
    );
  }
}
