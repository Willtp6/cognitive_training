import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class LotteryGame extends StatefulWidget {
  const LotteryGame({super.key});

  @override
  State<LotteryGame> createState() => _LotteryGameState();
}

class _LotteryGameState extends State<LotteryGame> {
  late AudioPlayer audioPlayer;
  late Timer mytimer;

  @override
  void initState() {
    super.initState();

    // Init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    gameLevel = 0;
    gameProcess = 0;
    numberOfDigits = 2;
    playerWin = false;
    disableButton = false;
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((event) {
      onComplete();
      setState(() {});
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
  }

  void _playGameSound(String path) async {
    final player = AudioPlayer();
    await player.play(AssetSource('lottery_game_sound/$path'));
  }

  void _playNumberSound() async {
    final player = AudioPlayer();
    if (currentIndex < numberOfDigits)
      await player.play(AssetSource(
          'lottery_game_sound/${numArray[currentIndex].toString()}.mp3'));
    currentIndex++;
    if (currentIndex >= numArray.length) {
      setState(() {
        disableButton = false;
      });
    }
  }

  // background image of game process
  List<String> imagePath = [
    'assets/lottery_game_scene/Temple1_withoutWord.png',
    'assets/lottery_game_scene/Temple1_withWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/Temple2_withInstruction.png',
    'assets/lottery_game_scene/NumberInput_withoutWord.png',
    'assets/lottery_game_scene/NumberInput_withWord.png',
    'assets/lottery_game_scene/NumberInput_withButton.png',
    'assets/lottery_game_scene/BuyLotter.png',
  ];

  List<bool> centerRightButtonEnable = [
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    false,
    false
  ];

  String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';

  int gameLevel = 0;
  int gameProcess = 0;
  int numberOfDigits = 2;
  bool playerWin = false;
  bool disableButton = false;
  bool isPaused = false;
  int currentIndex = 0;
  int min = 1;
  int max = 9;

  late List<int> numArray;

  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = AudioPlayer();

    final Size size = MediaQuery.of(context).size;
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
        print(numArray);
        break;
      case 3:
        if (currentIndex < numArray.length) {
          disableButton = true;
          mytimer = Timer.periodic(Duration(seconds: 2), (timer) {
            if (!isPaused) _playNumberSound();
          });
        }
        break;
      case 4:
        Timer(const Duration(seconds: 1), () {
          setState(() {
            gameProcess += 1;
          });
        });
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        Timer(const Duration(seconds: 3), () {
          setState(() {
            gameProcess += 1;
          });
        });
        break;
      // end of game leave 5 seconds to check result
      case 8:
        Timer(const Duration(seconds: 3), () {
          _showGameEndDialog();
        });
        break;
    }
    return Container(
      height: size.height,
      width: size.width,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1, milliseconds: 500),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: gameProcess <= 7
                ? AssetImage(imagePath[gameProcess])
                : playerWin
                    ? AssetImage(imagePathWin)
                    : AssetImage(imagePathLose),
            fit: BoxFit.fill,
          ),
        ),
        curve: Curves.linear,
        child: Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
              onPressed: () {
                isPaused = true;
                _showAlertDialog();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, shape: const CircleBorder()),
              child: const Icon(
                Icons.cancel,
                size: 40,
              ),
            ),
          ),
          if (centerRightButtonEnable[gameProcess]) ...[
            const SizedBox(height: 125),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: disableButton
                    ? null
                    : () {
                        setState(() {
                          gameProcess++;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: disableButton ? Colors.grey : Colors.green,
                  shape: CircleBorder(),
                ),
                child: const Icon(
                  Icons.arrow_circle_right,
                  size: 40,
                ),
              ),
            ),
          ]
        ]),
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
              child: const Text('go to next level'),
              onPressed: () {
                Navigator.of(context).pop();
                gameLevel++;
                setState(() {
                  gameProcess = 0;
                });
                print('go to next level');
                //Navigator.of(context).pop();
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onComplete() {}
}
