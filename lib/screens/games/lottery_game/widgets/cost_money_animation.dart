import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CostMoneyAnimation extends StatelessWidget {
  const CostMoneyAnimation({
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
                    begin: const Offset(2.0, 1.0), end: const Offset(2.0, 0.1))
                .chain(CurveTween(curve: const Interval(0.0, 0.4)))
                .animate(_controller),
            child: SlideTransition(
              position: Tween(
                      begin: const Offset(2.0, 0.1),
                      end: const Offset(2.0, -2.0))
                  .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                  .animate(_controller),
              child: const FractionallySizedBox(
                widthFactor: 0.15,
                heightFactor: 0.1,
                child: AutoSizeText(
                  '-200',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
