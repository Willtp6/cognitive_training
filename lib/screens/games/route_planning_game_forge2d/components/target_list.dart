import 'dart:async';

import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import '../models/building.dart';

class TargetList extends SpriteComponent
    with HasGameRef<RoutePlanningGameForge2d> {
  late List<int> targetsID;

  List<SpriteComponent> targetsSprite = [];
  late double targetImageWidth;
  late double targetImageHeight;
  late double targetGap;

  late RectangleComponent listItem;

  TargetList({super.priority = 3});

  @override
  FutureOr<void> onLoad() async {
    sprite = await gameRef.loadSprite(RoutePlanningGameConst.targetList);
    size = Vector2(gameRef.size.y * 215 / 720, gameRef.size.y);
    listItem = RectangleComponent(
      size: Vector2(size.x * 0.6, size.y * 0.75),
      position: Vector2(size.x / 2, size.y * 0.525),
      anchor: Anchor.center,
      paint: BasicPalette.white.withAlpha(0).paint(),
    );
    add(listItem);
    return super.onLoad();
  }

  void addBuildings({required List<Building> buildings}) async {
    targetsSprite.clear();
    targetsID = buildings
        .where((element) => element.isTarget)
        .map((e) => e.id)
        .toList();

    defineTargetSize(size.x * 0.6, size.y * 0.75);
    for (int i = 0; i < targetsID.length; i++) {
      targetsSprite.add(
        SpriteComponent(
          sprite: await gameRef.loadSprite(
              RoutePlanningGameConst.buildingsImagePath[targetsID[i]]),
          size: Vector2(targetImageWidth, targetImageHeight),
          position: Vector2(size.x * 0.6 / 2,
              i * targetImageHeight * 11 / 10 + targetImageHeight / 2),
          anchor: Anchor.center,
        ),
      );
    }
    listItem.addAll(targetsSprite);
  }

  void removeAllBuildings() {
    listItem.removeAll(targetsSprite);
  }

  /// for define the size of each building in the list
  void defineTargetSize(double listWidth, double listHeight) {
    //* every gap between is width / 20
    double totalHeight =
        listWidth * (targetsID.length + (targetsID.length - 1) / 20);
    if (listHeight >= totalHeight) {
      targetImageWidth = targetImageHeight = listWidth;
    } else {
      //* (n + (n - 1)/10)*width = height
      targetImageWidth = targetImageHeight =
          listHeight / (targetsID.length + (targetsID.length - 1) / 20);
    }
  }

  void reachTarget({required reachedIndex}) {
    int index = targetsID.indexOf(reachedIndex);
    targetsSprite[index].opacity = 0.3;
  }

  bool allVisited() {
    return !targetsSprite.any((element) => (element.opacity == 1));
  }
}
