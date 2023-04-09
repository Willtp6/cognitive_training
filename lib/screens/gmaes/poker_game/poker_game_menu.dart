import 'dart:async';

import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:cognitive_training/screens/gmaes/poker_game/poker_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PokerGameMenu extends StatefulWidget {
  const PokerGameMenu({super.key});

  @override
  State<PokerGameMenu> createState() => _PokerGameMenu();
}

class _PokerGameMenu extends State<PokerGameMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late UserInfoProvider userInfoProvider;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.reset();
    _controller.dispose();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    //userInfoProvider = Provider.of<UserInfoProvider>(context);
    return Stack(
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.6).animate(_controller),
          child: SlideTransition(
            position:
                Tween(begin: const Offset(0, 0), end: const Offset(0.05, 0.05))
                    .animate(_controller),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/poker_game_scene/Park1_witoutWalker.png'),
                  fit: BoxFit.fill,
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
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Text(
                        'Game Label',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Flexible(flex: 2, child: Container()),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.forward();
                        _controller.addListener(() {
                          if (_controller.isCompleted) {
                            GoRouter.of(context)
                                .push('/home/poker_game_menu/poker_game');
                            _controller.reset();
                          }
                        });
                      },
                      child: const Text('開始新遊戲'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.reset();
                        _controller.forward();
                        final level =
                            userInfoProvider.pokerGameDatabase.currentLevel;
                        final doneTutorial =
                            userInfoProvider.pokerGameDatabase.doneTutorial;
                        _controller.addListener(() {
                          if (_controller.isCompleted) {
                            GoRouter.of(context).push(
                                '/home/poker_game_menu/poker_game?startLevel=$level&isTutorial=$doneTutorial');
                            _controller.reset();
                          }
                        });
                      },
                      child: const Text('繼續遊戲'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.reset();
                        _controller.forward();
                        _controller.addListener(() {
                          if (_controller.isCompleted) {
                            GoRouter.of(context).push(
                                '/home/poker_game_menu/poker_game?startLevel=0&isTutorial=true');
                            _controller.reset();
                          }
                        });
                      },
                      child: const Text('教學模式'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                      child: const Text('返回'),
                    ),
                  ),
                  //Expanded(flex: 1, child: Placeholder()),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
