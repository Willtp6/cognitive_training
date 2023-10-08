import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/palette.dart';

class StreetBlockHitBox extends PolygonHitbox {
  StreetBlockHitBox.relative(super.relation,
      {required super.parentSize, required super.position})
      : super.relative();
  @override
  FutureOr<void> onLoad() {
    return super.onLoad();
  }
}
