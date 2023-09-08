import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GameLabel extends StatelessWidget {
  const GameLabel({super.key, required this.labelText});

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, -0.7),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: FittedBox(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 8),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AutoSizeText(
                  labelText,
                  style: const TextStyle(
                    fontFamily: "GSR_B",
                    fontSize: 100,
                    color: Colors.black,
                    decoration: TextDecoration.none,
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
