import 'dart:async';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../../../../constants/route_planning_game_const.dart';

import '../models/building.dart';

enum ImageType {
  normal,
  light,
}

class BuildingComponent extends BodyComponent<RoutePlanningGameForge2d>
    with ContactCallbacks, Tappable {
  Building building;
  Vector2 buildingSize;
  Vector2 buildingPosition;
  String flagDirection;
  double bodyAngle;
  bool isHome;
  BuildingComponent({
    required this.building,
    required this.buildingSize,
    required this.buildingPosition,
    required this.bodyAngle,
    this.flagDirection = "",
    this.isHome = false,
  }) : super(
            renderBody: false, paint: BasicPalette.blue.withAlpha(100).paint());

  late SpriteGroupComponent buildingSprite;
  late SpriteComponent flagSprite;
  late SpriteComponent repeatedSprite;
  late SpriteComponent errorSprite;

  late Map<String, Vector2> flagPosition = {
    "up": Vector2(0, -(buildingSize.y / 2 + buildingSize.y / 4)),
    "down": Vector2(0, buildingSize.y / 2 + buildingSize.y / 4),
    "left": Vector2(-(buildingSize.x / 2 + buildingSize.x / 4), 0),
    "right": Vector2(buildingSize.x / 2 + buildingSize.x / 4, 0),
  };

  bool isContactToRider = false;
  bool isTappable = true;
  bool isTargetAchieved = false;

  @override
  Future<void> onLoad() async {
    buildingSprite = SpriteGroupComponent<ImageType>(
      sprites: isHome
          ? {
              ImageType.normal: await gameRef
                  .loadSprite(RoutePlanningGameConst.homeImagePath),
              ImageType.light: await gameRef
                  .loadSprite(RoutePlanningGameConst.homeLightImagePath),
            }
          : {
              ImageType.normal: await gameRef.loadSprite(
                  RoutePlanningGameConst.buildingsImagePath[building.id]),
              ImageType.light: await gameRef.loadSprite(
                  RoutePlanningGameConst.buildingsLightImagePath[building.id]),
            },
      current: ImageType.normal,
      size: buildingSize,
      position: Matrix2.rotation(-bodyAngle)
          .transform(Vector2.all(0) - Vector2(0, buildingSize.y * 0.1)),
      angle: -bodyAngle,
      anchor: Anchor.center,
    );
    add(buildingSprite);
    //! comment for debug
    if (gameRef.gameLevel < 2 && building.isTarget) {
      flagSprite = SpriteComponent(
        sprite: await gameRef.loadSprite(RoutePlanningGameConst.flagImagePath),
        size: buildingSize / 2,
        position: Matrix2.rotation(-bodyAngle)
            .transform(flagPosition[flagDirection]!),
        // anchor: anchorDir[flagDirection],
        angle: -bodyAngle,
        anchor: Anchor.center,
      );
      add(flagSprite);
    }
    //* hints
    repeatedSprite = SpriteComponent(
      sprite: await gameRef.loadSprite(RoutePlanningGameConst.repeatedHint),
      size: buildingSize,
      position: Vector2.zero(),
      anchor: Anchor.center,
    )..add(OpacityEffect.to(0, EffectController(duration: 0)));
    add(repeatedSprite);
    errorSprite = SpriteComponent(
      sprite: await gameRef.loadSprite(RoutePlanningGameConst.errorHint),
      size: buildingSize,
      position: Vector2.zero(),
      anchor: Anchor.center,
    )..add(OpacityEffect.to(0, EffectController(duration: 0)));
    add(errorSprite);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBoxXY(buildingSize.x / 2 * 1.3, buildingSize.y / 2 * 1.3);
    final bodyDef = BodyDef(
        type: BodyType.static,
        angle: bodyAngle,
        position: buildingPosition,
        userData: this);
    final fixtureDef = FixtureDef(shape)..isSensor = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    isContactToRider = true;
    if (isHome) {
      if (gameRef.targetList.allVisited()) {
        buildingSprite.current = ImageType.light;
        buildingSprite.size *= 2;
      }
    } else {
      buildingSprite.current = ImageType.light;
      buildingSprite.size *= 2;
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    isContactToRider = false;
    //* only when previous state is lighted up
    if (buildingSprite.current == ImageType.light) buildingSprite.size /= 2;
    buildingSprite.current = ImageType.normal;
    super.endContact(other, contact);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (buildingSprite.current == ImageType.light && isTappable) {
      if (isHome && gameRef.targetList.allVisited()) {
        gameRef.gameWin();
      } else if (building.isTarget) {
        //* repeated
        if (isTargetAchieved) {
          //* if remained show time is not 0
          if (gameRef.remainRepeatedHintShowTime > 0) {
            gameRef.remainRepeatedHintShowTime--;
            repeatedSprite
                .add(OpacityEffect.to(1, EffectController(duration: 0.3)));
            repeatedSprite.add(OpacityEffect.to(
                0, EffectController(duration: 0.3, startDelay: 2.4)));
          }
          gameRef.repeatedError++;
          //* penalty time
          if (gameRef.gameLevel > 0) gameRef.remainTime -= 3;
          FlameAudio.play(RoutePlanningGameConst.tapWrongBuilding);
        }
        //* first tapped
        else {
          if (gameRef.gameLevel < 2 && building.isTarget) {
            flagSprite.add(ScaleEffect.by(
              Vector2.all(3),
              EffectController(
                  duration: 1,
                  onMax: () {
                    flagSprite.opacity = 0;
                    gameRef.targetList.reachTarget(reachedIndex: building.id);
                  }),
            ));
          }
          //* get every first reach time
          gameRef.timeToEachHalfwayPoint
              .add(DateTime.now().difference(gameRef.startTime).inMilliseconds);
          isTargetAchieved = true;
          FlameAudio.play(RoutePlanningGameConst.pickFlagAudio);
        }
      } else {
        if (gameRef.remainErrorHintShowTime > 0) {
          gameRef.remainErrorHintShowTime--;
          errorSprite.add(OpacityEffect.to(1, EffectController(duration: 0.3)));
          errorSprite.add(OpacityEffect.to(
              0, EffectController(duration: 0.3, startDelay: 2.4)));
        }
        gameRef.nonTargetError++;
        //* penalty time
        if (gameRef.gameLevel > 0) gameRef.remainTime -= 3;
        FlameAudio.play(RoutePlanningGameConst.tapWrongBuilding);
      }
      //* delayed for next tap event
      isTappable = false;
      Future.delayed(const Duration(seconds: 3), () => isTappable = true);
    }
    return super.onTapDown(info);
  }
}
