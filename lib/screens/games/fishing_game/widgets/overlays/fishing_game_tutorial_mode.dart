import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/tutorial_mode_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/fishing_game/fishing_game.dart';
import 'package:cognitive_training/screens/games/fishing_game/widgets/overlays/fishing_game_rule.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/rod_component.dart';

class FishingGameTutorialMode extends StatefulWidget {
  static const id = 'FishingGameTutorialMode';
  const FishingGameTutorialMode({super.key, required this.game});

  final FishingGame game;

  @override
  State<FishingGameTutorialMode> createState() =>
      _FishingGameTutorialModeState();
}

class _FishingGameTutorialModeState extends State<FishingGameTutorialMode> {
  int tutorialProgress = 0;
  bool buttonEnabled = true;
  late RectangleComponent background;

  late DatabaseInfoProvider databaseInfoProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      background = RectangleComponent(
        position: widget.game.size / 2,
        size: widget.game.size,
        anchor: Anchor.center,
        paint: BasicPalette.gray.withAlpha(100).paint(),
        priority: 1,
      );
      widget.game.add(background);
    });
    super.initState();
  }

  void tutorialProgressOne() {
    widget.game.rodComponents = List.generate(
      4,
      (index) => RodComponent(
        rodId: index,
        scaleLevel: 3,
      )..add(OpacityEffect.to(1, EffectController(duration: 0.5))),
    );
    widget.game.addAll(widget.game.rodComponents);
  }

  void tutorialProgressTwo() {
    widget.game.rodComponents[0].priority = 2;
    widget.game.rodComponents[0].controller.isActive = true;
    Future.delayed(
        const Duration(milliseconds: 1000),
        () => setState(() {
              buttonEnabled = true;
              widget.game.rodComponents[0].controller.isActive = false;
            }));
  }

  void toNextProgress() async {
    if (tutorialProgress < 6) {
      FlameAudio.play('shared/click_button.wav');
      setState(() {
        tutorialProgress++;
        switch (tutorialProgress) {
          case 1:
            tutorialProgressOne();
            break;
          case 2:
            buttonEnabled = false;
            tutorialProgressTwo();
            break;
          case 3:
            widget.game.rodComponents[0].removeRipple();
            break;
          case 5:
            widget.game.rodComponents[0].setImageToLight();
            break;
          default:
            break;
        }
      });
    } else {
      databaseInfoProvider.fishingGameDoneTutorial();
      await showEndTutorialDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    databaseInfoProvider = context.read<DatabaseInfoProvider>();
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0),
          ),
          child: Stack(
            children: [
              Align(
                alignment: const Alignment(0.5, 0.95),
                child: FractionallySizedBox(
                  heightFactor: 0.15,
                  child: ButtonWithText(
                    text: tutorialProgress < 6 ? '點我繼續' : '結束教學',
                    onTapFunction: buttonEnabled ? toNextProgress : () {},
                  ),
                ),
              ),
              ChatBubble(tutorialProgress: tutorialProgress),
              const TutorialDoctor(),
              if (tutorialProgress == 6) ...[
                Align(
                  alignment: const Alignment(0.0, -0.2),
                  child: Opacity(
                    opacity: 0.3,
                    child: FractionallySizedBox(
                      heightFactor: 0.15,
                      child: ButtonWithText(text: '確定', onTapFunction: () {}),
                    ),
                  ),
                ),
              ],
              DottedContainer(tutorialProgress: tutorialProgress),
              HintArrow(tutorialProgress: tutorialProgress),
            ],
          ),
        ),
      ),
    );
  }

  Future showEndTutorialDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '教學結束',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    '直接開始遊戲嗎?',
                    style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '離開遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                // context.pop(true);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                // context.pop(false);
                Navigator.of(context).pop(false);
                background.removeFromParent();
                widget.game.removeAll(widget.game.rodComponents);
                widget.game.overlays.remove(FishingGameTutorialMode.id);
                widget.game.overlays.add(FishingGameRule.id);
              },
            ),
          ],
        );
      },
    );
  }
}

class TutorialDoctor extends StatelessWidget {
  const TutorialDoctor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FractionallySizedBox(
        heightFactor: 0.3,
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
    );
  }
}

class ChatBubble extends StatelessWidget {
  final int tutorialProgress;
  const ChatBubble({super.key, required this.tutorialProgress});
  static const List<AutoSizeText> tutorialMessage = [
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '哈囉！我是小幫\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '手！接下來我會\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '教你怎麼玩這個\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '遊戲！'),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '首先，你需要觀\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '察水面漣漪的大\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '小，來判斷水底\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '下魚的大小！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '開始遊戲後，每\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '隻釣竿下會浮出\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '不同大小的漣漪', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '漣漪只會閃爍一\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '陣子，然後就消\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '失，請記得要注\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '意看！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '根據你的觀察，\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '選擇漣漪最大的\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '釣竿，把魚釣起！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '當釣竿亮起表示\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '你已選定，', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '再按下「確定」，\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '就可以看自己釣到\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '哪隻大魚囉！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(1, -0.3),
        child: FractionallySizedBox(
          heightFactor: 0.65,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    TutorialModeConst.chatBubble,
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
    );
  }
}

class DottedContainer extends StatelessWidget {
  final int tutorialProgress;

  const DottedContainer({super.key, required this.tutorialProgress});
  static const dottedLineContaierAlignment = [
    Alignment.center,
    Alignment.center,
    Alignment(-0.2, 0.65),
    Alignment(-0.2, 0.65),
    Alignment.center,
    Alignment.center,
    Alignment(0.0, -0.2),
  ];

  static List<double?> dottedLineContainerWFactor = [
    null,
    null,
    0.1 * pow(1.2, 3),
    0.1 * pow(1.2, 3),
    null,
    null,
    null,
  ];
  static const List<double?> dottedLineContainerHFactor = [
    null,
    null,
    null,
    null,
    null,
    null,
    0.175,
  ];
  static const List<double> dottedLineContainerASRatio = [
    1,
    1,
    2,
    2,
    1,
    1,
    835 / 353,
  ];
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: dottedLineContaierAlignment[tutorialProgress],
      child: tutorialProgress == 2 ||
              tutorialProgress == 3 ||
              tutorialProgress == 6
          ? FractionallySizedBox(
              widthFactor: dottedLineContainerWFactor[tutorialProgress],
              heightFactor: dottedLineContainerHFactor[tutorialProgress],
              child: AspectRatio(
                aspectRatio: dottedLineContainerASRatio[tutorialProgress],
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
            )
          : Container(),
    );
  }
}

class HintArrow extends StatelessWidget {
  final int tutorialProgress;
  const HintArrow({super.key, required this.tutorialProgress});

  static const List<Alignment> hintArrowAlignment = [
    Alignment.center,
    Alignment.center,
    Alignment(-0.175, 0.2),
    Alignment(-0.175, 0.2),
    Alignment.center,
    Alignment(-0.05, 0.1),
    Alignment(0.0, 0.225),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: hintArrowAlignment[tutorialProgress],
      child: FractionallySizedBox(
        heightFactor: 0.15,
        child: AspectRatio(
          aspectRatio: 1,
          child: tutorialProgress == 2 || tutorialProgress == 3
              ? Image.asset(TutorialModeConst.downArrow)
              : tutorialProgress == 5
                  ? Image.asset(TutorialModeConst.leftArrow)
                  : tutorialProgress == 6
                      ? Image.asset(TutorialModeConst.upArrow)
                      : Container(),
        ),
      ),
    );
  }
}
