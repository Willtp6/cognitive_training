import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import '../../fishing_game.dart';

class ConfirmButton extends StatelessWidget {
  static const String id = "ConfirmButton";
  const ConfirmButton({super.key, required this.game});
  final FishingGame game;

  void callback() {
    game.overlays.remove(id);
    game.makeAllRodsInvisible();
    game.getResult();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: ButtonWithText(text: '確定', onTapFunction: callback),
      ),
    );
  }
}
