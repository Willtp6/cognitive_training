import 'dart:async';

import 'package:cognitive_training/screens/games/route_planning_game/route_planning_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class StreetBlock extends PolygonComponent
    with HasGameRef<RoutePlanningGame>, CollisionCallbacks {
  StreetBlock.relative(
    super.relation, {
    required super.parentSize,
    required super.position,
  }) : super.relative();

  @override
  FutureOr<void> onLoad() {
    paint = BasicPalette.gray.withAlpha(100).paint();
    return super.onLoad();
  }
}
