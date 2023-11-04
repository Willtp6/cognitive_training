import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/tutorial_mode_const.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';

class HomeTutorial {
  HomeTutorial();

  bool isTutorial = false;
  int tutorialProgress = 0;
  List<String> tutorialMessage = [
    '我是小幫手，現在要選擇想玩的遊戲!',
    '點選想玩的遊戲，會出現遊戲的介紹跟訓練的內容',
    '接著畫面中央會出現開始遊戲，按下去就可以開始囉!',
  ];
  List<String> arrowPath = [
    TutorialModeConst.leftArrow,
    TutorialModeConst.rightArrow
  ];
  List<Alignment> arrowAlignment = [
    const Alignment(-0.4, 0.0),
    const Alignment(0.0, 1.0)
  ];

  AnimatedOpacity tutorialButton() {
    return AnimatedOpacity(
      opacity: isTutorial ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: const Alignment(0.9, -0.9),
        child: FractionallySizedBox(
          heightFactor: 0.15,
          widthFactor: 0.2,
          alignment: Alignment.centerRight,
          child: Image.asset(TutorialModeConst.enterTutorialModeButton),
        ),
      ),
    );
  }

  IgnorePointer tutorialDoctor() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isTutorial ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: tutorialProgress < 2
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          child: FractionallySizedBox(
            heightFactor: 0.45,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(TutorialModeConst.doctors),
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IgnorePointer chatBubble() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isTutorial ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: tutorialProgress < 2
              ? const Alignment(1, -0.9)
              : const Alignment(-1, -0.9),
          child: FractionallySizedBox(
            heightFactor: 0.65,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(TutorialModeConst.chatBubble),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: FractionallySizedBox(
                    heightFactor: 0.4,
                    widthFactor: 0.6,
                    child: Align(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        tutorialMessage[tutorialProgress],
                        maxLines: 4,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 100,
                          fontFamily: 'GSR_R',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedOpacity getContinueButton({required Function callback}) {
    return AnimatedOpacity(
      opacity: isTutorial ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: tutorialProgress < 2
            ? const Alignment(0.5, 0.9)
            : const Alignment(-0.5, 0.9),
        child: FractionallySizedBox(
          widthFactor: 0.15,
          child: ButtonWithText(text: '點我繼續', onTapFunction: callback),
        ),
      ),
    );
  }

  Align hintArrow() {
    return Align(
      alignment: arrowAlignment[tutorialProgress - 1],
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: Image.asset(arrowPath[tutorialProgress - 1]),
      ),
    );
  }
}
