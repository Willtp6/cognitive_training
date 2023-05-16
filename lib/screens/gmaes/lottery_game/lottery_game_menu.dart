import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game_scene.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.reset();
    // _controller.dispose();
    // _controller =
    //     AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'assets/lottery_game_scene/Temple1_withoutWord.png'),
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
                    Align(
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
                    ),
                    Align(
                      alignment: const Alignment(-0.25, 0.45),
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.15,
                        child: AspectRatio(
                          aspectRatio: 835 / 353,
                          child: GestureDetector(
                            onTap: () {
                              _controller.forward();
                              _controller.addListener(() {
                                if (_controller.isCompleted) {
                                  _controller.reset();
                                  final isTutorial = userInfoProvider
                                          .lotteryGameDatabase.doneTutorial
                                      ? false
                                      : true;
                                  GoRouter.of(context).goNamed(
                                    'lottery_game',
                                    queryParams: {
                                      'isTutorial': isTutorial.toString(),
                                    },
                                  );
                                }
                              });
                            },
                            child: buttonWithText('新遊戲', Alignment.bottomRight,
                                Alignment.centerRight),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.25, 0.45),
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.15,
                        child: AspectRatio(
                          aspectRatio: 835 / 353,
                          child: GestureDetector(
                            onTap: () {
                              _controller.forward();
                              _controller.addListener(() {
                                if (_controller.isCompleted) {
                                  _controller.reset();
                                  final level = userInfoProvider
                                      .lotteryGameDatabase.currentLevel;
                                  final digit = userInfoProvider
                                      .lotteryGameDatabase.currentDigit;
                                  final isTutorial = userInfoProvider
                                          .lotteryGameDatabase.doneTutorial
                                      ? false
                                      : true;
                                  GoRouter.of(context).goNamed(
                                    'lottery_game',
                                    queryParams: {
                                      'startLevel': level.toString(),
                                      'startDigit': digit.toString(),
                                      'isTutorial': isTutorial.toString(),
                                    },
                                  );
                                }
                              });
                            },
                            child: buttonWithText('繼續遊戲', Alignment.bottomLeft,
                                Alignment.centerLeft),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.25, 0.8),
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.15,
                        child: AspectRatio(
                          aspectRatio: 835 / 353,
                          child: GestureDetector(
                            onTap: () {
                              _controller.forward();
                              _controller.addListener(() {
                                if (_controller.isCompleted) {
                                  _controller.reset();
                                  GoRouter.of(context).goNamed(
                                    'lottery_game',
                                    queryParams: {'isTutorial': 'true'},
                                  );
                                }
                              });
                            },
                            child: buttonWithText('教學模式', Alignment.topRight,
                                Alignment.centerRight),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.25, 0.8),
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.15,
                        alignment: Alignment.topLeft,
                        child: AspectRatio(
                          aspectRatio: 835 / 353,
                          child: GestureDetector(
                            onTap: () {
                              GoRouter.of(context).pop();
                            },
                            child: buttonWithText(
                                '返回', Alignment.topLeft, Alignment.centerLeft),
                          ),
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
    );
  }

  Widget buttonWithText(
      String text, Alignment buttonAlignment, Alignment textAlignment) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/global/continue_button.png'),
          alignment: buttonAlignment,
        ),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.5,
        widthFactor: 0.8,
        alignment: textAlignment,
        child: Center(
          child: AutoSizeText(
            text,
            style: const TextStyle(
              fontSize: 100,
            ),
          ),
        ),
      ),
    );
  }
}
