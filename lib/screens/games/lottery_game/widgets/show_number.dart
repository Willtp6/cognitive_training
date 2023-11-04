import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ShowNumber extends StatelessWidget {
  const ShowNumber({
    super.key,
    required this.number,
  });

  final String number;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: number.isNotEmpty ? 1.0 : 0.0,
        curve: Curves.linear,
        duration: const Duration(
          milliseconds: 500,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AutoSizeText(
                  number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 200,
                    color: Colors.red,
                    fontFamily: 'GSR_B',
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
