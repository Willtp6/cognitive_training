import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OpponentCoinAnimation extends StatefulWidget {
  const OpponentCoinAnimation(
      {super.key, required this.controller, required this.string});
  final AnimationController controller;
  final String string;
  @override
  State<OpponentCoinAnimation> createState() => _OpponentCoinAnimationState();
}

class _OpponentCoinAnimationState extends State<OpponentCoinAnimation> {
  final opacitySequence = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]);
  final alignmentSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(-0.625, -0.5),
            end: const Alignment(-0.625, -0.65)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(-0.625, -0.65),
            end: const Alignment(-0.625, -0.65)),
        weight: 5),
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(-0.625, -0.65),
            end: const Alignment(-0.625, -0.8)),
        weight: 1),
  ]);
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacitySequence.animate(widget.controller),
      child: AlignTransition(
        alignment: alignmentSequence.animate(widget.controller),
        child: FractionallySizedBox(
          heightFactor: 0.1,
          widthFactor: 0.15,
          child: AutoSizeText(
            widget.string,
            style: const TextStyle(
                fontFamily: 'GSR_B', fontSize: 100, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class PlayerCoinAnimation extends StatefulWidget {
  const PlayerCoinAnimation(
      {super.key, required this.controller, required this.string});
  final AnimationController controller;
  final String string;
  @override
  State<PlayerCoinAnimation> createState() => _PlayerCoinAnimationState();
}

class _PlayerCoinAnimationState extends State<PlayerCoinAnimation> {
  final opacitySequence = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]);
  final alignmentSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(0.625, -0.5),
            end: const Alignment(0.625, -0.65)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(0.625, -0.65),
            end: const Alignment(0.625, -0.65)),
        weight: 5),
    TweenSequenceItem(
        tween: Tween(
            begin: const Alignment(0.625, -0.65),
            end: const Alignment(0.625, -0.8)),
        weight: 1),
  ]);
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacitySequence.animate(widget.controller),
      child: AlignTransition(
        alignment: alignmentSequence.animate(widget.controller),
        child: FractionallySizedBox(
          heightFactor: 0.1,
          widthFactor: 0.1,
          child: AutoSizeText(
            widget.string,
            style: const TextStyle(
                fontFamily: 'GSR_B', fontSize: 100, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
