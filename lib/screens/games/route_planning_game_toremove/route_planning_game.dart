import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/screens/games/route_planning_game_toremove/components/map_entity.dart';
import 'package:cognitive_training/screens/games/route_planning_game_toremove/components/target_list.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:logger/logger.dart';

class RoutePlanningGame extends FlameGame
    with HasCollisionDetection, HasTappables {
  //* define background color to black
  // @override
  // Color backgroundColor() => const Color(0x00000000);

  List<int> buildingsID = [];
  List<int> buildingsBlockID = [];
  //* store id
  List<int> selectedBuildingID = [];

  late TargetList targetList;
  late MapEntity mapEntity;

  @override
  FutureOr<void> onLoad() async {
    //!!! run as debug mode
    // debugMode = true;

    generateRandomBuilding();
    selectBuilding();

    targetList = TargetList(targetsID: selectedBuildingID);

    mapEntity = MapEntity(
      size: Vector2(size.x - size.y * 215 / 720, size.y),
      position: Vector2(size.x - (size.x - size.y * 215 / 720) / 2, size.y / 2),
      anchor: Anchor.center,
    );

    await addAll([
      targetList,
      mapEntity,
    ]);
    Logger().d('load complete');
  }

  void generateRandomBuilding() {
    buildingsID.clear();
    // while (buildingsID.length < Globals.numberOfBuildings[1]!) {
    //   int newBuildingID = Random().nextInt(40) + 1;
    //   if (!buildingsID.contains(newBuildingID)) {
    //     buildingsID.add(newBuildingID);
    //   }
    // }
    // buildingsBlockID.clear();
    // while (buildingsBlockID.length < Globals.numberOfBuildings[1]!) {
    //   int newId = Random().nextInt(9);
    //   if (!buildingsBlockID.contains(newId)) {
    //     buildingsBlockID.add(newId);
    //   }
    // }
  }

  void selectBuilding() {
    List<int> randomBuildingList = buildingsID;
    randomBuildingList.shuffle();
    // selectedBuildingID =
    // randomBuildingList.sublist(0, Globals.numberOfTargets[1]!);
  }

  void removeBuildings(int id) {
    if (selectedBuildingID.contains(id)) {
      selectedBuildingID.remove(id);
      remove(targetList);
      targetList = TargetList(targetsID: selectedBuildingID);
      add(targetList);
    }
  }

  void resetGame() {
    removeAll([
      targetList,
      mapEntity,
    ]);

    generateRandomBuilding();
    selectBuilding();

    targetList = TargetList(targetsID: selectedBuildingID);

    mapEntity = MapEntity(
      size: Vector2(size.x - size.y * 215 / 720, size.y),
      position: Vector2(size.x - (size.x - size.y * 215 / 720) / 2, size.y / 2),
      anchor: Anchor.center,
    );

    addAll([
      targetList,
      mapEntity,
    ]);
  }
}
