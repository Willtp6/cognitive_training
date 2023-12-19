class LotteryGameDatabase {
  int currentLevel;
  int currentDigit;
  int continuousCorrectRateBiggerThan50;
  int loseInCurrentDigit;
  int historyContinuousWin;
  int historyContinuousLose;
  bool doneTutorial;
  LotteryGameDatabase({
    required this.currentLevel,
    required this.currentDigit,
    required this.continuousCorrectRateBiggerThan50,
    required this.loseInCurrentDigit,
    required this.historyContinuousWin,
    required this.historyContinuousLose,
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

class RankingUser {
  String username;
  String userid;
  int ownedCoins;
  RankingUser({
    this.username = '未找到玩家',
    this.userid = 'usernotfound',
    this.ownedCoins = 0,
  });
}
