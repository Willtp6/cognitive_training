import 'dart:math';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/models/map_info.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import '../models/building.dart';
import 'street_block.dart';

import '../models/building_info.dart';
import 'building_component.dart';

class MapEntity extends RectangleComponent
    with HasGameRef<RoutePlanningGameForge2d> {
  MapEntity({
    required super.position,
    required super.size,
    required super.anchor,
    super.paint,
  }) : super(priority: 1);

  Map<String, int> positionPriority = {
    "up": 0,
    "left": 1,
    "right": 1,
    "down": 2,
  };

  late final double mapWidth;
  late final double mapHeight;
  late final MapInfo mapInfo;

  List<StreetBlock> blocks = [];
  List<BuildingComponent> buildingComponents = [];
  late BuildingComponent homeComponent;
  List<List<Building>> buildingInBlock = [];

  @override
  Future<void> onLoad() async {
    //* define the basic properties of the map
    //* use these to construct the map
    mapWidth = size.x - size.y * 215 / 720;
    mapHeight = size.y;
    paint = BasicPalette.white.withAlpha(0).paint();
    mapInfo = MapInfo(mapWidth: mapWidth, mapHeight: mapHeight);

    return super.onLoad();
  }

  /// generate the map
  Future<void> addBlocks({required int mapIndex}) async {
    blocks.clear();
    for (int i = 0; i < mapInfo.mapVectors[gameRef.chosenMap].length; i++) {
      blocks.add(StreetBlock(
        vertices: mapInfo.mapVectors[gameRef.chosenMap][i],
        position: plusOffset(mapInfo.blockStartPosition[gameRef.chosenMap][i]),
      ));
    }
    await addAll(blocks);
  }

  void removeBlocks() {
    removeAll(blocks);
  }

  /// this function will take building list as input that need to put to map
  Future<void> addBuildings({required List<Building> buildings}) async {
    buildingComponents.clear();

    List<int> buildingInBlocks =
        List.generate(mapInfo.buildingInfo[gameRef.chosenMap].length, (_) => 0);

    homeComponent = BuildingComponent(
      isHome: true,
      building: Building(id: -1, isTarget: false),
      buildingSize: Vector2.all(mapInfo.buildingSize),
      buildingPosition:
          mapInfo.homePosition[gameRef.chosenMap].buildingPosition +
              plusOffset(mapInfo.blockStartPosition[gameRef.chosenMap]
                  [MapInfo.homeBlock[gameRef.chosenMap]]),
      bodyAngle: mapInfo.homePosition[gameRef.chosenMap].bodyAngle,
      flagDirection: mapInfo.homePosition[gameRef.chosenMap].direction,
    );

    //* add home
    buildingComponents.add(homeComponent);

    //* random spread the buildings to all blocks
    buildingInBlock =
        List.generate(mapInfo.mapVectors[gameRef.chosenMap].length, (_) => []);

    int index = 0;
    while (index < buildings.length) {
      int blockToAdd =
          Random().nextInt(mapInfo.mapVectors[gameRef.chosenMap].length);
      //* add this to force not to add new blocks to block which have home
      if (blockToAdd == MapInfo.homeBlock[gameRef.chosenMap]) continue;
      //* check if the block to add new building have enough space
      if (buildingInBlock[blockToAdd].length <
          mapInfo.buildingInfo[gameRef.chosenMap][blockToAdd].length) {
        buildingInBlock[blockToAdd].add(buildings[index]);
        index++;
      } else {
        continue;
      }
    }
    //* for every block
    for (int blockId = 0; blockId < blocks.length; blockId++) {
      //* randomly pick position in the block
      List<BuildingInfo> pickedPosition =
          mapInfo.buildingInfo[gameRef.chosenMap][blockId]..shuffle();
      pickedPosition =
          pickedPosition.sublist(0, buildingInBlock[blockId].length);

      //* all building in block
      for (int index = 0; index < buildingInBlock[blockId].length; index++) {
        buildingComponents.add(
          BuildingComponent(
            building: buildingInBlock[blockId][index],
            buildingSize: Vector2.all(mapInfo.buildingSize),
            buildingPosition: pickedPosition[index].buildingPosition +
                plusOffset(
                    mapInfo.blockStartPosition[gameRef.chosenMap][blockId]),
            bodyAngle: pickedPosition[index].bodyAngle,
            flagDirection: pickedPosition[index].direction,
          ),
        );
      }
    }

    //* sort the position by the priority of image layer
    buildingComponents.sort((a, b) => positionPriority[a.flagDirection]!
        .compareTo(positionPriority[b.flagDirection]!));
    buildingComponents
        .sort((a, b) => a.buildingPosition.y.compareTo(b.buildingPosition.y));
    addAll(buildingComponents);
  }

  void removeBuildings() {
    removeAll(buildingComponents);
  }

  /// because the map is start from 0, 0
  /// if not the physical body and render body will have a offset
  /// to avoid this situation make the map start from 0, 0
  /// and all of the blocks add a offset to get correcct position
  Vector2 plusOffset(Vector2 original) {
    return original + Vector2(215 / 720 * mapHeight, 0);
  }
}
