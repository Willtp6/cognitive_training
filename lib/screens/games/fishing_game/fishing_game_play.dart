import 'package:cognitive_training/models/user_info_provider.dart';
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

class FishingGamePlay extends StatelessWidget {
  FishingGamePlay({super.key, required this.gameLevel});

  late UserInfoProvider userInfoProvider;
  int gameLevel;
  // final FishingGame game = FishingGame(userInfoProvider: userInfoProvider);

  @override
  Widget build(BuildContext context) {
    userInfoProvider = context.read();
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          child: GameWidget(
            game: FishingGame(
                userInfoProvider: userInfoProvider, gameLevel: gameLevel),
            initialActiveOverlays: const [
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
            },
          ),
          onWillPop: () async => false,
        ),
      ),
    );
  }
}
