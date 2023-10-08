import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/widgets/overlays/game_win.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';

class EndGameButton extends StatelessWidget {
  static const id = 'EndGameButton';
  final RoutePlanningGameForge2d game;
  const EndGameButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        heightFactor: 0.2,
        child: ButtonWithText(
            text: '到 家',
            onTapFunction: () {
              FlameAudio.bgm.stop();
              game.overlays.remove(id);
              game.overlays.add(GameWin.id);
              game.resetGame();
              // game.overlays.add(RoutePlanningGameRule.id);
            }),
      ),
    );
  }
}
