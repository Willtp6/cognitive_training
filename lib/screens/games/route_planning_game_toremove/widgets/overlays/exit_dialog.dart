import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/route_planning_game_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/widgets/overlays/exit_button.dart';
import 'package:flutter/material.dart';

import '../../route_planning_game.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final RoutePlanningGame game;

  void continueCallback() {
    game.overlays.remove(ExitDialog.id);
    //game.overlays.add(ExitButton.id);
    game.resetGame();
    game.resumeEngine();
  }

  void exitCallback() {
    game.overlays.remove(ExitDialog.id);
  }

  @override
  Widget build(BuildContext context) {
    return Globals.exitDialog(
      continueCallback: continueCallback,
      exitCallback: exitCallback,
      isTutorialMode: false,
    );
  }
}
