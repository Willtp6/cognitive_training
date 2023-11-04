import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final RoutePlanningGameForge2d game;

  void continueCallback() {
    game.overlays.remove(ExitDialog.id);
    // game.resetGame();
    game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Globals.exitDialog(
      continueCallback: continueCallback,
      exitCallback: () {
        game.overlays.remove(ExitDialog.id);
        context.pop();
      },
      isTutorialMode: false,
    );
  }
}
