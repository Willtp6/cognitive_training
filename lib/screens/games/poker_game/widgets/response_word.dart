import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

import '../poker_game_instance.dart';

class ResponseWord extends StatelessWidget {
  const ResponseWord({
    super.key,
    required this.game,
  });

  final GameInstance game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.6, -0.5),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        widthFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1077 / 352,
          child: Image.asset(
            game.resultType == ResultType.win
                ? PokerGameConst.winFeedback
                : PokerGameConst.loseFeedback,
          ),
        ),
      ),
    );
  }
}
