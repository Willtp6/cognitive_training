import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {}

class LotteryGameDatabase {
  int currentLevel;
  int historyContinuousWin;
  int historyContinuousLose;
  int currentDigit;
  bool doneTutorial;
  LotteryGameDatabase({
    required this.currentLevel,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.currentDigit,
    required this.doneTutorial,
  });
}

class PokerGameDatabase {
  int currentLevel;
  int historyContinuousWin;
  int historyContinuousLose;
  bool doneTutorial;
  List<int> responseTimeList;
  PokerGameDatabase({
    required this.currentLevel,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.doneTutorial,
    required this.responseTimeList,
  });
}

class FishingGameDatabase {
  int currentLevel;
  int historyContinuousWin;
  int historyContinuousLose;
  bool doneTutorial;

  FishingGameDatabase({
    required this.currentLevel,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.doneTutorial,
  });
}

class RoutePlanningGameDatabase {
  int currentLevel;
  int historyContinuousWin;
  int historyContinuousLose;
  bool doneTutorial;
  List<int> responseTimeList;
  RoutePlanningGameDatabase({
    required this.currentLevel,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
    required this.doneTutorial,
    required this.responseTimeList,
  });
}
