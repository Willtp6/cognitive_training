import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

import '../poker_game_instance.dart';

class PlayerHandCard extends StatelessWidget {
  const PlayerHandCard({
    super.key,
    required this.game,
    required AnimationController controllerChosenPlayer,
    required AnimationController controller,
    required this.callback,
  })  : _controllerChosenPlayer = controllerChosenPlayer,
        _controller = controller;

  final GameInstance game;
  final AnimationController _controllerChosenPlayer;
  final AnimationController _controller;
  final Function callback;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, 0.8),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        widthFactor: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < game.player.hand.length; i++) ...[
              Flexible(
                child: SlideTransition(
                  position: game.isChosen[i]
                      ? Tween(
                              begin: const Offset(0.0, -0.2),
                              end: const Offset(0.0, 0.0))
                          .animate(_controllerChosenPlayer)
                      : Tween(
                              begin: const Offset(0.0, 0.0),
                              end: const Offset(0.0, -0.2))
                          .animate(_controllerChosenPlayer),
                  child: GestureDetector(
                    onTap: callback(i),
                    child: Image.asset(
                      PokerGameConst.cardImageList[game.player.hand[i].suit]![
                          game.player.hand[i].rank - 1],
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(
                              curve: Interval(i / game.player.hand.length,
                                  (i + 1) / game.player.hand.length)))
                          .chain(ReverseTween(Tween(begin: 1.0, end: 0.0)))
                          .animate(_controller),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
