import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../lottery_game.dart';

class CorrectRateBar extends StatelessWidget {
  const CorrectRateBar({
    super.key,
    required this.game,
  });

  final LotteryGame game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, -0.5),
      child: FractionallySizedBox(
        widthFactor: 0.15,
        heightFactor: 0.15,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border.all(
              color: Colors.grey,
              width: 5,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: Center(
            child: AutoSizeText(
              '正確率 ${game.numOfCorrectAns} / ${game.getNumOfAnsDigits()}',
              style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
