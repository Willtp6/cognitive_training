import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class LotteryGame extends StatefulWidget {
  const LotteryGame({super.key});

  @override
  State<LotteryGame> createState() => _LotteryGameState();
}

class _LotteryGameState extends State<LotteryGame> {
  @override
  void initState() {
    super.initState();

    // Init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    // Change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //    overlays: SystemUiOverlay.values);
    super.dispose();
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

  String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';

  int gameProcess = 0;
  bool playerWin = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // game logic in here
    switch (gameProcess) {
      case 0:
        Timer(const Duration(seconds: 3), () {
          setState(() {
            gameProcess = 1;
          });
        });
        break;
      case 1:
        break;
      case 2:
        final player = AudioPlayer();
        player.setSource(
            AssetSource('lottery_game_sound/footsteps_in_temple.mp3'));
        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
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
        duration: const Duration(seconds: 2, milliseconds: 500),
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
                _showAlertDialog();
                //Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, shape: const CircleBorder()),
              child: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(height: 250),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  gameProcess++;
                });
              },
              child: const Text('change image'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    print('before');
    final player = AudioPlayer();
    player.play(AssetSource('lottery_game_sound/footsteps_in_temple.mp3'),
        mode: PlayerMode.lowLatency);
    print('after');
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
          content: playerWin ? Text('You win !!!') : Text('You lose.'),
          actions: <Widget>[
            TextButton(
              child: const Text('go back to home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('go to next stage'),
              onPressed: () {
                print('go to next stage');
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
