import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game/route_planning_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class BuildingComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<RoutePlanningGame> {
  final int buildingId;
  final int blockId;
  BuildingComponent({required this.buildingId, required this.blockId});

  @override
  FutureOr<void> onLoad() async {
    sprite = await gameRef.loadSprite(Globals.buildings[buildingId]);
    add(CircleHitbox(
      radius: size.x * sqrt(2) / 2,
      anchor: Anchor.center,
      position: size / 2,
    ));
    return super.onLoad();
  }
}
