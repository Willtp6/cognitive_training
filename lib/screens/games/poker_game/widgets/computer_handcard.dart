import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

import '../poker_game_instance.dart';

class ComputerHandCard extends StatelessWidget {
  const ComputerHandCard({
    super.key,
    required this.game,
    required AnimationController controllerChosenComputer,
    required AnimationController controller,
  })  : _controllerChosenComputer = controllerChosenComputer,
        _controller = controller;

  final GameInstance game;
  final AnimationController _controllerChosenComputer;
  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: FractionallySizedBox(
        heightFactor: 0.2,
        widthFactor: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < game.computer.hand.length; i++) ...[
              Flexible(
                child: SlideTransition(
                  position: game.isChosenComputer[i]
                      ? Tween(
                              begin: const Offset(0.0, -0.2),
                              end: const Offset(0.0, 0.0))
                          .animate(_controllerChosenComputer)
                      : Tween(
                              begin: const Offset(0.0, 0.0),
                              end: const Offset(0.0, -0.2))
                          .animate(_controllerChosenComputer),
                  child: Image.asset(PokerGameConst.cardBack,
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(
                              curve: Interval(i / game.computer.hand.length,
                                  (i + 1) / game.computer.hand.length)))
                          .animate(_controller)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
