import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/screens/games/route_planning_game/components/building_component.dart';
import 'package:cognitive_training/screens/games/route_planning_game/components/map_entity.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/route_planning_game/route_planning_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:logger/logger.dart';

enum MoveType {
  slideLeft,
  slideRight,
}

class Rider extends SpriteGroupComponent
    with HasGameRef<RoutePlanningGame>, CollisionCallbacks {
  late double _width, _height;
  late Vector2 _startPosition;
  late double _speed;

  late double _leftBound;
  late double _rightBound;
  late double _upBound;
  late double _downBound;

  Vector2 from = Vector2.all(0);
  Vector2 to = Vector2.all(10);
  Vector2 vertical = Vector2.all(0);

  Vector2 parentSize;
  JoystickComponent joystick;
  // Function updateTargetList;

  Rider({
    required this.joystick,
    required this.parentSize,
  });

  bool collided = false;
  bool nearToBuilding = false;
  // double? hitAngle;

  @override
  FutureOr<void> onLoad() async {
    //* times 0.9 to get some space from collision
    //! this part may various from every map
    _width = _height = parentSize.y * 2 / 13 * 0.9;
    //! this part may vrious from every map
    //* set the start position to one of the road
    _startPosition = Vector2(_width / 2, parentSize.y * 4 / 13);

    //* set default speed
    _speed = parentSize.y / 5;
    //* set for bound of map
    _leftBound = _width / 2 + parentSize.x / 1000;
    _rightBound = parentSize.x - _width / 2 - parentSize.x / 1000;
    _upBound = _width / 2 + parentSize.y / 1000;
    _downBound = parentSize.y - _width / 2 - parentSize.y / 1000;

    //* spriteComponent define
    Sprite riderLeft = await gameRef.loadSprite(Globals.riderLeft);
    Sprite riderRight = await gameRef.loadSprite(Globals.riderRight);
    sprites = {
      MoveType.slideLeft: riderLeft,
      MoveType.slideRight: riderRight,
    };
    current = MoveType.slideRight;
    position = _startPosition;
    size = Vector2(_width, _height);
    anchor = Anchor.center;

    //* add hit box
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (joystick.direction == JoystickDirection.downRight ||
        joystick.direction == JoystickDirection.right ||
        joystick.direction == JoystickDirection.upRight) {
      current = MoveType.slideRight;
    } else if (joystick.direction == JoystickDirection.downLeft ||
        joystick.direction == JoystickDirection.left ||
        joystick.direction == JoystickDirection.upLeft) {
      current = MoveType.slideLeft;
    }
    //* which means that can't move to upRight or upLeft when up is the collision direction
    if (collided) {
      Vector2 vB = (to - from);
      Vector2 vA = joystick.relativeDelta;

      //* joystick dot vertical than divide each length
      //* can get the angle between two vectors
      //* finally we can get angle by cos(theta) value
      double joystickDotVertical = vertical.dot(vA);
      joystickDotVertical /= vertical.length * vA.length;
      double theta = acos(joystickDotVertical);
      double degree = theta / pi * 180;
      //* check if the joystick direction and vertical of hit is bigger than pi / 2 radious
      if (degree < 90) {
        //* A dot B = |A||B|cos(theta)
        //* the value I need is |A|cos(theta)
        Vector2 normalizedB = vB.normalized();
        double dotProduct = normalizedB.dot(vA);
        //* get the projection from A on B
        Vector2 projection = normalizedB.scaled(dotProduct);
        position += projection * _speed * dt;
      } else {
        position += vA * _speed * dt;
      }
    } else {
      position += joystick.relativeDelta * _speed * dt;
    }
    //* block the map margin
    if (position.x < _leftBound) {
      position.x = _leftBound;
    }
    if (position.x > _rightBound) {
      position.x = _rightBound;
    }
    if (position.y < _upBound) {
      position.y = _upBound;
    }
    if (position.y > _downBound) {
      position.y = _downBound;
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Logger().d(other);
    if (!collided && other is MapEntity) {
      collided = true;
      from = intersectionPoints.first;
      to = intersectionPoints.last;
      getVertical();
    } else if (other is BuildingComponent && !nearToBuilding) {
      Logger().d(other.buildingId);
      Logger().d(other.blockId);
      nearToBuilding = true;
      gameRef.removeBuildings(other.buildingId);
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is MapEntity) {
      collided = false;
    } else if (other is BuildingComponent) {
      nearToBuilding = false;
    }
    super.onCollisionEnd(other);
  }

  /*
    * this function is for calculating the vertical cector tothe hit plane
    * use this vecor can get the real angle between joystick and the plane
    */
  void getVertical() {
    Vector2 normalizedB = (to - from).normalized();
    double dotProduct = normalizedB.dot(joystick.relativeDelta);
    Vector2 move = normalizedB.scaled(dotProduct);
    vertical = joystick.relativeDelta - move;
  }
}
