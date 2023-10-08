import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'building_info.dart';

class MapInfo {
  final double mapWidth;
  final double mapHeight;
  late final double roadWidth2Roads;
  late final double roadWidth3Roads;
  late final double streetBlockHeight2Roads;
  late final double streetBlockHeight3Roads;
  late final double streetBlockWidth22Roads;
  late final double streetBlockWidth23Roads;
  late final double streetBlockWidth33Roads;
  late final double streetBlockWidth32Roads;
  late final double buildingSize;

  MapInfo({required this.mapWidth, required this.mapHeight}) {
    roadWidth2Roads = mapHeight * 2 / 13;
    roadWidth3Roads = mapHeight * 2 / 18;

    streetBlockHeight2Roads = mapHeight * 3 / 13;
    streetBlockHeight3Roads = mapHeight * 3 / 18;
    streetBlockWidth22Roads = (mapWidth - 2 * roadWidth2Roads) / 3;
    streetBlockWidth23Roads = (mapWidth - 3 * roadWidth2Roads) / 4;
    streetBlockWidth33Roads = (mapWidth - 3 * roadWidth3Roads) / 4;
    streetBlockWidth32Roads = (mapWidth - 2 * roadWidth3Roads) / 3;

    buildingSize = streetBlockHeight2Roads / 2;
  }

  late final List<double> buildingSizeList = [
    streetBlockHeight2Roads / 2,
    streetBlockHeight2Roads / 2,
    streetBlockHeight2Roads / 2,
    streetBlockHeight3Roads / 2,
    streetBlockHeight3Roads / 2,
    streetBlockHeight3Roads / 2,
    streetBlockHeight3Roads / 2,
    streetBlockHeight3Roads / 2,
    streetBlockHeight2Roads / 2,
    streetBlockHeight3Roads / 2,
  ];

  //* blocks vector which represent by relative
  late List<List<List<Vector2>>> mapVectors = [
    //* map 1
    List.generate(
      9,
      (_) => [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth22Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth22Roads, 0),
      ],
    ),
    //* map 2
    List.generate(
      12,
      (_) => [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
    ),
    //* map 3
    [
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads * 2 + roadWidth2Roads),
        Vector2(streetBlockWidth23Roads,
            streetBlockHeight2Roads * 2 + roadWidth2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads,
            streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads, 0),
      ],
      [
        Vector2(0, 0),
        Vector2(0, streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads,
            streetBlockHeight2Roads),
        Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads, 0),
      ],
    ],
    //* map 4
    [
      [
        Vector2(0, 0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6, streetBlockHeight3Roads),
        Vector2(0, streetBlockHeight3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6,
            streetBlockHeight3Roads * 2 + roadWidth3Roads),
        Vector2(0, streetBlockHeight3Roads * 2 + roadWidth3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth32Roads * 1.8, 0),
        Vector2(
            streetBlockWidth32Roads * 1.8, streetBlockHeight3Roads * 14 / 9),
        Vector2(0, streetBlockHeight3Roads * 14 / 9),
      ],
      [
        Vector2(0, 0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6, streetBlockHeight3Roads),
        Vector2(0, streetBlockHeight3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth32Roads * 1.8, 0),
        Vector2(
            streetBlockWidth32Roads * 1.8, streetBlockHeight3Roads * 14 / 9),
        Vector2(0, streetBlockHeight3Roads * 14 / 9),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6,
            streetBlockHeight3Roads * 2 + roadWidth3Roads),
        Vector2(0, streetBlockHeight3Roads * 2 + roadWidth3Roads),
      ],
      [
        Vector2(0, 0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6, streetBlockHeight3Roads),
        Vector2(0, streetBlockHeight3Roads),
      ],
      [
        Vector2(0, 0),
        Vector2(streetBlockWidth32Roads * 0.6, 0),
        Vector2(streetBlockWidth32Roads * 0.6, streetBlockHeight3Roads),
        Vector2(0, streetBlockHeight3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth32Roads * 1.8, 0),
        Vector2(
            streetBlockWidth32Roads * 1.8, streetBlockHeight3Roads * 14 / 9),
        Vector2(0, streetBlockHeight3Roads * 14 / 9),
      ],
    ],
    //* map 5
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads,
            streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads),
        Vector2(0, streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 2, 0),
        Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 2,
            streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
    ],
    //* map 6
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads,
            streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads),
        Vector2(0, streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2, 0),
        Vector2(streetBlockWidth33Roads * 2, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
    ],
    //* map 7
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads - roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads - roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 15),
        Vector2(0, streetBlockHeight3Roads * 12 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 15),
        Vector2(0, streetBlockHeight3Roads * 12 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2, 0),
        Vector2(streetBlockWidth33Roads * 2, streetBlockHeight3Roads * 12 / 15),
        Vector2(0, streetBlockHeight3Roads * 12 / 15),
      ],
    ],
    //* map 8
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(
            streetBlockWidth33Roads,
            streetBlockHeight3Roads * 12 / 14 +
                streetBlockHeight3Roads * 16 / 14 +
                roadWidth3Roads),
        Vector2(
            0,
            streetBlockHeight3Roads * 12 / 14 +
                streetBlockHeight3Roads * 16 / 14 +
                roadWidth3Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 14),
        Vector2(0, streetBlockHeight3Roads * 16 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 2, 0),
        Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 2,
            streetBlockHeight3Roads * 12 / 14),
        Vector2(0, streetBlockHeight3Roads * 12 / 14),
      ],
    ],
    //* map 9
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads, 0),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads, 0),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads, 0),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads, 0),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 1.5 + roadWidth2Roads, 0),
        Vector2(streetBlockWidth23Roads * 1.5 + roadWidth2Roads,
            streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 1.5, 0),
        Vector2(streetBlockWidth23Roads * 1.5, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads, 0),
        Vector2(streetBlockWidth23Roads, streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads, 0),
        Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads * 0.5,
            streetBlockHeight2Roads),
        Vector2(0, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 0.75, 0),
        Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads * 0.5,
            streetBlockHeight2Roads),
        Vector2(-roadWidth2Roads * 0.5, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads, 0),
        Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads * 0.5,
            streetBlockHeight2Roads),
        Vector2(roadWidth2Roads * 0.5, streetBlockHeight2Roads),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth23Roads * 1.75 - roadWidth2Roads * 2, 0),
        Vector2(streetBlockWidth23Roads * 1.75 - roadWidth2Roads * 2,
            streetBlockHeight2Roads),
        Vector2(-roadWidth2Roads * 0.5, streetBlockHeight2Roads),
      ],
    ],
    //* map 10
    [
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads * 0.5, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 0.5, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 0.5,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(roadWidth3Roads * 0.5, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads + roadWidth3Roads,
            streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2, 0),
        Vector2(streetBlockWidth33Roads * 2, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads, 0),
        Vector2(streetBlockWidth33Roads, streetBlockHeight3Roads * 16 / 15),
        Vector2(0, streetBlockHeight3Roads * 16 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 15),
        Vector2(0, streetBlockHeight3Roads * 12 / 15),
      ],
      [
        Vector2.all(0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads, 0),
        Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads,
            streetBlockHeight3Roads * 12 / 15),
        Vector2(0, streetBlockHeight3Roads * 12 / 15),
      ],
    ],
  ];

  // * list of topleft point of blocks
  late List<List<Vector2>> blockStartPosition = [
    //* map 1
    [
      Vector2.all(0),
      Vector2(roadWidth2Roads + streetBlockWidth22Roads, 0),
      Vector2(2 * roadWidth2Roads + 2 * streetBlockWidth22Roads, 0),
      Vector2(0, roadWidth2Roads + streetBlockHeight2Roads),
      Vector2(roadWidth2Roads + streetBlockWidth22Roads,
          roadWidth2Roads + streetBlockHeight2Roads),
      Vector2(2 * roadWidth2Roads + 2 * streetBlockWidth22Roads,
          roadWidth2Roads + streetBlockHeight2Roads),
      Vector2(0, 2 * roadWidth2Roads + 2 * streetBlockHeight2Roads),
      Vector2(roadWidth2Roads + streetBlockWidth22Roads,
          2 * roadWidth2Roads + 2 * streetBlockHeight2Roads),
      Vector2(2 * roadWidth2Roads + 2 * streetBlockWidth22Roads,
          2 * roadWidth2Roads + 2 * streetBlockHeight2Roads)
    ],
    //* map 2
    [
      Vector2.all(0),
      Vector2(roadWidth2Roads + streetBlockWidth23Roads, 0),
      Vector2(roadWidth2Roads * 2 + streetBlockWidth23Roads * 2, 0),
      Vector2(roadWidth2Roads * 3 + streetBlockWidth23Roads * 3, 0),
      //
      Vector2(0, streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(roadWidth2Roads + streetBlockWidth23Roads,
          streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(roadWidth2Roads * 2 + streetBlockWidth23Roads * 2,
          streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(roadWidth2Roads * 3 + streetBlockWidth23Roads * 3,
          streetBlockHeight2Roads + roadWidth2Roads),
      //
      Vector2(0, streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(roadWidth2Roads + streetBlockWidth23Roads,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(roadWidth2Roads * 2 + streetBlockWidth23Roads * 2,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(roadWidth2Roads * 3 + streetBlockWidth23Roads * 3,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      //
      Vector2(0, streetBlockHeight2Roads * 3 + roadWidth2Roads * 3),
      Vector2(roadWidth2Roads + streetBlockWidth23Roads,
          streetBlockHeight2Roads * 3 + roadWidth2Roads * 3),
      Vector2(roadWidth2Roads * 2 + streetBlockWidth23Roads * 2,
          streetBlockHeight2Roads * 3 + roadWidth2Roads * 3),
      Vector2(roadWidth2Roads * 3 + streetBlockWidth23Roads * 3,
          streetBlockHeight2Roads * 3 + roadWidth3Roads * 3),
    ],
    //* map 3
    [
      Vector2.all(0),
      Vector2(streetBlockWidth23Roads + roadWidth2Roads, 0),
      Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads * 2, 0),
      Vector2(streetBlockWidth23Roads * 3 + roadWidth2Roads * 3, 0),
      Vector2(0, streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads * 2,
          streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(0, streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(streetBlockWidth23Roads + roadWidth2Roads,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads * 2,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
    ],
    //* map 4
    [
      Vector2.all(0),
      Vector2(streetBlockWidth32Roads * 0.6 + roadWidth3Roads, 0),
      Vector2(streetBlockWidth32Roads * 0.6 * 2 + roadWidth3Roads * 2, 0),
      Vector2(0, streetBlockHeight3Roads + roadWidth3Roads),
      Vector2(streetBlockWidth32Roads * 0.6 * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 14 / 9 + roadWidth3Roads),
      Vector2(0, streetBlockHeight3Roads * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth32Roads * 0.6 + roadWidth3Roads,
          streetBlockHeight3Roads * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth32Roads * 0.6 + roadWidth3Roads,
          streetBlockHeight3Roads * 3 + roadWidth3Roads * 3),
      Vector2(streetBlockWidth32Roads * 0.6 * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 14 / 9 * 2 + roadWidth3Roads * 2),
    ],
    //* map 5
    [
      Vector2.all(0),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3, 0),
      Vector2(0, streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(0,
          streetBlockHeight3Roads * (12 / 14 + 16 / 14) + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * (12 / 14 + 16 / 14) + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * (12 / 14 + 16 / 14) + roadWidth3Roads * 2),
      Vector2(
          0,
          streetBlockHeight3Roads * (12 / 14 + 16 / 14 * 2) +
              roadWidth3Roads * 3),
      Vector2(
          streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * (12 / 14 + 16 / 14 * 2) +
              roadWidth3Roads * 3)
    ],
    //* map 6
    [
      Vector2.all(0),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2, 0),
      Vector2(0, streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(
          streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 +
              roadWidth3Roads * 2),
      Vector2(
          streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 +
              roadWidth3Roads * 2),
      Vector2(
          0,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 * 2 +
              roadWidth3Roads * 3),
      Vector2(
          streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 * 2 +
              roadWidth3Roads * 3),
      Vector2(
          streetBlockWidth33Roads * 2 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 * 2 +
              roadWidth3Roads * 3),
    ],
    //* map 7
    [
      Vector2.all(0),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2, 0),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3, 0),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 4,
          streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 * 3 + roadWidth3Roads * 3),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 16 / 15 * 3 + roadWidth3Roads * 3),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 16 / 15 * 3 + roadWidth3Roads * 3),
    ],
    //* map 8
    [
      Vector2.all(0),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads, 0),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2, 0),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3, 0),
      Vector2(0, streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 12 / 14 + roadWidth3Roads),
      Vector2(
          0,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 +
              roadWidth3Roads * 2),
      Vector2(
          streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 +
              roadWidth3Roads * 2),
      Vector2(
          streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 +
              roadWidth3Roads * 2),
      Vector2(
          0,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 * 2 +
              roadWidth3Roads * 3),
      Vector2(
          streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 12 / 14 +
              streetBlockHeight3Roads * 16 / 14 * 2 +
              roadWidth3Roads * 3),
    ],
    //* map 9
    [
      Vector2.all(0),
      Vector2(streetBlockWidth23Roads + roadWidth2Roads, 0),
      Vector2(streetBlockWidth23Roads * 2 + roadWidth2Roads * 2, 0),
      Vector2(streetBlockWidth23Roads * 3 + roadWidth2Roads * 3, 0),
      Vector2(0, streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(streetBlockWidth23Roads * 1.5 + roadWidth2Roads * 2,
          streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(streetBlockWidth23Roads * 3 + roadWidth2Roads * 3,
          streetBlockHeight2Roads + roadWidth2Roads),
      Vector2(0, streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(streetBlockWidth23Roads * 0.75 + roadWidth2Roads * 2,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(streetBlockWidth23Roads * 0.75 * 2 + roadWidth2Roads * 3,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
      Vector2(streetBlockWidth23Roads * 0.75 * 3 + roadWidth2Roads * 5,
          streetBlockHeight2Roads * 2 + roadWidth2Roads * 2),
    ],
    //* map 10
    [
      Vector2.all(0),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads * 1.5, 0),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3, 0),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 16 / 15 + roadWidth3Roads),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads + roadWidth3Roads,
          streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(streetBlockWidth33Roads * 3 + roadWidth3Roads * 3,
          streetBlockHeight3Roads * 16 / 15 * 2 + roadWidth3Roads * 2),
      Vector2(0, streetBlockHeight3Roads * 16 / 15 * 3 + roadWidth3Roads * 3),
      Vector2(streetBlockWidth33Roads * 2 + roadWidth3Roads * 2,
          streetBlockHeight3Roads * 16 / 15 * 3 + roadWidth3Roads * 3),
    ],
  ];

  late List<List<List<BuildingInfo>>> buildingInfo = [
    //* map 1
    [
      //* block 1
      [
        BuildingInfo(
            buildingPosition: Vector2(
                streetBlockWidth22Roads - buildingSize / 2,
                streetBlockHeight2Roads / 2),
            direction: "right"), //* right
        BuildingInfo(
            buildingPosition: Vector2(streetBlockWidth22Roads / 2,
                streetBlockHeight2Roads - buildingSize / 2),
            direction: "down"), //* down
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
            direction: "left"), //* left
        BuildingInfo(
            buildingPosition: Vector2(
                streetBlockWidth22Roads - buildingSize / 2,
                streetBlockHeight2Roads / 2),
            direction: "right") //* right
      ],
      [
        BuildingInfo(
            buildingPosition: Vector2(streetBlockWidth22Roads / 2,
                streetBlockHeight2Roads - buildingSize / 2),
            direction: "down"), //* down
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(streetBlockWidth22Roads / 2, buildingSize / 2),
            direction: "up"), //* up
        BuildingInfo(
            buildingPosition: Vector2(
                streetBlockWidth22Roads - buildingSize / 2,
                streetBlockHeight2Roads / 2),
            direction: "right") //* right
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(streetBlockWidth22Roads / 2, buildingSize / 2),
            direction: "up"), //* up
        BuildingInfo(
            buildingPosition:
                Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
            direction: "left"), //* left
        BuildingInfo(
            buildingPosition: Vector2(
                streetBlockWidth22Roads - buildingSize / 2,
                streetBlockHeight2Roads / 2),
            direction: "right") //* right
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(streetBlockWidth22Roads / 2, buildingSize / 2),
            direction: "up"), //* up
        BuildingInfo(
            buildingPosition: Vector2(streetBlockWidth22Roads / 2,
                streetBlockHeight2Roads - buildingSize / 2),
            direction: "down"), //* down
      ],
      [
        BuildingInfo(
            buildingPosition: Vector2(
                streetBlockWidth22Roads - buildingSize / 2,
                streetBlockHeight2Roads / 2),
            direction: "right") //* right
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(streetBlockWidth22Roads / 2, buildingSize / 2),
            direction: "up"), //* up
        BuildingInfo(
            buildingPosition:
                Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
            direction: "left"), //* left
      ],
      [
        BuildingInfo(
            buildingPosition:
                Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
            direction: "left"), //* left
      ],
    ],
    //* map 2
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
      ],
    ],
    //* map 3
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              (streetBlockHeight2Roads * 2 + roadWidth2Roads) / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads / 2,
              (streetBlockHeight2Roads * 2 + roadWidth2Roads) -
                  buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 2 + roadWidth2Roads) / 2,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 2 + roadWidth2Roads) -
                  buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 2 + roadWidth2Roads) / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 2 + roadWidth2Roads) / 2,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
      ],
    ],
    //* map 4
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2, streetBlockHeight3Roads - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 2 + roadWidth3Roads - buildingSize),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads * 2 + roadWidth3Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 4 / 3 / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.9 - buildingSize / 2,
              streetBlockHeight3Roads * 14 / 9 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 1.5 - buildingSize / 2,
              streetBlockHeight3Roads * 14 / 9 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 14 / 9 / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth32Roads * 1.8 / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 1.8 - buildingSize / 2,
              streetBlockHeight3Roads * 14 / 9 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              (streetBlockHeight3Roads * 2 + roadWidth3Roads) * 0.6 -
                  buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads * 2 + roadWidth3Roads - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth32Roads * 0.6 - buildingSize / 2,
              streetBlockHeight3Roads - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth32Roads * 0.6 / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth32Roads * 1.8 / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
    ],
    //* map 5
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth32Roads / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 + roadWidth3Roads - buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 * 1.5 +
                  roadWidth3Roads -
                  buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 * 2 +
                  roadWidth3Roads -
                  buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 3 + roadWidth3Roads * 2) * 0.4,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
            (streetBlockWidth33Roads * 3 + roadWidth3Roads * 2) * 0.8,
            buildingSize / 2,
          ),
          direction: "up",
        ),
      ],
    ],
    //* map 6
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 0.4,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 0.8,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              (streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads) / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads / 2,
              (streetBlockHeight3Roads * 16 / 14 * 2 + roadWidth3Roads) -
                  buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads + roadWidth3Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "left",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 16 / 14 / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads + roadWidth3Roads, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) - buildingSize,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "left",
        ),
      ],
      [],
    ],
    //* map 7
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 0.33,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 0.66,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 + roadWidth3Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads + roadWidth3Roads) / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads + roadWidth3Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) / 3,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 2 / 3,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 + roadWidth3Roads - buildingSize / 2,
              buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 12 / 15 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads + roadWidth3Roads - buildingSize / 2,
              buildingSize / 2),
          direction: "up",
        ),
      ],
      [],
    ],
    //* map 8
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2,
              (streetBlockHeight3Roads * 2 + roadWidth3Roads) / 2 -
                  buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads + roadWidth3Roads + buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2,
              (streetBlockHeight3Roads * 2 + roadWidth3Roads) -
                  buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 12 / 14 / 2),
          direction: "left",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) / 3,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 2 / 3,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 + roadWidth3Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 14 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 3 + roadWidth3Roads * 2) / 2,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 3 +
                  roadWidth3Roads * 2 -
                  buildingSize / 2,
              buildingSize / 2),
          direction: "up",
        ),
      ],
    ],
    //* map 9
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2, streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockWidth23Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2, streetBlockHeight2Roads - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 1.5 + roadWidth2Roads) / 3,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth23Roads * 1.5 + roadWidth2Roads) * 2 / 3,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads * 1.5 +
                  roadWidth2Roads -
                  buildingSize / 2,
              streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              buildingSize / 2, streetBlockHeight2Roads - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads * 1.5 - buildingSize / 2,
              buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight2Roads / 2),
          direction: "left",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads * 0.75 +
                  roadWidth2Roads -
                  buildingSize / 2 -
                  buildingSize / 2 / 3,
              buildingSize / 2),
          direction: "right",
        ),
        //* although divide 3 by height can get the correct offset about x
        //* but the size is too small for contact (thus divide 4)
        BuildingInfo(
          buildingPosition: Vector2(
            streetBlockWidth23Roads +
                roadWidth2Roads * 0.5 -
                buildingSize / 2 -
                (streetBlockHeight2Roads - buildingSize / 2) / 4,
            streetBlockHeight2Roads - buildingSize / 2,
          ),
          direction: "right",
          bodyAngle: asin(1 / 3),
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(0, streetBlockHeight2Roads * 0.75),
          direction: "left",
          bodyAngle: asin(1 / 3),
        ),
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth23Roads * 0.75 / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads * 0.75, streetBlockHeight2Roads * 0.75),
          direction: "right",
          bodyAngle: -asin(1 / 3),
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockHeight2Roads / 2 / 3 + buildingSize / 2,
              streetBlockHeight2Roads / 2),
          direction: "left",
          bodyAngle: -asin(1 / 3),
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth23Roads * 0.75 +
                  roadWidth2Roads -
                  buildingSize / 2 / 3 -
                  buildingSize / 2,
              buildingSize / 2),
          direction: "up",
        ),
      ],
      [],
    ],
    //* map 10
    [
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads + roadWidth3Roads * 0.25,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
          bodyAngle: -asin(1 / 3),
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(roadWidth3Roads * 0.25 + buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "left",
          bodyAngle: -asin(1 / 3),
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              roadWidth3Roads * 0.5 + streetBlockWidth33Roads,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 +
                  roadWidth3Roads * 0.5 -
                  buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads + roadWidth3Roads) / 2,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads + roadWidth3Roads) - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2((streetBlockWidth33Roads * 2) / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads * 2 - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition:
              Vector2(buildingSize / 2, streetBlockHeight3Roads * 16 / 15 / 2),
          direction: "left",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(streetBlockWidth33Roads - buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "down",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(buildingSize / 2,
              streetBlockHeight3Roads * 16 / 15 - buildingSize / 2),
          direction: "left",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              streetBlockWidth33Roads - buildingSize / 2, buildingSize / 2),
          direction: "right",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition:
              Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) / 3,
              buildingSize / 2),
          direction: "up",
        ),
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) * 2 / 3,
              buildingSize / 2),
          direction: "up",
        ),
      ],
      [
        BuildingInfo(
          buildingPosition: Vector2(
              (streetBlockWidth33Roads * 2 + roadWidth3Roads) / 3,
              buildingSize / 2),
          direction: "up",
        ),
      ],
    ],
  ];

  static const List<int> homeBlock = [6, 8, 7, 8, 1, 11, 12, 10, 10, 11];

  late List<BuildingInfo> homePosition = [
    BuildingInfo(
        buildingPosition:
            Vector2(streetBlockWidth22Roads / 2, buildingSize / 2),
        direction: "up"),
    BuildingInfo(
        buildingPosition: Vector2(streetBlockWidth23Roads - buildingSize / 2,
            streetBlockHeight2Roads / 2),
        direction: "right"),
    BuildingInfo(
        buildingPosition:
            Vector2(streetBlockWidth23Roads / 2, buildingSize / 2),
        direction: "up"),
    BuildingInfo(
      buildingPosition:
          Vector2(buildingSize / 2, streetBlockHeight3Roads * 4 / 3 / 2),
      direction: "left",
    ),
    BuildingInfo(
      buildingPosition: Vector2(buildingSize / 2,
          streetBlockHeight3Roads * 12 / 14 - buildingSize / 2),
      direction: "left",
    ),
    BuildingInfo(
      buildingPosition: Vector2(streetBlockWidth33Roads, buildingSize / 2),
      direction: "up",
    ),
    BuildingInfo(
      buildingPosition: Vector2(buildingSize / 2, buildingSize / 2),
      direction: "up",
    ),
    BuildingInfo(
      buildingPosition: Vector2(streetBlockWidth33Roads / 2, buildingSize / 2),
      direction: "up",
    ),
    BuildingInfo(
      buildingPosition: Vector2(
          -streetBlockHeight2Roads / 2 / 3 + buildingSize / 2,
          streetBlockHeight2Roads / 2),
      direction: "left",
      bodyAngle: asin(1 / 3),
    ),
    BuildingInfo(
      buildingPosition: Vector2(
          streetBlockWidth33Roads * 1.5 + roadWidth3Roads, buildingSize / 2),
      direction: "up",
    ),
  ];
}
