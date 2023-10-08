import 'package:flame_forge2d/flame_forge2d.dart';

class BuildingInfo {
  Vector2 buildingPosition;
  String direction;
  double bodyAngle;
  BuildingInfo({
    required this.buildingPosition,
    required this.direction,
    this.bodyAngle = 0,
  });
}
