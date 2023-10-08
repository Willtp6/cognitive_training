import 'package:cognitive_training/screens/games/route_planning_game_toremove/route_planning_game.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/route_planning_game_menu.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/widgets/overlays/exit_button.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'widgets/overlays/exit_dialog.dart';

class RoutePlanningGamePlay extends StatelessWidget {
  RoutePlanningGamePlay({Key? key}) : super(key: key);

  // final RoutePlanningGame _routePlanningGame = RoutePlanningGame();
  final RoutePlanningGame _routePlanningGame = RoutePlanningGame();

  @override
  Widget build(BuildContext context) {
    Logger().d('test');
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async => false,
          // GameWidget is useful to inject the underlying
          // widget of any class extending from Flame's Game class.
          child: GameWidget(
            game: _routePlanningGame,
            // Initially only menu overlay will be visible.
            // initialActiveOverlays: const [ExitButton.id],
            // overlayBuilderMap: {
            //   // ExitButton.id: (BuildContext context, RoutePlanningGameF game) =>
            //   //     ExitButton(
            //   //       game: game,
            //   //     ),
            //   // ExitDialog.id: (BuildContext context, RoutePlanningGame game) =>
            //   //     ExitDialog(
            //   //       game: game,
            //   //     ),
            //   // RoutePlanningGameMenu.id:
            //   //     (BuildContext context, RoutePlanningGame game) =>
            //   //         RoutePlanningGameMenu(
            //   //           game: game,
            //   //         ),
            // },
          ),
        ),
      ),
    );
  }
}
