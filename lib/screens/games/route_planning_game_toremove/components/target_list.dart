import 'dart:async';

import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/route_planning_game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class TargetList extends SpriteComponent with HasGameRef<RoutePlanningGame> {
  List<int> targetsID;

  TargetList({required this.targetsID});

  List<SpriteComponent> targets = [];
  late double targetImageWidth;
  late double targetImageHeight;
  late double targetGap;

  @override
  FutureOr<void> onLoad() async {
    // sprite = await gameRef.loadSprite(Globals.targetList);
    size.y = gameRef.size.y;
    size.x = size.y * 215 / 720;

    RectangleComponent listItem = RectangleComponent(
      size: Vector2(size.x * 0.6, size.y * 0.75),
      position: Vector2(size.x / 2, size.y * 0.525),
      anchor: Anchor.center,
      paint: BasicPalette.white.withAlpha(0).paint(),
    );
    defineTargetSize(size.x * 0.6, size.y * 0.75);
    for (int i = 0; i < targetsID.length; i++) {
      // targets.add(
      //   SpriteComponent(
      //       sprite: await gameRef.loadSprite(Globals.buildings[targetsID[i]]),
      //       size: Vector2(targetImageWidth, targetImageHeight),
      //       position: Vector2(size.x * 0.6 / 2,
      //           i * targetImageHeight * 11 / 10 + targetImageHeight / 2),
      //       anchor: Anchor.center),
      // );
    }
    listItem.addAll(targets);

    add(listItem);
    return super.onLoad();
  }

  void defineTargetSize(double listWidth, double listHeight) {
    double totalHeight =
        listWidth * (targetsID.length + (targets.length - 1) / 20);
    if (listHeight >= totalHeight) {
      targetImageWidth = targetImageHeight = listWidth;
    } else {
      //* (n + (n - 1)/10)*width = height
      targetImageWidth = targetImageHeight =
          listHeight / (targetsID.length + (targetsID.length - 1) / 20);
    }
  }
}
