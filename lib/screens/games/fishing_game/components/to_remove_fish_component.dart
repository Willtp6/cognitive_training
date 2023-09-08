// import 'dart:async';
// import 'dart:math';

// import 'package:cognitive_training/constants/globals.dart';
// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';

// import '../fishing_game.dart';

// List<List<String>> possibleFishTypes = [
//   ["C"],
//   ["B", "C"],
//   ["B"],
//   ["A", "B"],
//   ["A", "B"],
// ];

// Map<String, int> possibleFishIndexes = {
//   "C": 7,
//   "B": 7,
//   "A": 8,
// };

// class FishComponent extends SpriteComponent with HasGameRef<FishingGame> {
//   late String fishType;
//   late int fishIndex;

//   @override
//   FutureOr<void> onLoad() async {
//     getFish();
//     size = Vector2.all(0);
//     position = Vector2(gameRef.size.x / 2, gameRef.size.y * 0.6);
//     anchor = Anchor.center;
//     opacity = 0;
//     return super.onLoad();
//   }

//   void getFish() async {
//     int index = Random().nextInt(possibleFishTypes[gameRef.gameLevel].length);
//     fishType = possibleFishTypes[gameRef.gameLevel][index];
//     fishIndex = Random().nextInt(possibleFishIndexes[fishType]!);
//     sprite =
//         await gameRef.loadSprite(Globals.fishesImages[fishType]![fishIndex]);
//   }

//   void reset() {
//     addAll([
//       SizeEffect.to(Vector2.all(0), EffectController(duration: 0.3)),
//       MoveEffect.to(Vector2(gameRef.size.x / 2, gameRef.size.y * 0.6),
//           EffectController(duration: 0.3)),
//       OpacityEffect.to(0, EffectController(duration: 0.3)),
//     ]);
//   }
// }
