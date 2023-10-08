import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'route_planning_game_rule.dart';

class GameWin extends StatefulWidget {
  static const id = 'GameWin';
  const GameWin({super.key, required this.game});
  final RoutePlanningGameForge2d game;
  @override
  State<GameWin> createState() => _GameWinState();
}

class _GameWinState extends State<GameWin> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late AudioController audioController;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlameAudio.play(RoutePlanningGameConst.winAudio);
      controller.forward().whenComplete(() {
        widget.game.overlays.remove(GameWin.id);
        widget.game.overlays.add(RoutePlanningGameRule.id);
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
      position: Tween(begin: const Offset(0, 0), end: const Offset(-0.25, -0.1))
          .animate(controller),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 2.0).animate(controller),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(RoutePlanningGameConst.routeWin),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
