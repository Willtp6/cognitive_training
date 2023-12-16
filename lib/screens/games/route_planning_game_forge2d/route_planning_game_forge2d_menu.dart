import 'dart:async';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/games/shared/game_label.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/button_with_text.dart';

class RoutePlanningGameForge2dMenu extends StatefulWidget {
  //static const String id = "RoutePlanningGameMenu";

  const RoutePlanningGameForge2dMenu({super.key});
  //final RoutePlanningGame game;
  @override
  State<RoutePlanningGameForge2dMenu> createState() =>
      _RoutePlanningGameForge2dMenuState();
}

class _RoutePlanningGameForge2dMenuState
    extends State<RoutePlanningGameForge2dMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late UserInfoProvider userInfoProvider;
  late AudioController audioController;
  bool buttonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startGame() {
    if (buttonEnabled) {
      buttonEnabled = false;
      audioController.playSfx(Globals.clickButtonSound);
      _controller.forward().whenComplete(() {
        String isTutorial =
            (!userInfoProvider.routePlanningGameDatabase.doneTutorial)
                .toString();
        context.pushNamed(
          'route_planning_game',
          queryParams: {'isTutorial': isTutorial},
        ).whenComplete(() {
          _controller.reset();
          buttonEnabled = true;
        });
      });
      Timer(Duration(milliseconds: (8000 * 0.2).toInt()), () {
        FlameAudio.play(RoutePlanningGameConst.phoneVibration);
      });
    }
  }

  void startTutorial() {
    if (buttonEnabled) {
      // buttonEnabled = false;
      // _controller.forward().whenComplete(() {
      //   context.pushNamed(
      //     'route_planning_game',
      //     queryParams: {'isTutorial': true.toString()},
      //   ).whenComplete(() {
      //     _controller.reset();
      //     buttonEnabled = true;
      //   });
      // });
      // Timer(Duration(milliseconds: (8000 * 0.2).toInt()), () {
      //   FlameAudio.play(RoutePlanningGameConst.phoneVibration);
      // });
      context.pushNamed(
        'route_planning_game',
        queryParams: {'isTutorial': true.toString()},
      );
    }
  }

  void goBack() {
    if (buttonEnabled) {
      audioController.playSfx(Globals.clickButtonSound);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    userInfoProvider = context.read<UserInfoProvider>();
    audioController = context.read<AudioController>();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Background(controller: _controller),
            FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0)
                  .chain(CurveTween(curve: const Interval(0.0, 0.2)))
                  .animate(_controller),
              child: Consumer<UserInfoProvider>(
                builder: (context, userInfoProvider, child) {
                  return Stack(
                    children: [
                      const GameLabel(labelText: '路線規劃'),
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
                                      text: '返回', onTapFunction: goBack)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            PhoneRing(controller: _controller),
            DialogBox(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class DialogBox extends StatelessWidget {
  const DialogBox({
    super.key,
    required controller,
  }) : _controller = controller;
  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    final opacitySequence = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    ]).chain(CurveTween(curve: const Interval(0.7, 1.0))).animate(_controller);
    return FadeTransition(
      opacity: opacitySequence,
      child: Align(
        alignment: const Alignment(-0.2, -1.0),
        child: FractionallySizedBox(
          heightFactor: 0.4,
          child: AspectRatio(
            aspectRatio: 1017 / 742,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(RoutePlanningGameConst.dialogBox),
                ),
              ),
              child: Stack(
                children: [
                  SlideTransition(
                    position: Tween(
                            begin: const Offset(0.4, 0.0),
                            end: const Offset(0.0, 0.0))
                        .chain(CurveTween(curve: const Interval(0.7, 1.0)))
                        .animate(_controller),
                    child: Align(
                      alignment: const Alignment(0.0, -0.45),
                      child: FractionallySizedBox(
                        heightFactor: 0.3,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child:
                              Image.asset(RoutePlanningGameConst.riderInMenu),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, 0.75),
                    child: FractionallySizedBox(
                      heightFactor: 0.3,
                      child: Image.asset(RoutePlanningGameConst.dialogBoxMom),
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
}

class PhoneRing extends StatelessWidget {
  const PhoneRing({
    super.key,
    required controller,
  }) : _controller = controller;

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    final opacitySequence = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).chain(CurveTween(curve: const Interval(0.2, 0.7))).animate(_controller);
    return FadeTransition(
      opacity: opacitySequence,
      child: Align(
        alignment: const Alignment(-0.2, -0.8),
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: AspectRatio(
            aspectRatio: 646 / 504,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(RoutePlanningGameConst.phoneRingImage),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Background extends StatelessWidget {
  const Background({
    super.key,
    required controller,
  }) : _controller = controller;

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position:
          Tween(begin: const Offset(0.0, 0.0), end: const Offset(-0.4, 0.3))
              .chain(CurveTween(curve: const Interval(0.0, 0.2)))
              .animate(_controller),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 2.5)
            .chain(CurveTween(curve: const Interval(0.0, 0.2)))
            .animate(_controller),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(RoutePlanningGameConst.menuBackground),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
