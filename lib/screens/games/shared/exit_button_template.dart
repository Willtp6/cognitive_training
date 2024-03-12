import 'package:flutter/material.dart';

abstract class ExitButtonTemplate extends StatelessWidget {
  const ExitButtonTemplate({super.key, this.alignment = Alignment.topRight});

  final Alignment alignment;
  void onTapFunction();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 10),
        child: FractionallySizedBox(
          widthFactor: 0.5 * 1 / 7,
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () {
                onTapFunction();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  border: Border.all(color: Colors.black, width: 1),
                  shape: BoxShape.circle,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.8,
                  widthFactor: 0.8,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double iconSize = constraints.maxWidth;
                      return Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: iconSize,
                      );
                    },
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
