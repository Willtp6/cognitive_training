import 'package:flame_forge2d/flame_forge2d.dart';

class WallComponent extends BodyComponent {
  final Vector2 v1, v2;
  WallComponent({required this.v1, required this.v2});

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.static);
    final fixtureDef = FixtureDef(EdgeShape()..set(v1, v2));
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
