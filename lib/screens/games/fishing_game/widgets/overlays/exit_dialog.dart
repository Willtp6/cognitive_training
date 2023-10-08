import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../fishing_game.dart';
import 'package:flutter/material.dart';

import 'exit_button.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final FishingGame game;

  void continueCallback() {
    game.overlays.remove(ExitDialog.id);
    game.overlays.add(ExitButton.id);
    game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    UserInfoProvider userInfoProvider = context.read<UserInfoProvider>();
    Logger().d(game.isTutorial);

    return Globals.exitDialog(
      continueCallback: continueCallback,
      exitCallback: () {
        game.overlays.remove(ExitDialog.id);
        if (game.isTutorial) {
          userInfoProvider.fishingGameDoneTutorial();
        }
        context.pop();
      },
      isTutorialMode: game.isTutorial,
    );
  }
}
