import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/constants/globals.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../fishing_game.dart';

enum ResultType {
  fish,
  none,
}

List<List<String>> possibleFishTypes = [
  ["C"],
  ["B", "C"],
  ["B"],
  ["A", "B"],
  ["A", "B"],
];

Map<String, int> possibleFishIndexes = {
  "C": 8,
  "B": 7,
  "A": 7,
};

class ResultComponent extends SpriteGroupComponent<ResultType>
    with HasGameRef<FishingGame> {
  late SpriteComponent fishComponent;
  late TextComponent labelComponent;
  late String fishType;
  late int fishIndex;
  @override
  FutureOr<void> onLoad() async {
    sprites = {
      ResultType.fish:
          await gameRef.loadSprite(Globals.fishingResultBackGround),
      ResultType.none: await gameRef.loadSprite(Globals.fishingResultEmptyRod),
    };
    current = ResultType.fish;
    position = gameRef.size / 2;
    size = Vector2(gameRef.size.y * 0.1 * 2, gameRef.size.y * 0.1);
    opacity = 0;
    anchor = Anchor.center;

    getFish();
    fishComponent = SpriteComponent(
      sprite:
          await gameRef.loadSprite(Globals.fishesImages[fishType]![fishIndex]),
      size: Vector2.all(size.y * 0.6),
      position: Vector2(size.x * 0.5, size.y * 0.7),
      anchor: Anchor.center,
    )..opacity = 0;
    add(fishComponent);
    labelComponent = TextComponent(
      text: '大 魚 入 場 !',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black.withOpacity(0),
          fontFamily: 'GSR_B',
          fontSize: size.x / 10,
        ),
      ),
      size: Vector2(size.x * 0.9, size.y * 0.4),
      position: Vector2(size.x * 0.5, size.y * 0.2),
      anchor: Anchor.center,
    );
    add(labelComponent);
    return super.onLoad();
  }

  void getFish() {
    int index = Random().nextInt(possibleFishTypes[gameRef.gameLevel].length);
    fishType = possibleFishTypes[gameRef.gameLevel][index];
    fishIndex = Random().nextInt(possibleFishIndexes[fishType]!);
  }

  void isFish() async {
    current = ResultType.fish;
    getFish();
    fishComponent.sprite =
        await gameRef.loadSprite(Globals.fishesImages[fishType]![fishIndex]);
    addAll([
      ScaleEffect.by(Vector2.all(8), EffectController(duration: 0.5)),
      OpacityEffect.to(1, EffectController(duration: 0.5)),
    ]);
    fishComponent.add(OpacityEffect.to(1, EffectController(duration: 0.5)));
    labelComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black.withOpacity(1),
        fontFamily: 'GSR_B',
        fontSize: size.x / 10,
      ),
    );
  }

  void isEmpty() {
    current = ResultType.none;
    addAll([
      ScaleEffect.by(Vector2.all(6), EffectController(duration: 0.5)),
      OpacityEffect.to(1, EffectController(duration: 0.5)),
    ]);
  }

  void reset() {
    switch (current) {
      case ResultType.fish:
        add(ScaleEffect.by(
            Vector2.all(1 / 8), EffectController(duration: 0.5)));
        fishComponent.add(OpacityEffect.to(0, EffectController(duration: 0.5)));
        labelComponent.textRenderer = TextPaint(
          style: TextStyle(
            color: Colors.black.withOpacity(0),
            fontFamily: 'GSR_B',
            fontSize: size.x / 10,
          ),
        );
        break;
      case ResultType.none:
        add(ScaleEffect.by(
            Vector2.all(1 / 6), EffectController(duration: 0.5)));
        break;
      default:
        break;
    }
    add(OpacityEffect.to(0, EffectController(duration: 0.3)));
  }
}
