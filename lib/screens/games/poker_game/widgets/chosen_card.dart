import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

import '../models/poker_card.dart';

class ComputerChosenCard extends StatelessWidget {
  const ComputerChosenCard({
    super.key,
    required this.card,
  });

  final PokerCard? card;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.05, 0.25),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..rotateX(0.5)
            ..rotateZ(0.5),
          child: card != null
              ? Image.asset(
                  PokerGameConst.cardImageList[card!.suit]![card!.rank - 1])
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}

class PlayerChosenCard extends StatelessWidget {
  const PlayerChosenCard({
    super.key,
    required this.card,
  });

  final PokerCard? card;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.05, 0.25),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..rotateX(0.5)
            ..rotateZ(-0.5),
          child: card != null
              ? Image.asset(
                  PokerGameConst.cardImageList[card!.suit]![card!.rank - 1])
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}
