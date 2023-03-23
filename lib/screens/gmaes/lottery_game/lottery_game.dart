import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../shared/design_type.dart';

class LotteryGame extends StatefulWidget {
  const LotteryGame({super.key});

  @override
  State<LotteryGame> createState() => _LotteryGameState();
}

class _LotteryGameState extends State<LotteryGame> {
  Timer? mytimer;
  late List<int> numArray;
  late List<int> userArray;
  static final formKey = GlobalKey<FormState>();

  AudioPlayer? player;
  // background image of game process
  final List<String> imagePath = [
    'assets/lottery_game_scene/Temple1_withoutWord.png',
    'assets/lottery_game_scene/Temple1_withWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/NumberInput_withWord.png',
    'assets/lottery_game_scene/NumberInput_withoutWord.png',
    'assets/lottery_game_scene/BuyLotter.png',
  ];

  List<bool> centerRightButtonEnable = [
    false,
    true,
    true,
    true,
    false,
    false,
    false,
    false
  ];

  final String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  final String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';
  List<String> gmaeRules = [
    'level 1 rule',
    'level 2 rule',
    'level 3 rule',
    'level 4 rule',
    'level 5 rule'
  ];

  int gameLevel = 0;
  int gameProcess = 0;
  int numberOfDigits = 2;
  bool playerWin = false;
  bool disableButton = false;
  bool isPaused = false;
  bool isCaseFunctioned = false;
  bool doneTutorialMode = false;
  int currentIndex = 0;
  int loseInCurrentDigits = 0;
  int continuousWinInEightDigits = 0;
  int min = 1; // min of possible number
  int max = 9; // max of possible number
  int specialRules = 0;
  String showNumber = '';
  int numOfCorrectAns = 0;
  String _currentImagePath =
      'assets/lottery_game_scene/Temple1_withoutWord.png';

  late DateTime start;
  late DateTime end;
  var logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    // Init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

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
    // Change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
    mytimer?.cancel();
    player?.dispose();
  }

  void changeImage() {
    setState(() {
      isCaseFunctioned = false;
      gameProcess++;
      _currentImagePath = gameProcess < 7
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
      await player!.play(AssetSource(
          'lottery_game_sound/${numArray[currentIndex].toString()}.mp3'));
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
          if (numArray[i] == userArray[i]) {
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
    gameProcess = 0;
    changeImage();
  }

  Future<void> recordGame(User user) {
    logger.d(user.uid);
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user.uid)
        .collection('game1')
        .doc(DateTime.now().toString());
    return reference
        .set({
          'game_record': {
            'gameDifficulties': gameLevel + 1,
            'numOfDigits': numberOfDigits,
            'accuracy': numOfCorrectAns / numberOfDigits,
            'responseTime(seconds)': end.difference(start).inSeconds,
          }
        })
        .then((value) => logger.d('succeed'))
        .catchError((error) => logger.d(error.message));
  }

  @override
  Widget build(BuildContext context) {
    //listen and reset the state
    final user = FirebaseAuth.instance.currentUser;
    var userInfoProvider = context.watch<UserInfoProvider>();

    if (!isCaseFunctioned) {
      isCaseFunctioned = true;
      switch (gameProcess) {
        case 0:
          Timer(const Duration(seconds: 2, milliseconds: 500), () {
            changeImage();
          });
          break;
        case 1:
          break;
        case 2:
          _playPathSound('footsteps_in_temple.mp3');
          // generate num array here
          numArray = List.generate(
              numberOfDigits, (index) => min + Random().nextInt(max - min));
          userArray = List.generate(numberOfDigits, (index) => -1);
          logger.d(numArray);
          isCaseFunctioned = false;
          break;
        case 3:
          startTimer();
          break;
        case 4:
          Timer(const Duration(seconds: 1, milliseconds: 500), () {
            changeImage();
          });
          break;
        case 5:
          start = DateTime.now();
          break;
        case 6:
          recordGame(user!);
          Timer(const Duration(seconds: 3), () {
            changeImage();
          });
          break;
        case 7:
          Timer(const Duration(seconds: 1), () {
            if (playerWin) {
              userInfoProvider.coins = userInfoProvider.coins + 10;
              _playPathSound("Applause.mp3");
            } else {
              userInfoProvider.coins = userInfoProvider.coins - 10;
              _playPathSound("horror_lose.wav");
            }
          });
          Timer(const Duration(seconds: 3), () {
            _showGameEndDialog();
          });
          break;
        // end of game leave 5 seconds to check result
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1, milliseconds: 0),
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage(_currentImagePath),
              fit: BoxFit.fill,
            ),
          ),
          curve: Curves.fastOutSlowIn,
          child: Row(
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
                      size: 70,
                    ),
                  ),
                ),
              ),
              //input form
              Expanded(
                flex: 5,
                child: gameProcess == 3
                    ? _showNumber()
                    : gameProcess == 5
                        ? _getForm()
                        : AnimatedOpacity(
                            opacity: gameProcess == 2 ? 1.0 : 0.0,
                            duration: const Duration(
                              seconds: 1,
                            ),
                            child: Container(
                              color: Colors.white.withOpacity(0.7),
                              child: Text(
                                gmaeRules[gameLevel],
                                style: const TextStyle(fontSize: 100),
                              ),
                            ),
                          ),
              ),
              Expanded(
                flex: 1,
                child: centerRightButtonEnable[gameProcess]
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
                            size: 70,
                          ),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
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
        children: <Widget>[
          Expanded(
              flex: 3,
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
                      for (int i = 0; i < numberOfDigits; i++) ...[
                        TextFormField(
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 30),
                          decoration: inputNumberDecoration.copyWith(
                              hintText: '',
                              contentPadding: const EdgeInsets.all(5)),
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val!.isEmpty ? 'Enter a number' : null,
                          onChanged: (val) {
                            userArray[i] = val.isEmpty ? -1 : int.parse(val);
                          },
                        ),
                      ],
                    ],
                  ),
                )
              ])),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    end = DateTime.now();
                    //judge the result
                    getResult();
                    changeImage();
                  }
                },
                child: const Text('done'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('leave the game ?'),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('The game process info won\'t be recorded !'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                isPaused = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
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

  Future<void> _showGameEndDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Result'),
          // this part can put multiple messages
          content:
              playerWin ? const Text('You win !!!') : const Text('You lose.'),
          actions: <Widget>[
            TextButton(
              child: const Text('go back to home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('continue'),
              onPressed: () {
                Navigator.of(context).pop();
                if (playerWin) {
                  if (numberOfDigits == 8) {
                    continuousWinInEightDigits++;
                    if (continuousWinInEightDigits == 2) levelUpgrades();
                  } else {
                    //temporary rules
                    numberOfDigits++;
                    loseInCurrentDigits = 0;
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
