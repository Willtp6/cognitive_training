import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {}

class LotteryGameDatabase {
  int currentLevel;
  int currentDigit;
  bool doneTutorial;
  LotteryGameDatabase({
    required this.currentLevel,
    required this.currentDigit,
    required this.doneTutorial,
  });
}

class PokerGameDatabase {
  int currentLevel;
  bool doneTutorial;
  List<int> responseTimeList;
  PokerGameDatabase({
    required this.currentLevel,
    required this.doneTutorial,
    required this.responseTimeList,
  });
}
