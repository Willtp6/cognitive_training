import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/games/lottery_game/lottery_game_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class LotteryGameMenu extends StatefulWidget {
  const LotteryGameMenu({super.key});

  @override
  State<LotteryGameMenu> createState() => _LotteryGameMenu();
}

class _LotteryGameMenu extends State<LotteryGameMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late UserInfoProvider userInfoProvider;
  bool buttonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  void startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _controller.forward();
      Future.delayed(const Duration(seconds: 2), () {
        _controller.reset();
        final level = userInfoProvider.lotteryGameDatabase.currentLevel;
        final digit = userInfoProvider.lotteryGameDatabase.currentDigit;
        final doneTutorial = userInfoProvider.lotteryGameDatabase.doneTutorial;
        if (doneTutorial) {
          Logger().i('continue game');
          GoRouter.of(context).pushNamed(
            'lottery_game',
            queryParams: {
              'startLevel': level.toString(),
              'startDigit': digit.toString(),
              'isTutorial': (!doneTutorial).toString(),
            },
          );
        } else {
          Logger().i('tutorial');
          GoRouter.of(context).pushNamed(
            'lottery_game',
            queryParams: {
              'startLevel': 0.toString(),
              'startDigit': 1.toString(),
              'isTutorial': 'true'
            },
          );
        }
        buttonEnabled = true;
      });
      Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
        _controller.reset();
      });
    }
  }

  void startTutorial() {
    if (buttonEnabled) {
      buttonEnabled = false;
      _controller.forward();
      Future.delayed(const Duration(seconds: 2), () {
        GoRouter.of(context).pushNamed(
          'lottery_game',
          queryParams: {
            'startLevel': 0.toString(),
            'startDigit': 1.toString(),
            'isTutorial': 'true'
          },
        );
        buttonEnabled = true;
      });
      Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
        _controller.reset();
      });
    }
  }

  void goBack() {
    if (buttonEnabled) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    userInfoProvider = context.read<UserInfoProvider>();
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
                        image: AssetImage(
                            'assets/lottery_game/scene/Temple1_withoutWord.png'),
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
              child: Consumer<UserInfoProvider>(
                builder: (context, userInfoProvider, child) {
                  return Stack(
                    children: [
                      gameLabel(),
                      Align(
                        alignment: const Alignment(0.0, 0.9),
                        child: FractionallySizedBox(
                          heightFactor: 0.45,
                          widthFactor: 0.3,
                          child: Column(
                            children: [
                              buttonWithText('進入遊戲', startGame),
                              buttonWithText('教學模式', startTutorial),
                              buttonWithText('返回', goBack),
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

  Align gameLabel() {
    return Align(
      alignment: const Alignment(0.0, -0.7),
      child: FractionallySizedBox(
        heightFactor: 0.2,
        widthFactor: 0.4,
        child: FittedBox(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 8),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: AutoSizeText(
                  '樂 透 彩 券',
                  style: TextStyle(
                    fontFamily: "GSR_B",
                    fontSize: 100,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Flexible buttonWithText(String text, Function onTapFunction) {
    return Flexible(
      child: AspectRatio(
        aspectRatio: 835 / 353,
        child: GestureDetector(
          onTap: () {
            onTapFunction();
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/global/continue_button.png'),
              ),
            ),
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 0.8,
              child: LayoutBuilder(
                builder:
                    (BuildContext buildContext, BoxConstraints boxConstraints) {
                  double width = boxConstraints.maxWidth;
                  return Center(
                    child: AutoSizeText(
                      text,
                      style: TextStyle(
                        fontSize: width / 4,
                        color: Colors.white,
                        fontFamily: 'GSR_B',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
