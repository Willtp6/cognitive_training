import 'package:go_router/go_router.dart';

import '../../fishing_game.dart';
import 'package:flutter/material.dart';
import 'fishing_game_rule.dart';
import 'exit_button.dart';

class ResultDialog extends StatelessWidget {
  static const id = "ResultDialog";
  const ResultDialog({super.key, required this.game});
  final FishingGame game;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          '結果發表',
          style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        ),
      ),
      // this part can put multiple messages
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Center(
              child: Text(
                game.ansRod == game.playerChosenRod ? '釣到大魚囉' : '可惜沒有釣到',
                style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
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
            game.overlays.remove(ResultDialog.id);
            game.overlays.add(ExitButton.id);
            if (game.gameLevelChanged) {
              game.removeAll(game.rodComponents);
              game.removeAll(game.rippleTimers);
              game.overlays.add(FishingGameRule.id);
              game.backGroundComponent.changeToFishing();
            } else {
              game.resetGame();
              game.resumeEngine();
            }
          },
        ),
        TextButton(
          child: const Text(
            '離開遊戲',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            game.overlays.remove(ResultDialog.id);
            context.pop();
          },
        ),
      ],
    );
  }
}
