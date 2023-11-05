import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'exit_button.dart';

import 'route_planning_game_rule.dart';

class GameLose extends StatefulWidget {
  static const id = 'GameLose';
  final RoutePlanningGameForge2d game;
  const GameLose({super.key, required this.game});

  @override
  State<GameLose> createState() => _GameLoseState();
}

class _GameLoseState extends State<GameLose>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlameAudio.play(RoutePlanningGameConst.loseAudio);
      controller.forward().whenComplete(() {
        widget.game.overlays.remove(GameLose.id);
        widget.game.overlays.add(RoutePlanningGameRule.id);
        widget.game.overlays.add(ExitButton.id);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(begin: const Offset(0, 0), end: const Offset(0.15, -0.3))
          .animate(controller),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 2.0).animate(controller),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(RoutePlanningGameConst.routeLose),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
