import 'dart:async';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../../constants/route_planning_game_const.dart';

enum MoveType {
  slideLeft,
  slideRight,
}

class Rider extends BodyComponent<RoutePlanningGameForge2d>
    with ContactCallbacks /*, Draggable */ {
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

  late double _width, _height;
  late double mapSizeY = gameRef.size.y;
  late JoystickComponent joystick;

  late final double roadWidth2Roads;
  late final double roadWidth3Roads;
  late final double streetBlockHeight2Roads;
  late final double streetBlockHeight3Roads;
  late final double streetBlockWidth22Roads;
  late final double streetBlockWidth23Roads;
  late final double streetBlockWidth33Roads;
  late final double streetBlockWidth32Roads;

  // bool collided = false;
  // bool nearToBuilding = false;

  late double speed;
  late SpriteGroupComponent<MoveType> riderSpriteComponent;

  Rider()
      : super(
          renderBody: true,
          paint: BasicPalette.pink.withAlpha(100).paint(),
        );

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBoxXY(_width / 2 * .75, _height / 2 * .75);
    final fixtureDef = FixtureDef(shape, userData: this);
    final bodyDef = BodyDef(
      position:
          startPosition[gameRef.chosenMap] + Vector2(215 / 720 * mapSizeY, 0),
      type: BodyType.dynamic,
      userData: this,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    final double mapWidth = gameRef.size.x - gameRef.size.y * 215 / 720;
    final double mapHeight = gameRef.size.y;
    //*
    roadWidth2Roads = mapHeight * 2 / 13;
    roadWidth3Roads = mapHeight * 2 / 18;

    streetBlockHeight2Roads = mapHeight * 3 / 13;
    streetBlockHeight3Roads = mapHeight * 3 / 18;
    streetBlockWidth22Roads = (mapWidth - 2 * roadWidth2Roads) / 3;
    streetBlockWidth23Roads = (mapWidth - 3 * roadWidth2Roads) / 4;
    streetBlockWidth33Roads = (mapWidth - 3 * roadWidth3Roads) / 4;
    streetBlockWidth32Roads = (mapWidth - 2 * roadWidth3Roads) / 3;
    //*
    joystick = gameRef.joystick;

    _width = _height = riderScale[gameRef.chosenMap] * gameRef.size.y * 0.9;
    // joystick = JoystickComponent(
    //   knob: CircleComponent(
    //     radius: 10 / 2,
    //     paint: BasicPalette.red.withAlpha(150).paint(),
    //   ),
    //   background: CircleComponent(
    //     radius: 10,
    //     paint: BasicPalette.red.withAlpha(100).paint(),
    //   ),
    //   margin: const EdgeInsets.all(0),
    //   // size: 10,
    //   // margin: EdgeInsets.only(
    //   //     left: (_width.y / 10 + 215 / 720 * _width) * 10, bottom: _width),
    //   // position: Vector2(size.y, size.y),
    // );
    // add(joystick);
    speed = gameRef.size.x / 10;
    riderSpriteComponent = SpriteGroupComponent<MoveType>(
      sprites: {
        MoveType.slideLeft:
            await gameRef.loadSprite(RoutePlanningGameConst.riderLeft),
        MoveType.slideRight:
            await gameRef.loadSprite(RoutePlanningGameConst.riderRight),
      },
      current: MoveType.slideRight,
      size: Vector2(_width, _height),
      anchor: Anchor.center,
    );
    add(riderSpriteComponent);
    await super.onLoad();
  }

  @override
  void update(double dt) {
    body.linearVelocity = joystick.relativeDelta * speed;
    joystick.position = body.position * 10;

    //* change the sprite direction
    if (joystick.direction == JoystickDirection.downRight ||
        joystick.direction == JoystickDirection.right ||
        joystick.direction == JoystickDirection.upRight) {
      riderSpriteComponent.current = MoveType.slideRight;
    } else if (joystick.direction == JoystickDirection.downLeft ||
        joystick.direction == JoystickDirection.left ||
        joystick.direction == JoystickDirection.upLeft) {
      riderSpriteComponent.current = MoveType.slideLeft;
    }
    super.update(dt);
  }
}
