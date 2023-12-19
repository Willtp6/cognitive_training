import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../poker_game_instance.dart';

class OpponentCoin extends StatelessWidget {
  const OpponentCoin({
    super.key,
    required this.game,
  });

  final GameInstance game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.625, -0.825),
      child: FractionallySizedBox(
        heightFactor: 0.08,
        widthFactor: 0.1,
        child: Center(
          child: AutoSizeText(
            game.opponentCoin.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'GSR_B',
              fontSize: 100,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}

class PlayerCoin extends StatelessWidget {
  const PlayerCoin({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.65, -0.825),
      child: FractionallySizedBox(
        heightFactor: 0.08,
        widthFactor: 0.1,
        child:
            Consumer<DatabaseInfoProvider>(builder: (context, provider, child) {
          return Center(
            child: AutoSizeText(
              provider.coins.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'GSR_B',
                fontSize: 100,
              ),
              textAlign: TextAlign.end,
            ),
          );
        }),
      ),
    );
  }
}
