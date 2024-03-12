import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/fishing_game/widgets/overlays/fishing_game_rule.dart';
import 'package:provider/provider.dart';

import 'widgets/overlays/exit_dialog.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'fishing_game.dart';
import 'widgets/overlays/exit_button.dart';
import 'widgets/overlays/top_coins.dart';
import 'widgets/overlays/result_dialog.dart';
import 'widgets/overlays/confirm_button.dart';
import 'widgets/overlays/fishing_game_tutorial_mode.dart';

class FishingGamePlay extends StatelessWidget {
  const FishingGamePlay({super.key, required this.enterWithTutorialMode});

  final bool enterWithTutorialMode;

  @override
  Widget build(BuildContext context) {
    DatabaseInfoProvider databaseInfoProvider =
        context.read<DatabaseInfoProvider>();
    AudioController audioController = context.read<AudioController>();
    return SafeArea(
      child: Scaffold(
        body: PopScope(
          canPop: false,
          child: GameWidget(
            game: FishingGame(
              gameLevel: databaseInfoProvider.fishingGameDatabase.currentLevel,
              continuousWin:
                  databaseInfoProvider.fishingGameDatabase.historyContinuousWin,
              continuousLose: databaseInfoProvider
                  .fishingGameDatabase.historyContinuousLose,
              isTutorial: enterWithTutorialMode,
              databaseInfoProvider: databaseInfoProvider,
              audioController: audioController,
            ),
            initialActiveOverlays: enterWithTutorialMode
                ? [
                    FishingGameTutorialMode.id,
                    ExitButton.id,
                  ]
                : const [
                    FishingGameRule.id,
                    ExitButton.id,
                  ],
            overlayBuilderMap: {
              FishingGameRule.id: (BuildContext context, FishingGame game) =>
                  FishingGameRule(game: game),
              ExitButton.id: (BuildContext context, FishingGame game) =>
                  ExitButton(game: game),
              ExitDialog.id: (BuildContext context, FishingGame game) =>
                  ExitDialog(game: game),
              TopCoins.id: (BuildContext context, FishingGame game) =>
                  TopCoins(game: game),
              ResultDialog.id: (BuildContext context, FishingGame game) =>
                  ResultDialog(game: game),
              ConfirmButton.id: (BuildContext context, FishingGame game) =>
                  ConfirmButton(game: game),
              FishingGameTutorialMode.id:
                  (BuildContext context, FishingGame game) =>
                      FishingGameTutorialMode(game: game),
            },
          ),
        ),
      ),
    );
  }
}
