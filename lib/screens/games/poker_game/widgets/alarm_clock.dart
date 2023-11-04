import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:flutter/material.dart';

class AlarmClock extends StatefulWidget {
  const AlarmClock({
    super.key,
    required this.timeInMilliSeconds,
    required this.audioController,
    required this.isTutorial,
    required this.callback,
  });

  final int timeInMilliSeconds;
  final AudioController audioController;
  final bool isTutorial;
  final Function() callback;

  @override
  State<AlarmClock> createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.isTutorial) {
      animation = Tween<double>(begin: 10.0, end: 10.0).animate(_controller);
      _timer = Timer(const Duration(seconds: 1), () {});
    } else {
      animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
      startTimer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    if (widget.timeInMilliSeconds >= 3000) {
      _timer =
          Timer(Duration(milliseconds: widget.timeInMilliSeconds - 3000), () {
        widget.audioController.playSfx(PokerGameConst.ticTokSfx);
        _controller.forward().whenComplete(() {
          widget.audioController.stopAllSfx();
          widget.callback();
        });
      });
    } else {
      _controller.forward();
      widget.audioController.playSfx(PokerGameConst.ticTokSfx);
      _timer = Timer(Duration(milliseconds: widget.timeInMilliSeconds), () {
        _controller.reset();
        widget.audioController.stopAllSfx();
        widget.callback();
      });
    }
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
            animation: _controller,
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
