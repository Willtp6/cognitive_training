import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/lottery_game_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:provider/provider.dart';

import '../shared/game_label.dart';

class LotteryGameMenu extends StatefulWidget {
  const LotteryGameMenu({super.key});

  @override
  State<LotteryGameMenu> createState() => _LotteryGameMenu();
}

class _LotteryGameMenu extends State<LotteryGameMenu>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late DatabaseInfoProvider databaseInfoProvider;
  late AudioController _audioController;
  bool buttonEnabled = true;
  PausableTimer? _timer;
  int passedTime = 0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    WidgetsBinding.instance.addObserver(this);
    _timer = PausableTimer.periodic(const Duration(seconds: 1), () {
      passedTime++;
    })
      ..start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _timer?.start();
        break;
      case AppLifecycleState.paused:
        _timer?.pause();
        break;
      case AppLifecycleState.inactive:
        _timer?.pause();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    databaseInfoProvider.updateMaxPlayTime(passedTime);
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _audioController.playSfx(Globals.clickButtonSound);
      _controller.forward().whenComplete(() {
        final doneTutorial =
            databaseInfoProvider.lotteryGameDatabase.doneTutorial;
        context.pushNamed('lottery_game',
            queryParams: {'enterTutorialMode': (!doneTutorial).toString()});
        buttonEnabled = true;
      }).whenComplete(() => _controller.reset());
    }
  }

  void startTutorial() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _audioController.playSfx(Globals.clickButtonSound);
      _controller.forward().whenComplete(() {
        context.pushNamed('lottery_game',
            queryParams: {'enterTutorialMode': 'true'});
        buttonEnabled = true;
      }).whenComplete(() => _controller.reset());
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
    databaseInfoProvider = context.read<DatabaseInfoProvider>();
    _audioController = context.read<AudioController>();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.5)
                  .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                  .animate(_controller),
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.6)
                    .chain(CurveTween(curve: const Interval(0.0, 0.7)))
                    .animate(_controller),
                child: SlideTransition(
                  position: Tween(
                          begin: const Offset(0, 0),
                          end: const Offset(-0.13, 0.11))
                      .chain(CurveTween(curve: const Interval(0.0, 0.7)))
                      .animate(_controller),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(LotteryGameConst.menuBackground),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0)
                  .chain(CurveTween(curve: const Interval(0.0, 0.7)))
                  .animate(_controller),
              child: Consumer<DatabaseInfoProvider>(
                builder: (context, databaseInfoProvider, child) {
                  return Stack(
                    children: [
                      const GameLabel(
                        labelText: '樂 透 彩 券',
                      ),
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
