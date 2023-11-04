import 'package:cognitive_training/constants/lottery_game_const.dart';
import 'package:flutter/material.dart';

class MoneyAnimation extends StatelessWidget {
  const MoneyAnimation({
    super.key,
    required AnimationController controller,
  }) : _controller = controller;

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.4)))
            .animate(_controller),
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: const Interval(0.7, 1.0)))
              .animate(_controller),
          child: SlideTransition(
            position: Tween(
                    begin: const Offset(0.0, 0.5), end: const Offset(0.0, 0.3))
                .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                .animate(_controller),
            child: SlideTransition(
              position: Tween(
                      begin: const Offset(0.0, 0.3),
                      end: const Offset(0.0, -0.3))
                  .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                  .animate(_controller),
              child: FractionallySizedBox(
                widthFactor: 0.3,
                child: AspectRatio(
                  aspectRatio: 902 / 710,
                  child: Image.asset(LotteryGameConst.moneyWithWings),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
