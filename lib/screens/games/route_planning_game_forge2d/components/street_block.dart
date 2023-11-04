import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class StreetBlock extends BodyComponent {
  List<Vector2> vertices;
  Vector2 position;
  StreetBlock({
    required this.vertices,
    required this.position,
  }) : super(paint: BasicPalette.gray.withAlpha(100).paint());

  @override
  Body createBody() {
    final shape = PolygonShape()..set(vertices);
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position;
    final fixtureDef = FixtureDef(shape);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
