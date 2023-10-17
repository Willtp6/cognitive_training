import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PokerGameTutorial {
  bool isTutorial = false;
  int tutorialProgress = 0;

  List<AutoSizeText> tutorialMessage = [
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
          TextSpan(text: '點選右上方的問', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '號後，可以得到', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '比大小遊戲更詳', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '細的說明', style: TextStyle(color: Colors.black)),
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
          TextSpan(text: '星星數量代表這', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '關的困難程度', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '按下「開始」，', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '就可以進入遊戲', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '囉!', style: TextStyle(color: Colors.black)),
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
          TextSpan(text: '進入遊戲後，電', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '腦爺爺會從他的', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '牌中打出一張牌', style: TextStyle(color: Colors.black)),
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
          TextSpan(text: '接著，請從自己', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '的牌中選出適合', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '的牌打出去，並', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '贏得遊戲!', style: TextStyle(color: Colors.black)),
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
          TextSpan(text: '旁邊的小鬧鈴是', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '在提醒你要在時', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '限內選出牌', style: TextStyle(color: Colors.black)),
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
          TextSpan(text: '選出正確的牌，', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '就可以贏得遊戲', style: TextStyle(color: Colors.black)),
          TextSpan(text: '\n'),
          TextSpan(text: '了! 加油吧!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  static const List<Alignment> doctorAlignment = [
    Alignment.bottomRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.bottomRight,
    Alignment.bottomRight,
    Alignment.bottomRight,
    Alignment.bottomLeft,
    Alignment.bottomLeft,
  ];

  IgnorePointer tutorialDoctor() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isTutorial ? 1 : 1,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: doctorAlignment[tutorialProgress],
          child: FractionallySizedBox(
            heightFactor: 0.45,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/login_page/tutorial_doctors.png',
                    ),
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

  static const List<Alignment> bubbleAlignment = [
    Alignment(1, -0.9),
    Alignment(-1, -0.9),
    Alignment(1, -0.9),
    Alignment(1, -0.9),
    Alignment(1, -0.9),
    Alignment(1, -0.9),
    Alignment(-1, -0.9),
    Alignment(-1, -0.9),
  ];

  IgnorePointer chatBubble() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isTutorial ? 1 : 1,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: bubbleAlignment[tutorialProgress],
          child: FractionallySizedBox(
            heightFactor: 0.65,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/login_page/tutorial_chat_bubble.png',
                    ),
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
    const Alignment(0.0, 0.15),
    const Alignment(0.0, 0.15),
    const Alignment(0.0, -0.85),
    const Alignment(0.4, 0.825),
    const Alignment(0.0, -0.2),
    const Alignment(0.0, 0.85),
    const Alignment(0.85, -0.25),
  ];
  final List<double?> _dottedLineContainerWFactor = [
    0.65,
    0.65,
    0.6,
    null,
    null,
    null,
    null,
  ];
  final List<double> _dottedLineContainerHFactor = [
    0.4,
    0.4,
    0.25,
    0.15,
    0.25,
    0.28,
    0.3,
  ];
  final List<double> _dottedLineContainerASRatio = [
    1,
    1,
    1,
    835 / 353,
    970 / 254,
    2750 / 641,
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

  final List<Alignment> _hintArrowAlignment = [
    const Alignment(-0.95, 0.15),
    const Alignment(-0.95, 0.15),
    const Alignment(-0.9, -0.85),
    const Alignment(0.0, 0.9),
    const Alignment(-0.8, -0.2),
    const Alignment(-0.9, 0.85),
    const Alignment(0.45, -0.2),
  ];

  Align hintArrow() {
    return Align(
      alignment: _hintArrowAlignment[tutorialProgress],
      child: FractionallySizedBox(
        widthFactor: 0.1,
        child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/global/tutorial_right_arrow.png')),
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
            text: tutorialProgress < 6 ? '點我繼續' : '結束教學',
            onTapFunction: () {
              tutorialProgress++;
              callback();
            },
          ),
        ),
      ),
    );
  }
}
