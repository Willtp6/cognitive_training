import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String imagePath = 'assets/lottery_game_scene/Temple1_withoutWord.png';

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isChanged = false;

    return Container(
      height: size.height,
      width: size.width,
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(children: [
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              _showAlertDialog();
              //Navigator.pop(context);
            },
            child: Text('sdas'),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              setState(() {
                imagePath = 'assets/lottery_game_scene/Temple1_withWord.png';
                isChanged = !isChanged;
              });
              print('change');
            },
            child: Text('change image'),
          ),
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
}
