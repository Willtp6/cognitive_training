import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/constants/fishing_game_const.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:logger/logger.dart';
import '../fishing_game.dart';
import '../widgets/overlays/confirm_button.dart';

enum ChosenType {
  normal,
  chosen,
}

class RodComponent extends SpriteGroupComponent<ChosenType>
    with HasGameRef<FishingGame>, Tappable {
  RodComponent(
      {required this.rodId, required this.scaleLevel, super.priority = 0});

  static const List<double> aspectRatios = [
    386 / 888,
    386 / 888,
    1042 / 657,
    1042 / 657,
  ];

  late List<Vector2> positionList = [
    Vector2(gameRef.size.x * 0.35, gameRef.size.y * 0.7),
    Vector2(gameRef.size.x * 0.65, gameRef.size.y * 0.7),
    Vector2(size.x * 0.4, gameRef.size.y * 0.3),
    Vector2(gameRef.size.x - size.x * 0.4, gameRef.size.y * 0.3),
  ];

  late List<Vector2> sizeList = [
    Vector2(gameRef.size.y * 0.7 * aspectRatios[0], gameRef.size.y * 0.7),
    Vector2(gameRef.size.y * 0.7 * aspectRatios[1], gameRef.size.y * 0.7),
    Vector2(gameRef.size.y * 0.3 * aspectRatios[2], gameRef.size.y * 0.3),
    Vector2(gameRef.size.y * 0.3 * aspectRatios[3], gameRef.size.y * 0.3),
  ];

  late List<Vector2> rippleCenters = [
    Vector2(size.x * 0.9, size.y * 0.6),
    Vector2(size.x * 0.1, size.y * 0.6),
    Vector2(size.x * 0.95, size.y * 0.9),
    Vector2(size.x * 0.05, size.y * 0.9),
  ];

  final List<double> baseOfPower = [1.25, 1.2, 1.2, 1.15, 1.13];

  final int rodId;
  int scaleLevel;
  bool isChosen = false;

  late RiveComponent rippleComponent;

  late TimerComponent timerComponent;

  late Artboard rippleArtboard;
  OneShotAnimation controller = OneShotAnimation('animation', autoplay: false);

  @override
  FutureOr<void> onLoad() async {
    sprites = {
      ChosenType.normal:
          await gameRef.loadSprite(FishingGameConst.rodList[rodId]),
      ChosenType.chosen:
          await gameRef.loadSprite(FishingGameConst.rodLightList[rodId]),
    };
    current = ChosenType.normal;
    size = sizeList[rodId];
    position = positionList[rodId];
    anchor = Anchor.center;
    await initializeAnimation();
    await addRipple();
    return super.onLoad();
  }

  Future<void> initializeAnimation() async {
    controller = OneShotAnimation('animation', autoplay: false);
    rippleArtboard =
        await loadArtboard(RiveFile.asset(FishingGameConst.rippleAnimation));
    rippleArtboard.addController(controller);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (gameRef.rodTappable) {
      Logger().d(rodId);
      if (isChosen) {
        // gameRef.makeAllRodsInvisible();
        // gameRef.getResult();
        setImageToNormal();
        gameRef.overlays.remove(ConfirmButton.id);
      } else {
        gameRef.resetAllRodImages();
        setImageToLight();
        gameRef.overlays.add(ConfirmButton.id);
      }
      Logger().d(isChosen);
    }
    return super.onTapDown(info);
  }

  Future<void> addRipple() async {
    rippleComponent = RiveComponent(
      artboard: rippleArtboard,
      position: rippleCenters[rodId],
      size: Vector2(gameRef.size.x * 0.1, gameRef.size.x * 0.1 / 2),
      scale: Vector2.all(
          pow(baseOfPower[gameRef.gameLevel], scaleLevel).toDouble()),
      anchor: Anchor.center,
    );

    await add(rippleComponent);
  }

  void removeRipple() {
    remove(rippleComponent);
  }

  // void setRippleSize(int newScaleLevel) {
  //   rippleComponent.scale = Vector2.all(pow(1.2, scaleLevel).toDouble());
  // }

  void setImageToLight() {
    current = ChosenType.chosen;
    isChosen = true;
  }

  void setImageToNormal() {
    current = ChosenType.normal;
    isChosen = false;
  }
}
