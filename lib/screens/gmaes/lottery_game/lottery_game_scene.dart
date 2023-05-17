import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_model.dart';
import '../../../shared/design_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  late UserInfoProvider userInfoProvider;
  var logger = Logger(printer: PrettyPrinter());

  late final LotteryGame game;
  late AnimationController _controller;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String chosenLanguage = '中文';

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

    setLanguage();
  }

  @override
  void dispose() {
    _controller.dispose();
    mytimer?.cancel();
    player.dispose();
    super.dispose();
  }

  void setLanguage() async {
    chosenLanguage = await _prefs.then((SharedPreferences prefs) {
      return prefs.getString('chosenLanguage') ?? '中文';
    });
  }

  void _playPathSound(String path) async {
    await player.play(AssetSource('lottery_game_sound/$path'));
  }

  void _playInstruction() async {
    String path = game.getInstructionAudioPath(chosenLanguage);
    isPlaying = true;
    await player.play(AssetSource(path));
    Future.delayed(await player.getDuration() ?? const Duration(seconds: 3),
        () {
      Future.delayed(const Duration(milliseconds: 100), () {
        player.release();
        setState(() {
          isPlaying = false;
        });
      });
    });
  }

  void _playNumberSound() async {
    if (game.currentIndex < game.numberOfDigits) {
      //player = AudioPlayer();
      await player.play(AssetSource(
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
          game.setGame();
          _playInstruction();
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
          Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
            setState(() {
              game.changeCurrentImage();
              _controller.reset();
            });
          });
          _controller.forward();
          Future.delayed(const Duration(seconds: 1, milliseconds: 300), () {
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
          Future.delayed(
              const Duration(seconds: 2), () => _showGameEndDialog());
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
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(game.currentImagePath),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                Align(
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
                            child: LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double iconSize = constraints.maxWidth;
                              return Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: iconSize,
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (game.gameLevel != 1) ShowNumber(number: game.showNumber),
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 5 / 7,
                    child: _getRules(),
                  ),
                ),
                if (game.gameProgress == 2)
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 5 / 7,
                      child: _getForm(),
                    ),
                  ),
                Align(
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
                            color: Colors.white
                                .withOpacity(game.gameProgress == 3 ? 1 : 0),
                            fontSize: 100,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                      .animate(_controller),
                  child: FadeTransition(
                    opacity: Tween(begin: 1.0, end: 0.0)
                        .chain(CurveTween(curve: const Interval(0.6, 1.0)))
                        .animate(_controller),
                    child: SlideTransition(
                      position: Tween(
                              begin: const Offset(2.0, 1.0),
                              end: const Offset(2.0, 0.0))
                          .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                          .animate(_controller),
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(2.0, 0.0),
                                end: const Offset(2.0, -2.0))
                            .chain(CurveTween(curve: const Interval(0.6, 1.0)))
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
                FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                      .animate(_controller),
                  child: FadeTransition(
                    opacity: Tween(begin: 1.0, end: 0.0)
                        .chain(CurveTween(curve: const Interval(0.6, 1.0)))
                        .animate(_controller),
                    child: SlideTransition(
                      position: Tween(
                              begin: const Offset(0.0, 0.5),
                              end: const Offset(0.0, 0.3))
                          .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                          .animate(_controller),
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0.0, 0.3),
                                end: const Offset(0.0, -0.3))
                            .chain(CurveTween(curve: const Interval(0.6, 1.0)))
                            .animate(_controller),
                        child: FractionallySizedBox(
                          widthFactor: 0.3,
                          child: AspectRatio(
                            aspectRatio: 902 / 710,
                            child: Image.asset(
                                'assets/lottery_game_scene/SpendMoney.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 1 / 7,
                    child: game.gameProgress == 2 && game.gameLevel < 2
                        ? GestureDetector(
                            onTap: game.disableButton
                                ? null
                                : () {
                                    game.getResult();
                                    setState(() {
                                      game.changeCurrentImage();
                                    });
                                  },
                            child: Align(
                              alignment: const Alignment(0.9, 0.0),
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                      'assets/global/checkButton.png'),
                                  //child: Placeholder(),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
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
          int lenOfForm = game.gameLevel == 4 ? 1 : game.numberOfDigits;
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
                        child: GridView.count(
                          crossAxisCount: 3,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 25,
                          mainAxisSpacing: 5,
                          childAspectRatio: 1,
                          children: [
                            for (int i = 0; i < lenOfForm; i++) ...[
                              TextFormField(
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 30),
                                  decoration: inputNumberDecoration.copyWith(
                                      hintText: '',
                                      contentPadding: const EdgeInsets.all(5)),
                                  keyboardType: TextInputType.number,
                                  validator: (val) =>
                                      val!.isEmpty ? '輸入數字' : null,
                                  textInputAction: i != lenOfForm - 1
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  onChanged: (val) {
                                    game.userArray[i] =
                                        val.isEmpty ? -1 : int.parse(val);
                                  }),
                            ],
                          ],
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
                      heightFactor: 0.2,
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

  AnimatedOpacity _getRules() {
    List<Alignment> starPosition = [
      const Alignment(-1.0, -0.5),
      const Alignment(-0.5, -0.85),
      const Alignment(0.0, -1.0),
      const Alignment(0.5, -0.85),
      const Alignment(1.0, -0.5),
    ];
    String starLight = 'assets/lottery_game_scene/star_light.png';
    String starDark = 'assets/lottery_game_scene/star_dark.png';
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
      ),
      const AutoSizeText.rich(
        TextSpan(
          children: [
            TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
            TextSpan(text: '最大的兩個數', style: TextStyle(color: Colors.red)),
            TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
          ],
        ),
        softWrap: true,
        maxLines: 2,
        style: TextStyle(fontSize: 50),
      ),
      const AutoSizeText.rich(
        TextSpan(
          children: [
            TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
            TextSpan(text: '最小的兩個數', style: TextStyle(color: Colors.red)),
            TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
          ],
        ),
        softWrap: true,
        maxLines: 2,
        style: TextStyle(fontSize: 50),
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
        maxLines: 2,
        style: TextStyle(fontSize: 50),
      ),
      const AutoSizeText.rich(
        TextSpan(
          children: [
            TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
            TextSpan(text: '數字', style: TextStyle(color: Colors.red)),
            TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
          ],
        ),
        softWrap: true,
        maxLines: 2,
        style: TextStyle(fontSize: 50),
      ),
    ];

    return AnimatedOpacity(
      opacity: game.gameProgress == 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
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
                  heightFactor: 0.35,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Transform.rotate(
                      angle: -pi / 3 + pi * i / 10,
                      child: Image.asset(
                          i <= game.gameLevel ? starLight : starDark),
                    ),
                  ),
                ),
              ),
            ],
            Align(
              alignment: const Alignment(0.0, 0.3),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                heightFactor: 0.4,
                child: Center(
                    child: game.gameLevel < 4
                        ? rules[game.gameLevel]
                        : specialRules[game.specialRules]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: const Alignment(0.5, 1.0),
                child: FractionallySizedBox(
                  widthFactor: 0.25,
                  heightFactor: 0.15,
                  child: GestureDetector(
                    onTap: isPlaying
                        ? null
                        : () {
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: const Alignment(-0.5, 1.0),
                child: FractionallySizedBox(
                  widthFactor: 0.25,
                  heightFactor: 0.15,
                  child: GestureDetector(
                    onTap: isPlaying
                        ? null
                        : () {
                            setState(() {
                              _playInstruction();
                            });
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
                            heightFactor: 0.7,
                            widthFactor: 0.7,
                            child: Center(
                              child: AutoSizeText(
                                '再聽一次',
                                style: TextStyle(
                                    fontFamily: 'GSR_B',
                                    fontSize: 100,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
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
      alignment: const Alignment(0.35, -0.55),
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
              fontFamily: 'GSR_B',
            ),
          ),
        ),
      ),
    );
  }
}
