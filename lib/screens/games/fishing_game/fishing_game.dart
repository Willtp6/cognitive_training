import 'dart:math';

class FishingRod {
  String? type;
  String? rank;
  int? id;
}

class FishingGame {
  int gameLevel;
  bool isTutorial;
  List<FishingRod> rodList;
  FishingGame({required this.gameLevel, required this.isTutorial})
      : rodList = List.generate(numOfRods[gameLevel], (_) => FishingRod());

  bool startFishing = false;
  bool endFishing = false;

  late List<int> remainingRepeatedTime;

  late int rodWithFish;

  late DateTime start;
  late DateTime end;

  void checkRodList() {
    //* check if any rods doesn't have fishing rod instance
    while (rodList.length < getNumOfRods()) {
      rodList.add(FishingRod());
    }
  }

  void setGame() {
    //* check if every rod have an instance
    checkRodList();
    //* randomly set the correct rod
    rodWithFish = Random().nextInt(getNumOfRods());
    //* set fish and garbage to rod
    for (int i = 0; i < getNumOfRods(); i++) {
      if (i == rodWithFish) {
        rodList[i].type = 'fish';
        int numOfType = possibleFishType[gameLevel].length;
        rodList[i].rank =
            possibleFishType[gameLevel][Random().nextInt(numOfType)];
        rodList[i].id =
            Random().nextInt(possibleFishNumber[rodList[i].rank]!) + 1;
      } else {
        rodList[i].type = 'garbage';
        rodList[i].id = Random().nextInt(possibleGarbageNumber) + 1;
      }
    }
    //* reset remain repeated time list
    switch (gameLevel) {
      case 0:
      case 1:
        break;
      case 2:
        remainingRepeatedTime = List.generate(3, (_) => 2);
        break;
      case 3:
        remainingRepeatedTime = List.generate(4, (_) => 2);
        break;
      case 4:
        remainingRepeatedTime = List.generate(4, (_) => 1);
        break;
    }
  }

  int getNumOfRods() {
    return numOfRods[gameLevel];
  }
}

const List<int> numOfRods = [2, 3, 3, 4, 4];

const Map<String, int> possibleFishNumber = {'C': 8, 'B': 7, 'A': 7};

const List<List<String>> possibleFishType = [
  ['C'],
  ['B', 'C'],
  ['B'],
  ['A', 'B'],
  ['A', 'B']
];

const int possibleGarbageNumber = 26;
