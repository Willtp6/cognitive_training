import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/progress_bar.dart';
import '../../route_planning_game_forge2d.dart';

class RoutePlanningGameRule extends StatefulWidget {
  static const String id = "RoutePlanningGameRule";
  const RoutePlanningGameRule({
    super.key,
    required this.game,
    required this.audioController,
  });

  final RoutePlanningGameForge2d game;
  final AudioController audioController;

  @override
  State<RoutePlanningGameRule> createState() => _RoutePlanningGameRuleState();
}

class _RoutePlanningGameRuleState extends State<RoutePlanningGameRule>
    with SingleTickerProviderStateMixin {
  List<Alignment> starPosition = [
    const Alignment(-1.0, -0.6),
    const Alignment(-0.5, -0.85),
    const Alignment(0.0, -1.0),
    const Alignment(0.5, -0.85),
    const Alignment(1.0, -0.6),
  ];

  late AnimationController _controller;
  late SettingsController _settings;
  late StreamSubscription<PlayerState> listener;
  bool buttonEnabled = true;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playRuleAudio();
    });
    listener = widget.audioController.instructionPlayer.onPlayerStateChanged
        .listen((event) {
      switch (event) {
        case PlayerState.playing:
          break;
        case PlayerState.completed:
          List<String> status = _settings.ruleListenedRoutePlanningGame.value;
          if (status[widget.game.gameLevel] == 'false') {
            setState(() {
              status[widget.game.gameLevel] = 'true';
              _settings.setRuleListenedRoutePlanningGame(status);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<SettingsController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
      ),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(_controller),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.blue.withOpacity(1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    for (int i = 0; i < 5; i++) ...[
                      Align(
                        alignment: starPosition[i],
                        child: FractionallySizedBox(
                          widthFactor: 0.2,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              i <= widget.game.gameLevel
                                  ? Globals.starLight
                                  : Globals.starDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                    Align(
                      alignment: const Alignment(0.0, -0.1),
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        heightFactor: 0.2,
                        child: ProgressBar(
                          maxProgress: 5,
                          continuousWin: widget.game.continuousWin,
                        ),
                      ),
                    ),
                    GameRule(
                      gameLevel: widget.game.gameLevel,
                    ),
                    Align(
                      alignment: const Alignment(0.0, 0.9),
                      child: FractionallySizedBox(
                        heightFactor: 0.15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Center(
                                child: ButtonWithText(
                                    text: '再聽一次', onTapFunction: _listenAgain),
                              ),
                            ),
                            Flexible(
                              child: Center(
                                child: _settings.ruleListenedRoutePlanningGame
                                            .value[widget.game.gameLevel] ==
                                        'true'
                                    ? ButtonWithText(
                                        text: '開始遊戲',
                                        onTapFunction: _startGame,
                                      )
                                    : const SizedBox.expand(),
                              ),
                            ),
                          ],
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

  void playRuleAudio() {
    final Map<String, String> path;
    switch (widget.game.gameLevel) {
      case 0:
        path = RoutePlanningGameConst.gameRuleLevel1;
        break;
      case 1:
        path = RoutePlanningGameConst.gameRuleLevel2;
        break;
      default:
        path = RoutePlanningGameConst.gameRuleLevel3to5;
        break;
    }
    widget.audioController.playInstructionRecord(path);
  }

  void _listenAgain() {
    playRuleAudio();
  }

  void _startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      widget.audioController.playSfx(Globals.clickButtonSound);
      widget.audioController.stopPlayingInstruction();
      _controller.forward().whenComplete(() {
        widget.game.overlays.remove(RoutePlanningGameRule.id);
        widget.game.startGame();
        buttonEnabled = false;
      });
    }
  }
}

class GameRule extends StatelessWidget {
  final int gameLevel;
  const GameRule({super.key, required this.gameLevel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, 0.4),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Center(
            child: gameLevel == 0
                ? RoutePlanningGameConst.level1RuleText
                : gameLevel == 2
                    ? RoutePlanningGameConst.level2RuleText
                    : RoutePlanningGameConst.level3to5RuleText,
          ),
        ),
      ),
    );
  }
}
