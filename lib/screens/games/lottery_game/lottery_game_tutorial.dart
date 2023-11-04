import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/tutorial_mode_const.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class LotteryGameTutorial {
  bool isTutorial = false;
  int tutorialProgress = 0;

  List<AutoSizeText> tutorialMessage = [
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '哈囉! 我是小幫', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '手! 接下來我會', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '教你怎麼玩這個', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '遊戲!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '畫面中央會出現', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '指導與說明，請', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '按照這關的指示', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '完成遊戲!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '難度與星星數量', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '代表這關的困難', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '程度', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '號碼數量則代表，', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '遊戲中需要記憶的', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '號碼數量', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '因此號碼數量越', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '多，遊戲也就越', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '有挑戰性!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '最後按下「開', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '始」，就可以進', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '入遊戲囉!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '遊戲開始後，中', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '央的神明將會告', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '知一系列號碼', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將看到或聽到', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '的數字記憶下來', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '，並於彩券上劃', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '記!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '接著按照遊戲指', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '示，在彩券上點', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '選記憶中的號碼', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '畫記完畢後，案', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '下「填好了」，', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '就可以開獎囉!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  IgnorePointer tutorialDoctor() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isTutorial ? 1 : 1,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: tutorialProgress < 6
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
        opacity: isTutorial ? 1 : 1,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: tutorialProgress < 6
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
                      child: tutorialMessage[tutorialProgress],
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

  final List<Alignment> _dottedLineContainerAlignment = [
    const Alignment(0.0, 0.0),
    const Alignment(0.0, 0.45),
    const Alignment(-0.625, -0.55),
    const Alignment(0.15, -0.2),
    const Alignment(0.15, -0.2),
    const Alignment(0.4, 0.85),
    const Alignment(0, 0),
    const Alignment(0.4, 0.825),
    const Alignment(0.35, 0.75),
    const Alignment(0, 0),
  ];
  final List<double?> _dottedLineContainerWFactor = [
    0,
    0.55,
    0.7 * 0.2,
    0.7 * 0.5 * 5 / 8,
    0.7 * 0.5 * 5 / 8,
    null,
    0,
    0,
    5 / 7 * 7 / 9 * 4 / 7,
    0,
  ];
  final List<double?> _dottedLineContainerHFactor = [
    0,
    0.25,
    null,
    0.15,
    0.15,
    0.15,
    0,
    0,
    20 / 28 * 4 / 7,
    0,
  ];
  final List<double> _dottedLineContainerASRatio = [
    1,
    1,
    1,
    1,
    1,
    835 / 353,
    1,
    1,
    1,
    1,
  ];

  Align dottedLineContainer() {
    return Align(
      alignment: _dottedLineContainerAlignment[tutorialProgress],
      child: FractionallySizedBox(
        widthFactor: _dottedLineContainerWFactor[tutorialProgress],
        heightFactor: _dottedLineContainerHFactor[tutorialProgress],
        child: AspectRatio(
          aspectRatio: _dottedLineContainerASRatio[tutorialProgress],
          child: DottedBorder(
            color: Colors.red,
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            strokeWidth: 2,
            dashPattern: const [8, 4],
            padding: const EdgeInsets.all(10),
            strokeCap: StrokeCap.round,
            child: Container(),
          ),
        ),
      ),
    );
  }

  Align extraDottedLineContainer() {
    return Align(
      alignment: const Alignment(-0.25, -0.2),
      child: FractionallySizedBox(
        widthFactor: 0.5 * 3 / 8,
        heightFactor: 0.15,
        child: AspectRatio(
          aspectRatio: _dottedLineContainerASRatio[tutorialProgress],
          child: DottedBorder(
            color: Colors.red,
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            strokeWidth: 2,
            dashPattern: const [8, 4],
            padding: const EdgeInsets.all(10),
            strokeCap: StrokeCap.round,
            child: Container(),
          ),
        ),
      ),
    );
  }

  final List<Alignment> _hintArrowAlignment = [
    const Alignment(3, 3),
    const Alignment(-0.75, 0.4),
    const Alignment(-0.6, 0.4),
    const Alignment(-0.25, -0.2),
    const Alignment(-0.25, -0.2),
    const Alignment(0.0, 0.95),
    const Alignment(0.5, 0.0),
    const Alignment(0.5, 0.0),
    const Alignment(0.8, 0.65),
    const Alignment(0.65, 0.0),
  ];

  List<String> arrowDirection = [
    'right',
    'right',
    'up',
    'right',
    'right',
    'right',
    'left',
    'left',
    'left',
    'right',
  ];

  Map<String, String> arrowImagePath = {
    'up': TutorialModeConst.upArrow,
    'down': TutorialModeConst.downArrow,
    'left': TutorialModeConst.leftArrow,
    'right': TutorialModeConst.rightArrow,
  };

  Align hintArrow() {
    return Align(
      alignment: _hintArrowAlignment[tutorialProgress],
      child: IgnorePointer(
        child: FractionallySizedBox(
          // widthFactor: 0.1,
          heightFactor: 0.2,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              arrowImagePath[arrowDirection[tutorialProgress]]!,
            ),
          ),
        ),
      ),
    );
  }

  Align extraHintArrow() {
    return Align(
      alignment: const Alignment(-0.25, -0.8),
      child: FractionallySizedBox(
        //widthFactor: 0.1,
        heightFactor: 0.2,
        child: AspectRatio(
            aspectRatio: 1, child: Image.asset(TutorialModeConst.downArrow)),
      ),
    );
  }

  final List<Alignment> _continueButtonAlignment = [
    const Alignment(0.9, 0.9),
    const Alignment(0.9, 0.9),
    const Alignment(0.9, 0.9),
    const Alignment(0.9, 0.9),
    const Alignment(0.9, 0.9),
    const Alignment(0.9, 0.9),
    const Alignment(-0.9, 0.9),
    const Alignment(-0.9, 0.9),
    const Alignment(-0.9, 0.9),
    const Alignment(-0.9, 0.9),
  ];

  AnimatedOpacity getContinueButton(Function callback) {
    return AnimatedOpacity(
      opacity: isTutorial ? 1 : 1,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: _continueButtonAlignment[tutorialProgress],
        child: FractionallySizedBox(
          widthFactor: 0.15,
          child: ButtonWithText(
              text: tutorialProgress < 9 ? '點我繼續' : '結束教學',
              onTapFunction: () {
                tutorialProgress++;
                callback();
              }),
        ),
      ),
    );
  }
}
