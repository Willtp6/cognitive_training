import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/progress_bar.dart';
import '../poker_game_instance.dart';
import '../poker_game_tutorial.dart';

class RuleScreen extends StatefulWidget {
  const RuleScreen({
    super.key,
    required this.game,
    required this.audioController,
    required this.pokerGameTutorial,
    required this.callback,
  });

  final GameInstance game;
  final AudioController audioController;
  final PokerGameTutorial pokerGameTutorial;
  final Function() callback;

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  List<Alignment> starPosition = [
    const Alignment(-0.9, -0.5),
    const Alignment(-0.3, -0.5),
    const Alignment(0.3, -0.5),
    const Alignment(0.9, -0.5),
  ];

  late SettingsController _settings;
  bool isAudioOver = false;
  late StreamSubscription<PlayerState> listener;

  @override
  void initState() {
    if (!widget.game.isTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final path = widget.game.gameLevel <= 1
            ? PokerGameConst.gameRuleFindBiggerAudio
            : PokerGameConst.gameRuleFindTheSameAudio;
        widget.audioController.playInstructionRecord(path);
      });
    }
    listener = widget.audioController.instructionPlayer.onPlayerStateChanged
        .listen((event) {
      switch (event) {
        case PlayerState.playing:
          break;
        case PlayerState.completed:
          List<String> status = _settings.ruleListenedPokerGame.value;
          if (status[widget.game.gameLevel] == 'false') {
            setState(() {
              status[widget.game.gameLevel] = 'true';
              _settings.setRuleListenedPokerGame(status);
            });
          }
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

  bool questionIconPressed = false;

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<SettingsController>();
    return Align(
      child: IgnorePointer(
        ignoring: widget.game.cardDealed,
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: AnimatedOpacity(
            opacity: widget.game.cardDealed ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.blue
                        .withOpacity(widget.game.isTutorial ? 0.5 : 1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              widget.pokerGameTutorial.tutorialProgress != 2
                          ? 0.3
                          : 1,
                      child: difficultyStars(),
                    ),
                    if (widget.game.gameLevel <= 1) ...[
                      Opacity(
                        opacity: widget.game.isTutorial ? 0.3 : 1,
                        child: sizeDescriptionButton(),
                      ),
                    ],
                    Opacity(
                      opacity: widget.game.isTutorial ? 0.3 : 1,
                      child: Align(
                        alignment: const Alignment(0.0, -0.35),
                        child: FractionallySizedBox(
                          widthFactor: 0.7,
                          heightFactor: 0.2,
                          child: ProgressBar(
                            maxProgress: 5,
                            continuousWin: widget.game.continuousWin,
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: widget.game.isTutorial &&
                              (widget.pokerGameTutorial.tutorialProgress != 0 &&
                                  widget.pokerGameTutorial.tutorialProgress !=
                                      1)
                          ? 0.3
                          : 1,
                      child: ruleText(),
                    ),
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
                                      text: '再聽一次', onTapFunction: listenAgain),
                                ),
                              ),
                              Flexible(
                                child: Center(
                                  child: widget.game.isTutorial ||
                                          _settings.ruleListenedPokerGame.value[
                                                  widget.game.gameLevel] ==
                                              'true'
                                      ? ButtonWithText(
                                          text: '開始遊戲',
                                          onTapFunction: startGame,
                                        )
                                      : const SizedBox.expand(),
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

  Align difficultyStars() {
    return Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: Stack(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Align(
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
            ],
          ],
        ),
      ),
    );
  }

  void startGame() {
    if (!widget.game.isTutorial) {
      widget.audioController.stopPlayingInstruction();
      widget.callback();
    }
  }

  void listenAgain() {
    if (!widget.game.isTutorial) {
      final path = widget.game.gameLevel <= 1
          ? PokerGameConst.gameRuleFindBiggerAudio
          : PokerGameConst.gameRuleFindTheSameAudio;
      widget.audioController.playInstructionRecord(path);
    }
  }

  Align sizeDescriptionButton() {
    return Align(
      alignment: const Alignment(0.9, -0.3),
      child: FractionallySizedBox(
        widthFactor: 0.1,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => questionIconPressed = true);
          },
          onTapUp: (_) {
            setState(() => questionIconPressed = false);
          },
          onPanEnd: (_) {
            setState(() => questionIconPressed = false);
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              questionIconPressed
                  ? PokerGameConst.questionDark
                  : PokerGameConst.questionLight,
            ),
          ),
        ),
      ),
    );
  }

  Align ruleText() {
    return Align(
      alignment: const Alignment(0.0, 0.35),
      child: FractionallySizedBox(
        heightFactor: 0.4,
        widthFactor: 0.9,
        child: questionIconPressed ||
                (widget.game.isTutorial &&
                    widget.pokerGameTutorial.tutorialProgress == 1)
            ? Center(
                child: FractionallySizedBox(
                  heightFactor: 0.7,
                  widthFactor: 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.green, width: 3),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: const Center(child: PokerGameConst.getSizeRule),
                  ),
                ),
              )
            : Center(
                child: widget.game.gameLevel <= 1
                    ? PokerGameConst.getBigger
                    : PokerGameConst.getSameRankOrSuit,
              ),
      ),
    );
  }
}
