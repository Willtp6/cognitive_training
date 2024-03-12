import 'dart:async';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../../../../constants/route_planning_game_const.dart';

enum MoveType {
  slideLeft,
  slideRight,
}

class Rider extends BodyComponent<RoutePlanningGameForge2d>
    with ContactCallbacks, Draggable {
  static const riderScale = [
    2 / 13,
    2 / 13,
    2 / 13,
    2 / 18,
    2 / 18,
    2 / 18,
    2 / 18,
    2 / 18,
    2 / 13,
    2 / 18,
  ];

  late double riderSize;

  late final double roadWidth2Roads;
  late final double roadWidth3Roads;
  late final double streetBlockHeight2Roads;
  late final double streetBlockHeight3Roads;
  late final double streetBlockWidth22Roads;
  late final double streetBlockWidth23Roads;
  late final double streetBlockWidth33Roads;
  late final double streetBlockWidth32Roads;

  late List<Vector2> startPosition = [
    Vector2(streetBlockWidth22Roads / 2,
        streetBlockHeight2Roads * 2 + roadWidth2Roads * 1.5),
    Vector2(streetBlockWidth23Roads + roadWidth2Roads / 2,
        streetBlockHeight2Roads * 2.5 + roadWidth2Roads * 2),
    Vector2(streetBlockWidth23Roads * 1.5 + roadWidth2Roads,
        streetBlockHeight2Roads * 2 + roadWidth2Roads * 1.5),
    Vector2(streetBlockWidth32Roads * 1.2 + roadWidth3Roads * 1.5,
        streetBlockHeight3Roads * 14 / 9 * 2.5 + roadWidth3Roads * 2),
    Vector2(streetBlockWidth33Roads + roadWidth3Roads * 0.5,
        streetBlockHeight3Roads * 12 / 14 / 2),
    Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
        streetBlockHeight3Roads * 44 / 14 + roadWidth3Roads * 2.5),
    Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 3.5,
        streetBlockHeight3Roads * 48 / 15 + roadWidth3Roads * 2.5),
    Vector2(streetBlockWidth33Roads / 2,
        streetBlockHeight3Roads * 44 / 14 + roadWidth3Roads * 2.5),
    Vector2(streetBlockWidth23Roads * 0.75 * 3 + roadWidth2Roads * 4,
        streetBlockHeight2Roads * 2.5 + roadWidth2Roads * 2),
    Vector2(streetBlockWidth33Roads * 3.5 + roadWidth3Roads * 3,
        streetBlockHeight3Roads * 48 / 15 + roadWidth3Roads * 2.5),
  ];

  late double speed;
  late SpriteGroupComponent<MoveType> riderSpriteComponent;

  Rider()
      : super(
          renderBody: false,
          paint: BasicPalette.pink.withAlpha(100).paint(),
        );

  Vector2 addOffset(Vector2 original) {
    return original + Vector2(215 / 720 * gameRef.size.y, 0);
  }

  @override
  Future<void> onLoad() async {
    final double mapWidth = gameRef.size.x - gameRef.size.y * 215 / 720;
    final double mapHeight = gameRef.size.y;

    roadWidth2Roads = mapHeight * 2 / 13;
    roadWidth3Roads = mapHeight * 2 / 18;

    streetBlockHeight2Roads = mapHeight * 3 / 13;
    streetBlockHeight3Roads = mapHeight * 3 / 18;
    streetBlockWidth22Roads = (mapWidth - 2 * roadWidth2Roads) / 3;
    streetBlockWidth23Roads = (mapWidth - 3 * roadWidth2Roads) / 4;
    streetBlockWidth33Roads = (mapWidth - 3 * roadWidth3Roads) / 4;
    streetBlockWidth32Roads = (mapWidth - 2 * roadWidth3Roads) / 3;

    riderSize = riderScale[gameRef.chosenMap] * gameRef.size.y * 0.9;

    speed = gameRef.size.x / 5;
    riderSpriteComponent = SpriteGroupComponent<MoveType>(
      sprites: {
        MoveType.slideLeft:
            await gameRef.loadSprite(RoutePlanningGameConst.riderLeft),
        MoveType.slideRight:
            await gameRef.loadSprite(RoutePlanningGameConst.riderRight),
      },
      current: MoveType.slideRight,
      size: Vector2.all(riderSize * 1.5),
      anchor: Anchor.center,
    );
    add(riderSpriteComponent);
    await super.onLoad();
  }

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBoxXY(riderSize / 2 * .75 * .75, riderSize / 2 * .75 * .75);
    final fixtureDef = FixtureDef(shape, userData: this);
    final bodyDef = BodyDef(
      position: gameRef.isTutorial
          ? addOffset(Vector2(
              streetBlockWidth22Roads * 2 + roadWidth2Roads * 1.5,
              streetBlockHeight2Roads * 2.5 + roadWidth2Roads * 2))
          : addOffset(startPosition[gameRef.chosenMap]),
      type: BodyType.dynamic,
      userData: this,
    );
    final shapeOfSensor = PolygonShape()
      ..setAsBoxXY(riderSize * .75, riderSize * .75);
    final fixtureDefOfSensor =
        FixtureDef(shapeOfSensor, userData: this, isSensor: true);
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..createFixture(fixtureDefOfSensor);
  }

  @override
  bool onDragStart(DragStartInfo info) {
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if ((info.eventPosition.game).distanceTo(body.position) <=
        riderSize * 1.5) {
      body.linearVelocity = info.delta.game * speed * 10;
    } else {
      body.linearVelocity = Vector2.all(0);
    }
    return false;
  }

  @override
  bool onDragCancel() {
    body.linearVelocity = Vector2.all(0);
    return super.onDragCancel();
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    body.linearVelocity = Vector2.all(0);
    return false;
  }
}
