import 'dart:async';

import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class BackgroundComponent extends RectangleComponent
    with HasGameRef<RoutePlanningGameForge2d> {
  @override
  FutureOr<void> onLoad() {
    size = gameRef.size;
    paint = BasicPalette.white.paint();
    return super.onLoad();
  }
}
