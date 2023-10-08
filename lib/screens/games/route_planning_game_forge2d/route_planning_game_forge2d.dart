import 'dart:async';
import 'dart:math';
import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'components/wall_component.dart';
import 'components/background_component.dart';
import 'components/target_list.dart';
import 'components/rider.dart';
import 'components/map_entity.dart';
import 'models/building.dart';
import 'widgets/overlays/game_lose.dart';
import 'widgets/overlays/game_win.dart';

class RoutePlanningGameForge2d extends Forge2DGame
    with HasTappables /*, HasDraggables*/ {
  int gameLevel;

  RoutePlanningGameForge2d({
    this.gameLevel = 0,
  }) : super(gravity: Vector2.all(0));

  static const List<int> numOfBuildings = [6, 8, 8, 8, 10];

  static const List<int> numOfTarget = [3, 3, 4, 4, 4];

  static const List<List<int>> possibleMapIndex = [
    [0, 1, 2, 3],
    [0, 1, 2, 3],
    [2, 3, 4, 5, 6, 7],
    [4, 5, 6, 7, 8, 9],
    [4, 5, 6, 7, 8, 9],
  ];

  static const List<double> hintImageShowTime = [double.infinity, 1, 0, 0, 0];

  late List<Building> buildings = [];
  late TargetList targetList;
  late Rider rider;
  late JoystickComponent joystick;
  late MapEntity map;
  late int chosenMap;
  late double remainRepeatedHintShowTime;
  late double remainErrorHintShowTime;

  late TimerComponent countDownTimer;

  @override
  void onAttach() {
    FlameAudio.bgm.initialize();
    super.onAttach();
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
  }

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    //? the problem is that the size need to times 10 maybe because in forge2d game
    //? size is 10 times smaller than in flame game.
    //? while the other which takes gameRef.size to get size don't need to
    //? times 10 reason is unknown.
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: size.y / 5,
        paint: BasicPalette.red.withAlpha(150).paint(),
      ),
      background: CircleComponent(
        radius: size.y / 2,
        paint: BasicPalette.red.withAlpha(100).paint(),
      ),
      // margin: EdgeInsets.only(
      //     left: (size.y / 10 + 215 / 720 * size.y) * 10, bottom: size.y),
      position: size / 2,
    );
    map = MapEntity(
      size: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    targetList = TargetList();

    //* all of them are static component
    addAll([
      BackgroundComponent(),
      //* four edges
      WallComponent(v1: Vector2(0, 0), v2: Vector2(size.x, 0)),
      WallComponent(v1: Vector2(0, size.y), v2: Vector2(size.x, size.y)),
      WallComponent(
          v1: Vector2(215 / 720 * size.y, 0),
          v2: Vector2(215 / 720 * size.y, size.y)),
      WallComponent(v1: Vector2(size.x, 0), v2: Vector2(size.x, size.y)),

      map,
      joystick,
      targetList,
      // rider,
    ]);

    return super.onLoad();
  }

  void startGame() async {
    // FlameAudio.bgm.play(RoutePlanningGameConst.bgm);
    //* get a new map index
    // chosenMap = 9;
    int numOfPossibleMap = possibleMapIndex[gameLevel].length;
    chosenMap = possibleMapIndex[gameLevel][Random().nextInt(numOfPossibleMap)];
    //* set hint image show time
    remainRepeatedHintShowTime = hintImageShowTime[gameLevel];
    remainErrorHintShowTime = hintImageShowTime[gameLevel];
    //* add rider
    rider = Rider();
    if (gameLevel > 0) {
      countDownTimer = TimerComponent(
        period: 30,
        removeOnFinish: true,
        onTick: () {
          gameLose();
        },
      );
      add(countDownTimer);
    }

    await addAll([rider]);
    generateBuildings();
    targetList.addBuildings(buildings: buildings);

    map.addBlocks(mapIndex: chosenMap);
    //! test for all block
    // map.addAllBuildingsAsHome();
    map.addBuildings(buildings: buildings);
  }

  /// remove all added dynamic components
  /// also reset all values
  void resetGame() {
    targetList.removeAllBuildings();
    map.removeBlocks();
    map.removeBuildings();
    remove(rider);
  }

  void generateBuildings() {
    buildings.clear();
    while (buildings.length < numOfBuildings[gameLevel]) {
      int toAddId = Random().nextInt(40);
      //* which means the is already in the list
      if (buildings.where((element) => element.id == toAddId).isNotEmpty) {
        continue;
      } else {
        //* if target is not enough then set to target
        bool needMoreTarget =
            buildings.where((element) => element.isTarget).length <
                numOfTarget[gameLevel];
        buildings.add(Building(id: toAddId, isTarget: needMoreTarget));
      }
    }
  }

  void gameWin() {
    FlameAudio.bgm.stop();
    if (gameLevel > 0) {
      remove(countDownTimer);
    }
    overlays.add(GameWin.id);
    resetGame();
  }

  void gameLose() {
    FlameAudio.bgm.stop();
    overlays.add(GameLose.id);
    resetGame();
  }
}
