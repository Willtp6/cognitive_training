import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Globals {
  Globals._();

  //* shared
  static const String orangeButton = "assets/images/shared/orange_button.png";
  static const String starLight = 'assets/images/shared/star_light.png';
  static const String starDark = 'assets/images/shared/star_dark.png';
  static const String progressBar = 'assets/images/shared/progress_bar_bar.png';
  static const String progressBarDot =
      'assets/images/shared/progress_bar_dot.png';
  static const String progressBarDotEmpty =
      'assets/images/shared/progress_bar_dot_empty.png';
  static const String coinWithoutTap =
      'assets/images/shared/coin_without_tap.png';

  static AlertDialog exitDialog(
      {required Function continueCallback,
      required Function exitCallback,
      required bool isTutorialMode}) {
    Logger().d(isTutorialMode);
    return AlertDialog(
      title: const Center(
        child: Text(
          '確定要離開嗎?',
          style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        ),
      ),
      // this part can put multiple messages
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Center(
              child: Text(
                isTutorialMode ? '直接離開會跳過教學模式喔!!!' : '遊戲將不會被記錄下來喔!!!',
                style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text(
            '確定離開',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            exitCallback();
          },
        ),
        TextButton(
          child: Text(
            isTutorialMode ? '繼續教學' : '繼續遊戲',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            continueCallback();
          },
        ),
      ],
    );
  }

  //* sfx
  static const String clickButtonSound = 'audio/shared/click_button.wav';
}
