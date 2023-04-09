import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../models/user.dart';
import '../../../shared/design_type.dart';

class LotteryGame extends StatefulWidget {
  final startLevel;
  final startDigit;
  final isTutorial;

  LotteryGame({super.key, this.startLevel, this.startDigit, this.isTutorial});

  @override
  State<LotteryGame> createState() => _LotteryGameState();
}

class _LotteryGameState extends State<LotteryGame>
    with SingleTickerProviderStateMixin {
  Timer? mytimer;
  late List<int> numArray;
  late List<int> userArray;
  late AnimationController _controller;
  static final formKey = GlobalKey<FormState>();

  AudioPlayer? player;
  // background image of game process
  final List<String> imagePath = [
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/NumberInput_withWord.png',
    'assets/lottery_game_scene/NumberInput_recognition.png',
    'assets/lottery_game_scene/BuyLotter.png',
  ];

  final String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  final String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';
  List<String> gameRules = [
    '接下來你會聽到加看到數字，請試著記下所有的數字吧(不用依照順序喔)',
    'level 2 rule',
    'level 3 rule',
    'level 4 rule',
    'level 5 rule'
  ];

  late int gameLevel = 0;
  int gameProcess = 0;
  late int numberOfDigits = 2;
  bool playerWin = false;
  bool disableButton = false;
  bool isPaused = false;
  bool isCaseFunctioned = false;
  bool doneTutorialMode = false;
  int numOfChosen = 0;
  int currentIndex = 0;
  int loseInCurrentDigits = 0;
  int continuousWinInEightDigits = 0;
  int min = 1; // min of possible number
  int max = 9; // max of possible number
  int specialRules = 0;
  String showNumber = '';
  int numOfCorrectAns = 0;
  String _currentImagePath =
      'assets/lottery_game_scene/Temple2_withoutWord.png';

  late DateTime start;
  late DateTime end;
  late int startLevel;
  late int startDigit;
  late bool isTutorial;
  late UserInfoProvider userInfoProvider;
  late List<bool> isChosen;
  var logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    // initialize the controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );

    startLevel = widget.startLevel;
    startDigit = widget.startDigit;
    isTutorial = widget.isTutorial;
    // logger.d(widget.startLevel);
    // logger.d(widget.startDigit);
    // logger.d(widget.isTutorial);
    gameLevel = startLevel;
    numberOfDigits = startDigit;

    Future.delayed(Duration.zero, () {
      for (var imagePath in imagePath) {
        precacheImage(AssetImage(imagePath), context);
      }
      precacheImage(AssetImage(imagePathWin), context);
      precacheImage(AssetImage(imagePathLose), context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    mytimer?.cancel();
    player?.dispose();
    super.dispose();
  }

  List<int> generateUniqueRandomNumbers(int min, int max, int count) {
    if (count > (max - min + 1)) {
      throw Exception(
          "Count must be less than or equal to the range between min and max.");
    }

    Random random = Random();
    Set<int> usedNumbers = {};
    List<int> results = [];

    while (usedNumbers.length < count) {
      int randomNumber = min + random.nextInt(max - min + 1);
      if (!usedNumbers.contains(randomNumber)) {
        usedNumbers.add(randomNumber);
        results.add(randomNumber);
      }
    }

    return results;
  }

  void changeImage() {
    setState(() {
      isCaseFunctioned = false;
      gameProcess++;
      _currentImagePath = gameProcess < 5
          ? imagePath[gameProcess]
          : playerWin
              ? imagePathWin
              : imagePathLose;
    });
  }

  void _playPathSound(String path) async {
    player = AudioPlayer();
    await player!.play(AssetSource('lottery_game_sound/$path'));
  }

  void _playNumberSound() async {
    if (currentIndex < numberOfDigits) {
      player = AudioPlayer();
      // await player!.play(AssetSource(
      //     'lottery_game_sound/${numArray[currentIndex].toString()}.mp3'));
      setState(() {
        showNumber = numArray[currentIndex].toString();
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showNumber = "";
        });
      });
    } else {
      cancelTimer();
    }
    currentIndex++;
  }

  void startTimer() {
    mytimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isPaused) _playNumberSound();
    });
    setState(() {
      isCaseFunctioned = true;
      disableButton = true;
    });
  }

  void cancelTimer() {
    if (mytimer != null) {
      mytimer!.cancel();
      setState(() {
        disableButton = false;
      });
      changeImage();
    }
  }

  void randomGenerateRules() {
    specialRules = Random().nextInt(4);
  }

  void getResult() {
    numOfCorrectAns = 0;
    switch (gameLevel) {
      case 0:
      case 1:
        numArray.sort();
        userArray.sort();
        for (int i = 0; i < numArray.length; i++) {
          if (isChosen[numArray[i]]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 2:
      case 3:
        for (int i = 0; i < numArray.length; i++) {
          if (numArray[i] == userArray[i]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 4:
        switch (specialRules) {
          case 0:
          case 1:
          case 2:
          case 3:
            break;
        }
        break;
      default:
        break;
    }
    numOfCorrectAns == numArray.length ? playerWin = true : playerWin = false;
  }

  void levelUpgrades() {
    currentIndex = 0;
    loseInCurrentDigits = 0;
    continuousWinInEightDigits = 0;
    numberOfDigits = 2;
    gameProcess = 0;
    gameLevel++;
  }

  void setForNextGame() {
    playerWin = false;
    currentIndex = 0;
    gameProcess = -1; // because change Image will add the process
    changeImage();
  }

  @override
  Widget build(BuildContext context) {
    //listen and reset the state
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    if (!isCaseFunctioned) {
      isCaseFunctioned = true;
      switch (gameProcess) {
        case 0:
          numArray = generateUniqueRandomNumbers(1, 49, numberOfDigits);
          userArray = List.generate(numberOfDigits, (index) => -1);
          logger.d(numArray);
          isChosen = List.generate(50, (index) => false);
          numOfChosen = 0;
          // ignore: todo
          //TODO will add audio to play game rule
          _controller.reset();
          _controller.forward();
          break;
        case 1:
          startTimer();
          break;
        case 2:
          Timer(const Duration(seconds: 1, milliseconds: 500), () {
            changeImage();
          });
          break;
        case 3:
          start = DateTime.now();
          break;
        case 4:
          end = DateTime.now();
          // record this game
          RecordLotteryGame().recordGame(
              gameLevel: gameLevel,
              numberOfDigits: numberOfDigits,
              numOfCorrectAns: numOfCorrectAns,
              end: end,
              start: start);
          Timer(const Duration(seconds: 2), () {
            changeImage();
          });
          break;
        case 5:
          Timer(const Duration(milliseconds: 250), () {
            if (playerWin) {
              userInfoProvider.coins = userInfoProvider.coins + 10;
              _playPathSound("Applause.mp3");
            } else {
              userInfoProvider.coins = userInfoProvider.coins - 10;
              _playPathSound("horror_lose.wav");
            }
          });
          if (playerWin) {
            if (numberOfDigits == 8) {
              continuousWinInEightDigits++;
              if (continuousWinInEightDigits == 2) levelUpgrades();
            } else {
              //temporary rules
              numberOfDigits++;
              if (loseInCurrentDigits > 0) loseInCurrentDigits--;
            }
          } else {
            if (numberOfDigits == 8) continuousWinInEightDigits = 0;
            loseInCurrentDigits++;
            if (loseInCurrentDigits >= 2) {
              if (numberOfDigits > 2) {
                numberOfDigits--;
                loseInCurrentDigits = 0;
              }
            }
          }
          LotteryGameDatabase data = LotteryGameDatabase(
              currentLevel: gameLevel,
              currentDigit: numberOfDigits,
              doneTutorial: isTutorial);
          userInfoProvider.lotteryGameDatabase = data;
          Timer(const Duration(seconds: 2), () {
            _showGameEndDialog();
          });
          break;
        // end of game leave 5 seconds to check result
      }
    }
    return WillPopScope(
      onWillPop: () async {
        showDialog(
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
                    isPaused = false;
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('確定離開'),
                  onPressed: () {
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
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_currentImagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        isPaused = true;
                        _showAlertDialog();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: const CircleBorder()),
                      child: const Icon(
                        Icons.cancel,
                      ),
                    ),
                  ),
                ),
                //input form
                Expanded(
                  flex: 5,
                  child: gameProcess == 1
                      ? _showNumber()
                      : gameProcess == 3
                          ? _getForm()
                          : AnimatedOpacity(
                              opacity: gameProcess == 0 ? 1.0 : 0.0,
                              duration: const Duration(seconds: 1),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    color: Colors.white.withOpacity(0.7),
                                    child: AutoSizeText(
                                      gameRules[gameLevel],
                                      style: const TextStyle(fontSize: 100),
                                      maxLines: 3,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO add audios
                                    },
                                    child: const AutoSizeText(
                                      '再聽一次',
                                      style: TextStyle(fontSize: 30),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
                Expanded(
                  flex: 1,
                  child: gameProcess == 0 || gameProcess == 3
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: disableButton
                                ? null
                                : () {
                                    changeImage();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  disableButton ? Colors.grey : Colors.green,
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(
                              Icons.arrow_circle_right,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Align _showNumber() {
    return Align(
      alignment: const Alignment(0.7, -0.5),
      child: AnimatedOpacity(
        opacity: showNumber != '' ? 1.0 : 0.0,
        duration: const Duration(
          milliseconds: 500,
        ),
        child: Container(
          height: 125,
          width: 125,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10)),
          child: Text(
            showNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 100,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Form _getForm() {
    return Form(
        key: formKey,
        child: Row(
          children: [
            Flexible(flex: 1, child: Placeholder()),
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  Flexible(flex: 2, child: Placeholder()),
                  Expanded(flex: 3, child: Placeholder()),
                  Expanded(
                    flex: 20,
                    child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 7,
                        padding: EdgeInsets.zero,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1.5,
                        children: [
                          for (int i = 1; i <= 49; i++) ...[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                color:
                                    isChosen[i] ? Colors.yellow : Colors.white,
                              ),
                              child: Center(
                                child: GestureDetector(
                                    onTap: () {
                                      logger.d('$i');
                                      setState(() {
                                        if (numOfChosen == numberOfDigits &&
                                            isChosen[i] == false) {
                                          //show that need to cancel one of them first
                                          _exceedLimitAlertDialog();
                                        } else {
                                          isChosen[i] = !isChosen[i];
                                          if (isChosen[i]) {
                                            numOfChosen++;
                                          } else {
                                            numOfChosen--;
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      child: Text("$i",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                    )),
                              ),
                            ),
                          ]
                        ]),
                  ),
                  Flexible(flex: 1, child: Placeholder()),
                ],
              ),
            ),
            Flexible(flex: 1, child: Placeholder()),
          ],
        )
        /*Row(children: <Widget>[
          Expanded(
              flex: 5,
              child: Column(children: <Widget>[
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 9,
                    child: )
              ])),
          /*Expanded(
              flex: 2,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      /*if (formKey.currentState!.validate()) {
                        end = DateTime.now();
                        //judge the result
                        getResult();
                        changeImage();
                      }*/
                      changeImage();
                    },
                    child: const Text('決定好了'),
                  )))*/
        ]),*/
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
                isPaused = false;
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
                Text('最多只能劃記$numberOfDigits個數字'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                isPaused = false;
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
          content: playerWin ? const Text('你贏得遊戲了!!!') : const Text('真可惜下次努力吧'),
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
                  setForNextGame();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
