import 'dart:async';

import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/screens/games/fishing_game/fishing_game.dart';
import 'package:flame/components.dart';

enum BackGoundImage {
  fishing,
  result,
}

class BackGroundComponent extends SpriteGroupComponent<BackGoundImage>
    with HasGameRef<FishingGame> {
  @override
  FutureOr<void> onLoad() async {
    // sprite = await gameRef.loadSprite(Globals.fishingGameBackground);
    sprites = {
      BackGoundImage.fishing:
          await gameRef.loadSprite(Globals.fishingGameBackground),
      BackGoundImage.result:
          await gameRef.loadSprite(Globals.fishingGameResult),
    };
    current = BackGoundImage.fishing;
    size = gameRef.size;
    position = size / 2;
    anchor = Anchor.center;
    return super.onLoad();
  }

  void changeToFishing() {
    current = BackGoundImage.fishing;
  }

  void changeToResult() async {
    current = BackGoundImage.result;
  }
}
