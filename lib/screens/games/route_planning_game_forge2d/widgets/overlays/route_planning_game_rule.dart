import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../route_planning_game_forge2d.dart';

class RoutePlanningGameRule extends StatefulWidget {
  static const String id = "RoutePlanningGameRule";
  const RoutePlanningGameRule({
    super.key,
    required this.game,
    //required this.audioController,
    //required this.lotteryGameTutorial,
    //required this.callback,
  });

  final RoutePlanningGameForge2d game;
  //final AudioController audioController;
  // final Function() callback;

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
  late AudioController _audioController;
  bool buttonEnabled = true;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _audioController = context.read<AudioController>();
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
                                child: ButtonWithText(
                                    text: '開始遊戲', onTapFunction: _startGame),
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

  void _listenAgain() {}

  void _startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _audioController.playPathAudio(Globals.clickButtonSound);
      _controller.forward().whenComplete(() {
        widget.game.overlays.remove(RoutePlanningGameRule.id);
        // widget.game.overlays.remove(FishingGameRule.id);
        // widget.game.overlays.add(TopCoins.id);
        widget.game.startGame();
        buttonEnabled = false;
      });
    }
  }
}

class GameRule extends StatelessWidget {
  int gameLevel;
  GameRule({super.key, required this.gameLevel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, 0.3),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Center(
            child: AutoSizeText.rich(
              TextSpan(
                children: gameLevel == 0
                    ? const [
                        TextSpan(
                            text: '請前往目標地幫家人辦事',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: '\n', style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: '越快', style: TextStyle(color: Colors.red)),
                        TextSpan(
                            text: '完成越好喔!',
                            style: TextStyle(color: Colors.black)),
                      ]
                    : const [
                        TextSpan(
                            text: '請在', style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: '時限內', style: TextStyle(color: Colors.red)),
                        TextSpan(
                            text: '前往目標地幫家人辦事\n',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: '越快完成越好喔!',
                            style: TextStyle(color: Colors.black)),
                      ],
              ),
              softWrap: true,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
            ),
          ),
        ),
      ),
    );
  }
}
