import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game_menu.dart';
import 'package:cognitive_training/screens/gmaes/poker_game/poker_game_instance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_model.dart';
import '../../../shared/design_type.dart';

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
    with SingleTickerProviderStateMixin {
  Timer? mytimer;
  static final formKey = GlobalKey<FormState>();

  AudioPlayer? player;

  late UserInfoProvider userInfoProvider;
  var logger = Logger(printer: PrettyPrinter());

  late final LotteryGame game;

  @override
  void initState() {
    super.initState();
    // create the instance of lottery game
    game = LotteryGame(
      gameLevel: widget.startLevel,
      numberOfDigits: widget.startDigit,
      isTutorial: widget.isTutorial,
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
    mytimer?.cancel();
    player?.dispose();
    super.dispose();
  }

  void _playPathSound(String path) async {
    player = AudioPlayer();
    await player!.play(AssetSource('lottery_game_sound/$path'));
  }

  void _playNumberSound() async {
    if (game.currentIndex < game.numberOfDigits) {
      player = AudioPlayer();
      await player!.play(AssetSource(
          'lottery_game_sound/${game.numArray[game.currentIndex].toString()}.mp3'));
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

  List<Alignment> starPosition = [
    const Alignment(-1.0, -0.4),
    const Alignment(-0.5, -0.8),
    const Alignment(0.0, -1.0),
    const Alignment(0.5, -0.8),
    const Alignment(1.0, -0.4),
  ];
  String starLight = 'assets/lottery_game_scene/star_light.png';
  String starDark = 'assets/lottery_game_scene/star_dark.png';

  List<AutoSizeText> rules = [
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請把出現的',
              style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '所有數字', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請把「', style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '聽到', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '」的所有數字記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請「', style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '按照順序', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '」把所有數字記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請將所有數字由「',
              style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '小到大排列', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '」記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請將所有的「',
              style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '單數', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '」記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
    const AutoSizeText.rich(
      softWrap: true,
      maxLines: 2,
      TextSpan(
        children: [
          TextSpan(
              text: '請將所有的「',
              style: TextStyle(color: Colors.black, fontSize: 50)),
          TextSpan(
              text: '雙數', style: TextStyle(color: Colors.red, fontSize: 50)),
          TextSpan(
              text: '」記下來！',
              style: TextStyle(color: Colors.black, fontSize: 50)),
        ],
      ),
    ),
  ];

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

  void gameFunctions() {
    if (!game.isCaseFunctioned) {
      game.isCaseFunctioned = true;
      switch (game.gameProgress) {
        case 0:
          game.setArrays(1, 49);
          logger.d(game.numArray);
          // ignore: todo
          //TODO will add audio to play game rule
          break;
        case 1:
          startTimer();
          break;
        case 2:
          game.start = DateTime.now();
          break;
        case 3:
          game.end = DateTime.now();
          game.record();
          Timer(const Duration(seconds: 5), () {
            setState(() {
              game.changeCurrentImage();
            });
          });
          break;
        case 4:
          userInfoProvider.coins -= 200;
          Timer(const Duration(seconds: 2), () {
            setState(() {
              game.changeCurrentImage();
            });
          });
          break;
        case 5:
          Timer(const Duration(milliseconds: 250), () {
            if (game.playerWin) {
              userInfoProvider.coins += game.gameReward;
              _playPathSound("Applause.mp3");
            } else {
              _playPathSound("horror_lose.wav");
            }
          });
          game.changeDigitByResult();
          // ignore: ToDo
          //TODO done tutorial need modify
          userInfoProvider.lotteryGameDatabase = LotteryGameDatabase(
              currentLevel: game.gameLevel,
              currentDigit: game.numberOfDigits,
              doneTutorial: userInfoProvider.lotteryGameDatabase.doneTutorial);
          Timer(const Duration(seconds: 2), () => _showGameEndDialog());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //listen and reset the state
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    gameFunctions();
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            game.isPaused = true;
            return DefaultTextStyle(
              style: const TextStyle(fontFamily: 'NotoSansTC_Regular'),
              child: AlertDialog(
                title: const Text('確定要離開嗎?'),
                // this part can put multiple messages
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('遊戲將不會被記錄下來喔!!!'),
                      Text('而且猜中也能拿到獎勵'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('繼續遊戲'),
                    onPressed: () {
                      game.isPaused = false;
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('確定離開'),
                    onPressed: () {
                      game.isPaused = false;
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
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(game.currentImagePath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          game.isPaused = true;
                          _showAlertDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          Icons.cancel,
                          size: boxConstraints.maxWidth * 0.5,
                        ),
                      ),
                    );
                  }),
                ),
                //input form
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      ShowNumber(number: game.showNumber),
                      _getRules(),
                      if (game.gameProgress == 2) _getForm(),
                      if (game.gameProgress == 3) ...[
                        // add animation about spend money
                        // left part image
                        // right part -200 text (red)
                        MoneyAnimation(),
                        // Align(
                        //   alignment: const Alignment(0.05, -0.95),
                        //   child: FractionallySizedBox(
                        //     widthFactor: 0.15,
                        //     heightFactor: 0.1,
                        //     child: Consumer<UserInfoProvider>(
                        //       builder: (context, value, child) {
                        //         return AutoSizeText(
                        //           value.coins.toString(),
                        //           style: const TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 100,
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // )
                      ],
                    ],
                  ),
                ),
                Flexible(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (buildContext, boxConstraints) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Opacity(
                            opacity: game.gameProgress == 2 ? 1 : 0,
                            child: Container(
                              height: boxConstraints.maxWidth * 0.5,
                              width: boxConstraints.maxWidth * 0.5,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/global/checkButton.png'),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: game.disableButton
                                    ? null
                                    : () {
                                        if (!game.disableButton &&
                                            (game.gameProgress == 2)) {
                                          if (game.gameProgress == 2) {
                                            game.getResult();
                                          }
                                          setState(() {
                                            game.changeCurrentImage();
                                          });
                                        }
                                      },
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getForm() {
    return LayoutBuilder(
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
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                color: Colors.white,
                              ),
                            ),
                            Center(child: LayoutBuilder(
                                builder: (buildContext, boxConstraints) {
                              return AutoSizeText(
                                '彩 券 單',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'NotoSansTC_Bold',
                                    fontSize: boxConstraints.maxHeight),
                              );
                            }))
                          ])),
                    ),
                    Expanded(
                        flex: 20,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.2 * lotteryHeight / 8,
                                horizontal: 0.2 * lotteryWidth / 8),
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
                                  for (int i = 1; i <= 49; i++) ...[
                                    InkWell(
                                      onTap: () {
                                        logger.d('$i');
                                        _playPathSound('$i.mp3');
                                        setState(() {
                                          if (game.numOfChosen ==
                                                  game.numberOfDigits &&
                                              game.isChosen[i] == false) {
                                            game.isPaused = true;
                                            //show that need to cancel one of them first
                                            _exceedLimitAlertDialog().then(
                                                (_) => game.isPaused = false);
                                          } else {
                                            game.isChosen[i] =
                                                !game.isChosen[i];
                                            if (game.isChosen[i]) {
                                              game.numOfChosen++;
                                            } else {
                                              game.numOfChosen--;
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          color: game.isChosen[i]
                                              ? Colors.yellow
                                              : Colors.white,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "$i",
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontFamily: 'GSR_R'),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                                ]))),
                    Flexible(flex: 2, child: Container()),
                  ],
                ),
              ),
              Flexible(flex: 1, child: Container()),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              Expanded(
                  flex: 5,
                  child: Column(children: <Widget>[
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                        flex: 9,
                        child: GridView.count(
                            crossAxisCount: 3,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                            children: [
                              for (int i = 0; i < game.numberOfDigits; i++) ...[
                                TextFormField(
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 30),
                                    decoration: inputNumberDecoration.copyWith(
                                        hintText: '',
                                        contentPadding:
                                            const EdgeInsets.all(5)),
                                    keyboardType: TextInputType.number,
                                    validator: (val) =>
                                        val!.isEmpty ? '輸入數字' : null,
                                    textInputAction:
                                        i == game.numberOfDigits - 1
                                            ? TextInputAction.next
                                            : TextInputAction.done,
                                    onChanged: (val) {
                                      game.userArray[i] =
                                          val.isEmpty ? -1 : int.parse(val);
                                    })
                              ]
                            ]))
                  ])),
              Expanded(
                  flex: 2,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            game.end = DateTime.now();
                            //judge the result
                            game.getResult();
                            setState(() {
                              game.changeCurrentImage();
                            });
                          }
                        },
                        child: const Text('決定好了'),
                      )))
            ],
          );
        }
      },
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確定要離開嗎?'),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('遊戲將不會被記錄下來喔!!!'),
                Text('而且猜中也能拿到獎勵'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('繼續遊戲'),
              onPressed: () {
                game.isPaused = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('確定離開'),
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
          title: const Text('結果發表'),
          // this part can put multiple messages
          content:
              game.playerWin ? const Text('你贏得遊戲了!!!') : const Text('真可惜下次努力吧'),
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
                Timer(const Duration(seconds: 1), () {
                  game.setNextGame();
                  setState(() {
                    game.changeCurrentImage();
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getRules() {
    return AnimatedOpacity(
      opacity: game.gameProgress == 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(
                        color: Colors.purple,
                        width: 5,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  for (int i = 0; i < 5; i++) ...[
                    Align(
                      alignment: starPosition[i],
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.4,
                        child: Transform.rotate(
                            angle: -pi / 3 + pi * i,
                            child: Image.asset(
                                i <= game.gameLevel ? starLight : starDark)),
                      ),
                    ),
                  ],
                  Align(
                    alignment: const Alignment(0.0, 0.3),
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.3,
                      child: Center(child: rules[game.gameLevel]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: const Alignment(0.0, 1.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.3,
                        heightFactor: 0.2,
                        child: GestureDetector(
                          onTap: () {
                            Logger().i('tap');
                            setState(() {
                              game.changeCurrentImage();
                            });
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
          /*Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                // ignore: todo
                // TODO add audios
              },
              child: const AutoSizeText(
                '再聽一次',
                style:
                    TextStyle(fontSize: 30, fontFamily: 'NotoSansTC_Regular'),
                maxLines: 1,
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}

class ShowNumber extends StatelessWidget {
  const ShowNumber({
    super.key,
    required this.number,
  });

  final String number;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.7, -0.5),
      child: AnimatedOpacity(
        opacity: number != '' ? 1.0 : 0.0,
        duration: const Duration(
          milliseconds: 500,
        ),
        child: Container(
          height: 125,
          width: 125,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AutoSizeText(
            number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 125,
              color: Colors.red,
              fontFamily: 'NotoSansTC_Regular',
            ),
          ),
        ),
      ),
    );
  }
}

class MoneyAnimation extends StatefulWidget {
  const MoneyAnimation({super.key});

  @override
  State<MoneyAnimation> createState() => _MoneyAnimationState();
}

class _MoneyAnimationState extends State<MoneyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0.05, -0.95),
          child: FractionallySizedBox(
            widthFactor: 0.15,
            heightFactor: 0.1,
            child: Consumer<UserInfoProvider>(
              builder: (context, value, child) {
                return AutoSizeText(
                  value.coins.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
