import 'dart:math';
import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

class AlarmClock extends StatefulWidget {
  const AlarmClock({
    super.key,
    required this.animationController,
    required this.isTutorial,
  });

  final AnimationController animationController;
  final bool isTutorial;

  @override
  State<AlarmClock> createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    animation = Tween<double>(begin: widget.isTutorial ? 10.0 : 0.0, end: 10.0)
        .animate(widget.animationController);
  }

  int getAngle(double value) {
    int stamp = value.toInt();
    if (stamp == 1 || stamp == 5 || stamp == 9) {
      return 1;
    } else if (stamp == 3 || stamp == 7) {
      return -1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.85, -0.25),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: getAngle(animation.value) * 2 * pi / 40,
                child: Opacity(
                  opacity: animation.value > 0 ? 1 : 0,
                  child: Image.asset(PokerGameConst.clock),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
