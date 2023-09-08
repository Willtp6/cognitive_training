import 'package:cognitive_training/screens/games/route_planning_game/route_planning_game_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game/widgets/overlays/exit_button.dart';
import 'package:flutter/material.dart';

import '../../route_planning_game.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final RoutePlanningGame game;

  @override
  Widget build(BuildContext context) {
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
            game.overlays.remove(ExitDialog.id);
            //game.overlays.add(ExitButton.id);
            game.resetGame();
            game.resumeEngine();
          },
        ),
        TextButton(
          child: const Text(
            '確定離開',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            game.overlays.remove(ExitDialog.id);
            //game.overlays.add(RoutePlanningGameMenu.id);
          },
        ),
      ],
    );
  }
}
