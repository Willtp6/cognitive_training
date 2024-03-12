import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/fishing_game_const.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/shared/game_label.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/button_with_text.dart';

class FishingGameMenu extends StatefulWidget {
  const FishingGameMenu({super.key});

  @override
  State<FishingGameMenu> createState() => _FishingGameMenuState();
}

class _FishingGameMenuState extends State<FishingGameMenu>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late DatabaseInfoProvider databaseInfoProvider;
  late AudioController _audioController;
  bool buttonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _controller.forward().whenComplete(() {
        final db = databaseInfoProvider.fishingGameDatabase;
        context.pushNamed(
          'fishing_game',
          queryParams: {'enterTutorialMode': (!db.doneTutorial).toString()},
        );
      }).whenComplete(() {
        _controller.reset();
        buttonEnabled = true;
      });
      _audioController.playSfx(Globals.clickButtonSound);
    }
  }

  void startTutorial() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _controller.forward().whenComplete(() {
        context.pushNamed(
          'fishing_game',
          queryParams: {'enterTutorialMode': 'true'},
        );
      }).whenComplete(() {
        _controller.reset();
        buttonEnabled = true;
      });
      _audioController.playSfx(Globals.clickButtonSound);
    }
  }

  void goBack() {
    if (buttonEnabled) {
      _audioController.playSfx(Globals.clickButtonSound);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _audioController = context.read<AudioController>();
    databaseInfoProvider = context.read<DatabaseInfoProvider>();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.0)
                  .chain(CurveTween(curve: const Interval(0.0, 1.0)))
                  .animate(_controller),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(FishingGameConst.fishingGameMenu),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(_controller),
              child: Stack(
                children: [
                  const GameLabel(labelText: '釣 魚'),
                  Align(
                    alignment: const Alignment(0.0, 0.9),
                    child: FractionallySizedBox(
                      heightFactor: 0.45,
                      widthFactor: 0.3,
                      child: Column(
                        children: [
                          Flexible(
                            child: ButtonWithText(
                                text: '進入遊戲', onTapFunction: startGame),
                          ),
                          Flexible(
                            child: ButtonWithText(
                                text: '教學模式', onTapFunction: startTutorial),
                          ),
                          Flexible(
                            child: ButtonWithText(
                                text: '返回', onTapFunction: goBack),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
