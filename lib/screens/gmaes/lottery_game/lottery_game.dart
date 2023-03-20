import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

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

  late AudioPlayer player;

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    // Init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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
    player.dispose();
  }

  void _playGameSound(String path) async {
    player = AudioPlayer();
    await player.play(AssetSource('lottery_game_sound/$path'));
  }

  void _playNumberSound() async {
    if (currentIndex < numberOfDigits) {
      player = AudioPlayer();
      await player.play(AssetSource(
          'lottery_game_sound/${numArray[currentIndex].toString()}.mp3'));
      setState(() {
        showNumber = numArray[currentIndex].toString();
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showNumber = "";
        });
      });
    }
    currentIndex++;
    if (currentIndex >= numArray.length) {
      cancelTimer();
      setState(() {
        disableButton = false;
      });
    }
  }

  void startTimer() {
    roundTimerCreated = true;
    mytimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _playNumberSound();
    });
  }

  void cancelTimer() {
    if (mytimer != null) {
      mytimer!.cancel();
      logger.v('Timer canceled');
    }
  }

  // background image of game process
  List<String> imagePath = [
    'assets/lottery_game_scene/Temple1_withoutWord.png',
    'assets/lottery_game_scene/Temple1_withWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/Temple2_withInstruction.png',
    'assets/lottery_game_scene/NumberInput_withWord.png',
    'assets/lottery_game_scene/NumberInput_withButton.png',
    'assets/lottery_game_scene/BuyLotter.png',
  ];

  List<bool> centerRightButtonEnable = [
    false,
    true,
    true,
    true,
    true,
    true,
    false,
    false
  ];

  String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';
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
  bool roundTimerCreated = false;
  int currentIndex = 0;
  int loseInCurrentDigits = 0;
  int min = 1; // min of possible number
  int max = 9; // max of possible number
  String showNumber = '';

  @override
  Widget build(BuildContext context) {
    //final Size size = MediaQuery.of(context).size;
    final formKey = GlobalKey<FormState>();
    // game logic in here
    switch (gameProcess) {
      case 0:
        // to go to next page
        Timer(const Duration(seconds: 2), () {
          setState(() {
            gameProcess = 1;
          });
        });
        break;
      case 1:
        break;
      case 2:
        _playGameSound('footsteps_in_temple.mp3');
        // generate num array here
        numArray = List.generate(
            numberOfDigits, (index) => min + Random().nextInt(max - min));
        userArray = List.generate(numberOfDigits, (index) => -1);
        logger.d(numArray);
        roundTimerCreated = false;
        break;
      case 3:
        if (!roundTimerCreated) {
          startTimer();
        }
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        Timer(const Duration(seconds: 3), () {
          setState(() {
            gameProcess = 7;
          });
        });
        break;
      case 7:
        Timer(const Duration(seconds: 3), () {
          _showGameEndDialog();
        });
        break;
      // end of game leave 5 seconds to check result
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1, milliseconds: 500),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: gameProcess < 7
                  ? AssetImage(imagePath[gameProcess])
                  : playerWin
                      ? AssetImage(imagePathWin)
                      : AssetImage(imagePathLose),
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
                      size: 40,
                    ),
                  ),
                ),
              ),
              //input form
              Expanded(
                flex: 5,
                child: gameProcess == 3
                    ? Text(
                        showNumber,
                        style: const TextStyle(
                          fontSize: 100,
                          color: Colors.red,
                        ),
                      )
                    : gameProcess == 5
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: Form(
                              key: formKey,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      padding: const EdgeInsets.all(20),
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      children: [
                                        for (int i = 0;
                                            i < numberOfDigits;
                                            i++) ...[
                                          SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: TextFormField(
                                              maxLength: 1,
                                              decoration: inputNumberDecoration
                                                  .copyWith(hintText: ''),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (val) => val!.isEmpty
                                                  ? 'Enter a number'
                                                  : null,
                                              onChanged: (val) {
                                                userArray[i] = int.parse(val);
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          logger.v(numArray);
                                          userArray.sort();
                                          logger.v(userArray);
                                        }
                                      },
                                      child: const Text('done'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 125,
                            child: AnimatedOpacity(
                              // If the widget is visible, animate to 0.0 (invisible).
                              // If the widget is hidden, animate to 1.0 (fully visible).
                              opacity: gameProcess == 2 ? 1.0 : 0.0,
                              duration: const Duration(
                                seconds: 1,
                                milliseconds: 500,
                              ),
                              // The green box must be a child of the AnimatedOpacity widget.
                              child: Text(gmaeRules[gameLevel]),
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
                                  setState(() {
                                    gameProcess++;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                disableButton ? Colors.grey : Colors.green,
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.arrow_circle_right,
                            size: 40,
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
              child: const Text('continue ?'),
              onPressed: () {
                Navigator.of(context).pop();
                if (numberOfDigits == 8) {
                  gameLevel++;
                  numberOfDigits = 2;
                } else {
                  numberOfDigits++;
                }
                setState(() {
                  currentIndex = 0;
                  gameProcess = 0;
                });
                logger.d('go to next level');
              },
            ),
          ],
        );
      },
    );
  }
}
