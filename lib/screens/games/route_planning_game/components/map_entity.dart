import 'dart:math';

import 'package:cognitive_training/screens/games/route_planning_game/components/building_component.dart';
import 'package:cognitive_training/screens/games/route_planning_game/components/rider.dart';
import 'package:cognitive_training/screens/games/route_planning_game/components/street_block.dart';
import 'package:cognitive_training/screens/games/route_planning_game/components/street_block_hitbox.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game/route_planning_game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MapEntity extends RectangleComponent with HasGameRef<RoutePlanningGame> {
  final int nums;
  MapEntity({
    super.position,
    super.size,
    super.anchor,
    super.paint,
    this.nums = 9,
  });

  late final double roadWidth;
  late final double streetBlockWidth;
  late final double streetBlockHeight;
  late final double streetBlockWidthScale;
  late final double streetBlockHeightScale;

  List<StreetBlock> blocks = [];
  List<StreetBlockHitBox> blockHitBoxes = [];

  //* blocks vector which represent by relative
  late List<List<Vector2>> vectors = [
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, streetBlockHeightScale * 2),
      Vector2(streetBlockWidthScale * 2, 0),
    ],
  ];

  // * list of topleft point of blocks
  late List<Vector2> startPos = [
    Vector2.all(0),
    Vector2(roadWidth + streetBlockWidth, 0),
    Vector2(2 * roadWidth + 2 * streetBlockWidth, 0),
    Vector2(0, roadWidth + streetBlockHeight),
    Vector2(roadWidth + streetBlockWidth, roadWidth + streetBlockHeight),
    Vector2(
        2 * roadWidth + 2 * streetBlockWidth, roadWidth + streetBlockHeight),
    Vector2(0, 2 * roadWidth + 2 * streetBlockHeight),
    Vector2(
        roadWidth + streetBlockWidth, 2 * roadWidth + 2 * streetBlockHeight),
    Vector2(2 * roadWidth + 2 * streetBlockWidth,
        2 * roadWidth + 2 * streetBlockHeight)
  ];

  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    roadWidth = size.y * 2 / 13;
    streetBlockHeightScale = 3 / 13;
    streetBlockHeight = size.y * streetBlockHeightScale;
    streetBlockWidthScale = (size.x - 2 * roadWidth) / 3 / size.x;
    streetBlockWidth = size.x * streetBlockWidthScale;

    for (int i = 0; i < nums; i++) {
      blocks.add(StreetBlock.relative(
        vectors[i],
        parentSize: size,
        position: startPos[i],
      ));
      blockHitBoxes.add(StreetBlockHitBox.relative(
        vectors[i],
        parentSize: size,
        position: startPos[i],
      ));
    }

    for (int i = 0; i < Globals.numberOfBuildings[1]!; i++) {
      blocks[gameRef.buildingsBlockID[i]].add(BuildingComponent(
        buildingId: gameRef.buildingsID[i],
        blockId: gameRef.buildingsBlockID[i],
      )
        ..size = Vector2.all(min(blocks[i].size.x, blocks[i].size.y) * 0.8)
        ..position = Vector2(blocks[i].size.x / 2, blocks[i].size.y / 2)
        ..anchor = Anchor.center);
    }
    //* add all component to map
    addAll(blocks);
    addAll(blockHitBoxes);

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: gameRef.size.y / 20,
        paint: BasicPalette.red.withAlpha(200).paint(),
      ),
      background: CircleComponent(
        radius: gameRef.size.y / 10,
        paint: BasicPalette.red.withAlpha(100).paint(),
      ),
      margin: EdgeInsets.only(
          left: gameRef.size.y / 10, bottom: gameRef.size.y / 10),
    );

    add(Rider(
      joystick: joystick,
      parentSize: size,
    ));
    add(joystick);
    return super.onLoad();
  }
}
