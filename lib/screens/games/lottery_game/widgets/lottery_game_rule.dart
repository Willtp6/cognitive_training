import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/shared/progress_bar.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../lottery_game.dart';
import '../lottery_game_tutorial.dart';

class RuleScreen extends StatefulWidget {
  const RuleScreen({
    super.key,
    required this.game,
    required this.audioController,
    required this.lotteryGameTutorial,
    required this.callback,
  });

  final LotteryGame game;
  final AudioController audioController;
  final LotteryGameTutorial lotteryGameTutorial;
  final Function() callback;

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  List<Alignment> starPosition = [
    const Alignment(-1.0, -0.6),
    const Alignment(-0.5, -0.85),
    const Alignment(0.0, -1.0),
    const Alignment(0.5, -0.85),
    const Alignment(1.0, -0.6),
  ];

  List<AutoSizeText> rules = [
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請把出現的', style: TextStyle(color: Colors.black)),
          TextSpan(text: '所有數字', style: TextStyle(color: Colors.red)),
          TextSpan(text: '記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請把「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '聽到', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」的所有數字記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '按照出現順序', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」把所有數字記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有數字由「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '小到大排列', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  List<AutoSizeText> specialRules = [
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '雙數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '最大的兩個數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '最小的兩個數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    const AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請將所有的「', style: TextStyle(color: Colors.black)),
          TextSpan(text: '單數', style: TextStyle(color: Colors.red)),
          TextSpan(text: '」記下來！', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 1,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  List<String> difficulties = ['一', '二', '三', '四', '五'];

  late StreamSubscription<PlayerState> listener;
  bool isAudioOver = false;

  @override
  void initState() {
    listener = widget.audioController.instructionPlayer.onPlayerStateChanged
        .listen((event) {
      switch (event) {
        case PlayerState.playing:
          if (isAudioOver = true) {
            setState(() => isAudioOver = false);
          }
          break;
        case PlayerState.completed:
          setState(() => isAudioOver = true);
          break;
        default:
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: IgnorePointer(
          ignoring: widget.game.gameProgress != 0,
          child: AnimatedOpacity(
            opacity: widget.game.gameProgress == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.purple
                        .withOpacity(widget.game.isTutorial ? 0.3 : 1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    //difficultyStars(),
                    for (int i = 0; i < 5; i++) ...[
                      Opacity(
                        opacity: widget.game.isTutorial &&
                                ((widget.lotteryGameTutorial.tutorialProgress !=
                                            2 &&
                                        i == 0) ||
                                    i != 0)
                            ? 0.3
                            : 1,
                        child: Align(
                          alignment: starPosition[i],
                          child: FractionallySizedBox(
                            widthFactor: 0.2,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(i <= widget.game.gameLevel
                                  ? Globals.starLight
                                  : Globals.starDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                    difficultyLabel(),
                    Opacity(
                      opacity: widget.game.isTutorial ? 0.3 : 1,
                      child: Align(
                        alignment: const Alignment(0.0, 0.1),
                        child: FractionallySizedBox(
                          widthFactor: 0.7,
                          heightFactor: 0.2,
                          child: widget.game.numberOfDigits ==
                                  widget.game
                                      .maxNumberLength[widget.game.gameLevel]
                              ? ProgressBar(
                                  maxProgress: 5,
                                  continuousWin: widget.game.continuousWin,
                                )
                              : ProgressBar(
                                  maxProgress: 2,
                                  continuousWin: widget
                                      .game.continuousCorrectRateBiggerThan50),
                        ),
                      ),
                    ),
                    gameRule(),
                    Opacity(
                      opacity: widget.game.isTutorial ? 0.3 : 1,
                      child: Align(
                        alignment: const Alignment(0.0, 0.9),
                        child: FractionallySizedBox(
                          heightFactor: 0.15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Center(
                                  child: ButtonWithText(
                                    text: '再聽一次',
                                    onTapFunction: listenAgain,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Center(
                                  child: ButtonWithText(
                                    text: isAudioOver ? '開始' : '跳過並開始',
                                    onTapFunction: startGame,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Opacity gameRule() {
    return Opacity(
      opacity: widget.game.isTutorial &&
              widget.lotteryGameTutorial.tutorialProgress != 1
          ? 0.3
          : 1,
      child: Align(
        alignment: const Alignment(0.0, 0.5),
        child: FractionallySizedBox(
          heightFactor: 0.25,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Center(
              child: widget.game.gameLevel < 4
                  ? rules[widget.game.gameLevel]
                  : specialRules[widget.game.specialRules],
            ),
          ),
        ),
      ),
    );
  }

  Align difficultyLabel() {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: FractionallySizedBox(
        heightFactor: 0.15,
        widthFactor: 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Opacity(
                opacity: widget.game.isTutorial &&
                        widget.lotteryGameTutorial.tutorialProgress != 2
                    ? 0.3
                    : 1,
                child: AutoSizeText(
                  '難度${difficulties[widget.game.gameLevel]} ',
                  style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
                  maxFontSize: 100,
                  minFontSize: 5,
                  stepGranularity: 5,
                  maxLines: 1,
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Opacity(
                opacity: widget.game.isTutorial &&
                        (widget.lotteryGameTutorial.tutorialProgress != 3 &&
                            widget.lotteryGameTutorial.tutorialProgress != 4)
                    ? 0.3
                    : 1,
                child: AutoSizeText(
                  '號碼數量${widget.game.numberOfDigits}',
                  style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
                  maxFontSize: 100,
                  minFontSize: 5,
                  stepGranularity: 5,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startGame() async {
    if (!widget.game.isTutorial) {
      widget.audioController.stopPlayingInstruction();
      widget.callback();
      widget.audioController.playSfx(Globals.clickButtonSound);
    }
  }

  void listenAgain() async {
    if (!widget.game.isTutorial) {
      widget.audioController.playSfx(Globals.clickButtonSound);

      Future.delayed(const Duration(milliseconds: 200), () {
        final path = widget.game.getInstructionAudioPath();
        Logger().d(path);
        if (path != null) {
          widget.audioController.playInstructionRecord(path);
          setState(() => isAudioOver = false);
        }
      });
    }
  }
}
