import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/fishing_game_const.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/progress_bar.dart';
import 'top_coins.dart';
import '../../fishing_game.dart';

class FishingGameRule extends StatefulWidget {
  static const String id = "FishingGameRule";
  const FishingGameRule({
    super.key,
    required this.game,
    //required this.audioController,
    //required this.lotteryGameTutorial,
    //required this.callback,
  });

  final FishingGame game;
  //final AudioController audioController;
  // final Function() callback;

  @override
  State<FishingGameRule> createState() => _FishingGameRuleState();
}

class _FishingGameRuleState extends State<FishingGameRule>
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioController.playInstructionRecord(FishingGameConst.gameRule);
    });
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
    return FadeTransition(
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
                  const GameRule(),
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
    );
  }

  void _listenAgain() {
    _audioController.playInstructionRecord(FishingGameConst.gameRule);
  }

  void _startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _audioController.playSfx(Globals.clickButtonSound);

      _controller.forward().whenComplete(() {
        widget.game.overlays.remove(FishingGameRule.id);
        widget.game.overlays.add(TopCoins.id);
        widget.game.startGame();
        buttonEnabled = false;
      });
    }
  }
}

class GameRule extends StatelessWidget {
  const GameRule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0.0, 0.4),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Center(
            child: FishingGameConst.fishingGameRule,
          ),
        ),
      ),
    );
  }
}
