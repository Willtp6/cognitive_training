import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class WallComponent extends BodyComponent {
  final Vector2 v1, v2, v3, v4;
  WallComponent({
    required this.v1,
    required this.v2,
    required this.v3,
    required this.v4,
    super.priority = 2,
  });
  final GlowEffect effect = GlowEffect(
      1.5, EffectController(duration: 1, reverseDuration: 0.5, infinite: true));
  @override
  Future<void> onLoad() {
    paint = BasicPalette.red.paint();
    return super.onLoad();
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.static);
    // final fixtureDef = FixtureDef(EdgeShape()..set(v1, v2));
    final fixtureDef = FixtureDef(PolygonShape()..set([v1, v2, v3, v4]));
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void addEffect() {
    add(effect);
  }

  void removeEffect() {
    effect
      ..reset()
      ..removeFromParent();
  }
}
