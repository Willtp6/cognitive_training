import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:flutter/material.dart';

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required text,
    required onTapFunction,
  })  : _text = text,
        _onTapFunction = onTapFunction;

  final String _text;
  final Function _onTapFunction;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 835 / 353,
      child: GestureDetector(
        onTap: () {
          _onTapFunction();
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Globals.orangeButton),
            ),
          ),
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 0.8,
            child: LayoutBuilder(
              builder:
                  (BuildContext buildContext, BoxConstraints boxConstraints) {
                double width = boxConstraints.maxWidth;
                return Center(
                  child: AutoSizeText(
                    _text,
                    style: TextStyle(
                      fontSize: width / 4,
                      color: Colors.white,
                      fontFamily: 'GSR_B',
                    ),
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
