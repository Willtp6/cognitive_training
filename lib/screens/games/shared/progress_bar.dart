import 'package:cognitive_training/constants/globals.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int maxProgress;
  final int continuousWin;
  const ProgressBar(
      {super.key, required this.maxProgress, required this.continuousWin});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (buildContext, constraints) {
        double dotSize = constraints.maxHeight / 2;
        return Stack(children: [
          Center(
            child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth * 0.9,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Globals.progressBar),
                    fit: BoxFit.fitWidth,
                  ),
                )),
          ),
          for (int i = 0; i < maxProgress; i++) ...[
            Positioned(
              top: dotSize / 2,
              left: i * (constraints.maxWidth - dotSize) / (maxProgress - 1),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: i < continuousWin
                        ? const AssetImage(Globals.progressBarDot)
                        : const AssetImage(Globals.progressBarDotEmpty),
                  ),
                ),
              ),
            ),
          ]
        ]);
      },
    );
  }
}
