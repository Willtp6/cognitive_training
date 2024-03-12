import 'package:cognitive_training/models/database_info_provider.dart';

import 'package:provider/provider.dart';

import 'widgets/overlays/exit_button.dart';
import 'route_planning_game_forge2d.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'widgets/overlays/exit_dialog.dart';
import 'widgets/overlays/route_planning_game_rule.dart';
import 'widgets/overlays/endgame_button.dart';
import 'widgets/overlays/game_win.dart';
import 'widgets/overlays/game_lose.dart';
import 'widgets/overlays/route_planning_game_tutorial_mode.dart';

class RoutePlanningGameForge2dPlay extends StatelessWidget {
  const RoutePlanningGameForge2dPlay(
      {super.key, required this.enterWithTutorialMode});

  final bool enterWithTutorialMode;

  @override
  Widget build(BuildContext context) {
    DatabaseInfoProvider databaseInfoProvider =
        context.read<DatabaseInfoProvider>();
    return SafeArea(
      child: Scaffold(
        body: PopScope(
          canPop: false,
          // GameWidget is useful to inject the underlying
          // widget of any class extending from Flame's Game class.
          child: GameWidget(
            game: RoutePlanningGameForge2d(
              gameLevel:
                  databaseInfoProvider.routePlanningGameDatabase.currentLevel,
              continuousWin: databaseInfoProvider
                  .routePlanningGameDatabase.historyContinuousWin,
              continuousLose: databaseInfoProvider
                  .routePlanningGameDatabase.historyContinuousLose,
              isTutorial: enterWithTutorialMode,
              databaseInfoProvider: databaseInfoProvider,
            ),
            // Initially only menu overlay will be visible.
            initialActiveOverlays: enterWithTutorialMode
                ? const [
                    RoutePlanningGameTutorialMode.id,
                    ExitButton.id,
                  ]
                : const [
                    RoutePlanningGameRule.id,
                    ExitButton.id,
                  ],
            overlayBuilderMap: {
              ExitButton.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      ExitButton(game: game),
              ExitDialog.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      ExitDialog(game: game),
              RoutePlanningGameRule.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      RoutePlanningGameRule(game: game),
              EndGameButton.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      EndGameButton(game: game),
              GameWin.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      GameWin(game: game),
              GameLose.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      GameLose(game: game),
              RoutePlanningGameTutorialMode.id:
                  (BuildContext context, RoutePlanningGameForge2d game) =>
                      RoutePlanningGameTutorialMode(game: game),
            },
          ),
        ),
      ),
    );
  }
}
