import 'dart:math';
import 'package:cognitive_training/constants/lottery_game_const.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:logger/logger.dart';

class LotteryGame {
  int gameLevel;
  int numberOfDigits;
  bool isTutorial;
  int loseInCurrentDigit;
  int continuousCorrectRateBiggerThan50;
  int continuousWin;
  int continuousLose;

  LotteryGame({
    this.gameLevel = 0,
    this.numberOfDigits = 2,
    this.continuousCorrectRateBiggerThan50 = 0,
    this.loseInCurrentDigit = 0,
    this.continuousWin = 0,
    this.continuousLose = 0,
    this.isTutorial = true,
  });

  late List<int> numArray;
  late List<int> userArray;

  final List<String> imagePath = [
    LotteryGameConst.insideTempleBackground,
    LotteryGameConst.insideTempleBackground,
    LotteryGameConst.markLotteryBackground,
    LotteryGameConst.buyLotteryBackground,
    LotteryGameConst.waitingResultBackground
  ];
  final String formPath = LotteryGameConst.formBackground;
  final String imagePathWin = LotteryGameConst.winBackground;
  final String imagePathLose = LotteryGameConst.loseBackground;
  String rewardImagePath = '';

  int gameProgress = 0;
  bool playerWin = false;
  bool disableButton = false;
  bool isCaseFunctioned = false;
  int numOfChosen = 0;
  int currentIndex = 0;

  int specialRules = 0;
  String showNumber = '';
  int numOfCorrectAns = 0;
  String currentImagePath = LotteryGameConst.insideTempleBackground;
  List<int> coinReward = [200, 400, 800];
  int gameReward = 0;
  double correctRate = 0;
  List<int> maxNumberLength = [4, 5, 7, 7, 7];

  late DateTime start;
  late DateTime end;
  late bool doneTutorial;
  List<bool> isChosen = List.generate(50, (index) => false);

  Map<String, String>? getInstructionAudioPath() {
    if (gameProgress == 2) {
      return LotteryGameConst.gameRuleLevel5Sum;
    } else {
      switch (gameLevel) {
        case 0:
          return LotteryGameConst.gameRuleLevel1;
        case 1:
          return LotteryGameConst.gameRuleLevel2;
        case 2:
          return LotteryGameConst.gameRuleLevel3;
        case 3:
          return LotteryGameConst.gameRuleLevel4;
        case 4:
          switch (specialRules) {
            case 0:
              return LotteryGameConst.gameRuleLevel5Even;
            case 1:
              return LotteryGameConst.gameRuleLevel5Max;
            case 2:
              return LotteryGameConst.gameRuleLevel5Min;
            case 3:
              return LotteryGameConst.gameRuleLevel5Odd;
            default:
              return null;
          }
        default:
          return null;
      }
    }
  }

  void setArrays(int min, int max) {
    Random random = Random();
    Set<int> usedNumbers = {};
    List<int> results = [];
    //* number of odd or even number ahould be in the array
    int numOfEvenOrOdd = 0;

    while (usedNumbers.length < numberOfDigits) {
      int randomNumber = min + random.nextInt(max - min + 1);
      if (!usedNumbers.contains(randomNumber)) {
        //* in level four and case even or odd there should
        //* be at least half of the number belongs to even or odd
        if (gameLevel == 4 &&
            (specialRules == 0 || specialRules == 3) &&
            numOfEvenOrOdd < (numberOfDigits + 1) ~/ 2) {
          switch (specialRules) {
            //* even
            case 0:
              if (randomNumber % 2 != 0) continue;
              numOfEvenOrOdd++;
              break;
            //* odd
            case 3:
              if (randomNumber % 2 != 1) continue;
              numOfEvenOrOdd++;
              break;
          }
        }
        usedNumbers.add(randomNumber);
        results.add(randomNumber);
      }
    }
    numArray = results;
    userArray = List.generate(numberOfDigits, (index) => -1);
    isChosen = List.generate(50, (index) => false);
    numOfChosen = 0;
  }

  void record() {
    // go through the loop
    if (gameLevel < 2) {
      userArray = [];
      for (int i = 1; i < isChosen.length; i++) {
        if (isChosen[i]) userArray.add(i);
      }
    } else {
      userArray.remove(-1);
    }
    RecordGame.recordLotteryGame(
      gameLevel: gameLevel,
      numberOfDigits: numberOfDigits,
      numOfCorrectAns: numOfCorrectAns,
      end: end,
      start: start,
      specialRule: specialRules,
      answer: numArray,
      playerInput: userArray,
    );
  }

  void levelUpgrades() {
    if (gameLevel < 4) {
      numberOfDigits = 2;
      gameLevel++;
    }
  }

  void levelDowngrades() {
    if (gameLevel > 0) {
      gameLevel--;
      numberOfDigits = 2;
    }
  }

  void setGame() {
    // * get special game rule
    if (gameLevel == 4) {
      specialRules = Random().nextInt(4);
    }
  }

  int getNumOfAnsDigits() {
    if (gameLevel == 4 && (specialRules == 0 || specialRules == 3)) {
      return numArray
          .where(
              (element) => specialRules == 0 ? element.isEven : element.isOdd)
          .length;
    } else {
      return numArray.length;
    }
  }

  void getResult() {
    numOfCorrectAns = 0;
    //* default set to number of digits
    int numOfAnsDigits = numberOfDigits;
    switch (gameLevel) {
      case 0:
      case 1:
        for (int i = 0; i < numArray.length; i++) {
          if (isChosen[numArray[i]]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 2:
        for (int i = 0; i < numArray.length; i++) {
          if (numArray[i] == userArray[i]) {
            Logger().i(numArray[i]);
            Logger().i(userArray[i]);
            numOfCorrectAns++;
          }
        }
        break;
      case 3:
        numArray.sort();
        userArray.sort();
        for (int i = 0; i < numArray.length; i++) {
          if (numArray[i] == userArray[i]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 4:
        int sum = 0;
        switch (specialRules) {
          //even
          case 0:
            for (int i = 0; i < numArray.length; i++) {
              if (userArray.contains(numArray[i])) numOfCorrectAns++;
            }
            numOfAnsDigits = getNumOfAnsDigits();
            break;
          //max
          case 1:
            numArray.sort((b, a) => a.compareTo(b));
            sum = numArray[0] + numArray[1];
            if (sum == userArray[0]) numOfCorrectAns = numArray.length;
            //* no need to set ans digit because correct rate is not showed
            break;
          //min
          case 2:
            numArray.sort();
            sum = numArray[0] + numArray[1];
            if (sum == userArray[0]) numOfCorrectAns = numArray.length;
            //* no need to set ans digit because correct rate is not showed
            break;
          //odd
          case 3:
            for (int i = 0; i < numArray.length; i++) {
              if (userArray.contains(numArray[i])) numOfCorrectAns++;
              //* calculate numOfAnsDigits
            }
            numOfAnsDigits = getNumOfAnsDigits();
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }
    //* reward is determined by correct rate
    correctRate = numOfCorrectAns / numOfAnsDigits;
    gameReward = 0;
    if (correctRate > 0 && correctRate <= 0.5) {
      gameReward = coinReward[0];
      rewardImagePath = 'assets/lottery_game_scene/feedback/reward_200.png';
    } else if (correctRate > 0.5 && correctRate <= 0.75) {
      gameReward = coinReward[1];
      rewardImagePath = 'assets/lottery_game_scene/feedback/reward_400.png';
    } else if (correctRate > 0.75 && correctRate <= 1) {
      gameReward = coinReward[2];
      rewardImagePath = 'assets/lottery_game_scene/feedback/reward_800.png';
    }
    playerWin = correctRate != 0.0;
  }

  void changeDigitByResult() {
    if (playerWin) {
      if (numberOfDigits == maxNumberLength[gameLevel]) {
        if (correctRate == 1.0) {
          continuousWin++;
          continuousLose = 0;
          if (continuousWin >= 5) {
            continuousWin = 0;
            levelUpgrades();
          }
        } else {
          continuousLose++;
          continuousWin = 0;
          if (continuousLose >= 5) {
            numberOfDigits--;
            continuousLose = 0;
          }
        }
      } else {
        if (correctRate >= 0.5) {
          continuousCorrectRateBiggerThan50++;
          // *  if correctrate >= 0.5 continuously two times add the digit
          if (continuousCorrectRateBiggerThan50 >= 2) {
            continuousCorrectRateBiggerThan50 = 0;
            numberOfDigits++;
            loseInCurrentDigit = 0;
            // if (numberOfDigits > maxNumberLength[gameLevel]) {
            //   levelUpgrades();
            // }
          }
        } else {
          if (continuousCorrectRateBiggerThan50 > 0) {
            continuousCorrectRateBiggerThan50--;
          }
        }
      }
    } else {
      continuousCorrectRateBiggerThan50 = 0;

      loseInCurrentDigit++;
      if (loseInCurrentDigit >= 5) {
        loseInCurrentDigit = 0;
        if (numberOfDigits > 2) {
          numberOfDigits--;
        } else {
          levelDowngrades();
        }
      }
    }
  }

  void changeCurrentImage() {
    isCaseFunctioned = false;
    gameProgress++;
    currentImagePath = gameProgress < 5
        ? imagePath[gameProgress]
        : playerWin
            ? imagePathWin
            : imagePathLose;
    if (gameLevel >= 2 && gameProgress == 2) currentImagePath = formPath;
  }

  void setNextGame() {
    playerWin = false;
    currentIndex = 0;
    gameProgress = -1; // because change Image will add the process
  }
}
