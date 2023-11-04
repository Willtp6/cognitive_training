import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';

class NoCardButton extends StatelessWidget {
  const NoCardButton({
    super.key,
    required this.callBack,
  });

  final Function callBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.9, 0.2),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: ButtonWithText(
          text: '沒有',
          onTapFunction: callBack,
        ),
      ),
    );
  }
}
