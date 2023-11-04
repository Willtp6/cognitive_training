import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../lottery_game.dart';

class TopCoin extends StatelessWidget {
  const TopCoin({
    super.key,
    required this.game,
  });

  final LotteryGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0.05, -0.95),
        child: FractionallySizedBox(
          widthFactor: 0.12,
          heightFactor: 0.1,
          child: Consumer<UserInfoProvider>(
            builder: (context, value, child) {
              return AutoSizeText(
                value.coins.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withOpacity(
                      game.gameProgress == 3 || game.gameProgress == 5 ? 1 : 0),
                  fontSize: 100,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
