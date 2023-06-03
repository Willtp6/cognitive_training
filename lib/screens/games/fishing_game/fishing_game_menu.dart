import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FishingGameMenu extends StatefulWidget {
  const FishingGameMenu({super.key});

  @override
  State<FishingGameMenu> createState() => _FishingGameMenuState();
}

class _FishingGameMenuState extends State<FishingGameMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _controller.reset();
    _controller.dispose();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var userInfoProvider = context.watch<UserInfoProvider>();
    return Stack(
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
                      begin: const Offset(0, 0), end: const Offset(-0.13, 0.11))
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
                    Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.reset();
                          _controller.forward();
                          _controller.addListener(() {
                            if (_controller.isCompleted) {
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                _controller.reset();
                              });
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
                          _controller.addListener(() {
                            if (_controller.isCompleted) {
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                _controller.reset();
                              });
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
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                _controller.reset();
                              });
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
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
