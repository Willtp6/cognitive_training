import 'widgets/overlays/exit_button.dart';
import 'route_planning_game_forge2d.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'widgets/overlays/exit_dialog.dart';
import 'widgets/overlays/route_planning_game_rule.dart';
import 'widgets/overlays/endgame_button.dart';
import 'widgets/overlays/game_win.dart';
import 'widgets/overlays/game_lose.dart';

class RoutePlanningGameForge2dPlay extends StatelessWidget {
  RoutePlanningGameForge2dPlay({Key? key}) : super(key: key);

  // final RoutePlanningGame _routePlanningGame = RoutePlanningGame();
  final RoutePlanningGameForge2d _routePlanningGameForge2d =
      RoutePlanningGameForge2d();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async => false,
          // GameWidget is useful to inject the underlying
          // widget of any class extending from Flame's Game class.
          child: GameWidget(
            game: _routePlanningGameForge2d,
            // Initially only menu overlay will be visible.
            initialActiveOverlays: const [
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
            },
          ),
        ),
      ),
    );
  }
}
