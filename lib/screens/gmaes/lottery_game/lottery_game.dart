import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LotteryGame {
  int gameLevel;
  int numberOfDigits;
  bool isTutorial;

  LotteryGame({
    required this.gameLevel,
    required this.numberOfDigits,
    required this.isTutorial,
  });

  late List<int> numArray;
  late List<int> userArray;

  final List<String> imagePath = [
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/Temple2_withoutWord.png',
    'assets/lottery_game_scene/NumberInput_recognitionWithoutNum.png',
    'assets/lottery_game_scene/BuyLotteryTickets.png',
    'assets/lottery_game_scene/BuyLotter.png',
  ];
  final String formPath =
      'assets/lottery_game_scene/NumberInput_withoutWord.png';
  final String imagePathWin =
      'assets/lottery_game_scene/feedback/BuyLotter_win_background.png';
  final String imagePathLose =
      'assets/lottery_game_scene/feedback/BuyLotter_lose_background.png';

  int gameProgress = 0;
  bool playerWin = false;
  bool disableButton = false;
  bool isPaused = false;
  bool isCaseFunctioned = false;
  int numOfChosen = 0;
  int currentIndex = 0;
  int loseInCurrentDigits = 0;
  int continuousCorrectRateBiggerThan50 = 0;
  int specialRules = 0;
  String showNumber = '';
  int numOfCorrectAns = 0;
  String currentImagePath = 'assets/lottery_game_scene/Temple2_withoutWord.png';
  List<int> coinReward = [200, 400, 800];
  int gameReward = 0;
  double correctRate = 0;
  List<int> maxNumberLength = [4, 5, 7, 7, 7];

  late DateTime start;
  late DateTime end;
  late bool doneTutorial;
  late List<bool> isChosen;

  String getInstructionAudioPath(String chosenLanguage) {
    String language = chosenLanguage == '國語' ? 'chinese' : 'taiwanese';
    Logger().d(chosenLanguage);
    Logger().d(language);
    String path =
        'instruction_record/$language/lottery_game/rule_level_${gameLevel + 1}';
    if (gameProgress == 2) {
      path = '${path}_sum';
    } else {
      if (gameLevel == 4) {
        switch (specialRules) {
          case 0:
            path = '${path}_even';
            break;
          case 1:
            path = '${path}_max';
            break;
          case 2:
            path = '${path}_min';
            break;
          case 3:
            path = '${path}_odd';
            break;
          default:
        }
      }
    }
    path = '$path.m4a';
    return path;
  }

  void setArrays(int min, int max) {
    Random random = Random();
    Set<int> usedNumbers = {};
    List<int> results = [];

    while (usedNumbers.length < numberOfDigits) {
      int randomNumber = min + random.nextInt(max - min + 1);
      if (!usedNumbers.contains(randomNumber)) {
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
    RecordLotteryGame().recordGame(
      gameLevel: gameLevel,
      numberOfDigits: numberOfDigits,
      numOfCorrectAns: numOfCorrectAns,
      end: end,
      start: start,
    );
  }

  void levelUpgrades() {
    if (gameLevel < 4) {
      numberOfDigits = 2;
      gameLevel++;
    }
  }

  void setGame() {
    // * get special game rule
    if (gameLevel == 4) {
      specialRules = Random().nextInt(4);
    }
  }

  void getResult() {
    numOfCorrectAns = 0;
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
          case 0:
            //even
            for (int i = 0; i < numArray.length; i++) {
              if (numArray[i] % 2 == 0) sum += numArray[i];
            }
            break;
          case 1:
            //max
            numArray.sort((b, a) => a.compareTo(b));
            sum = numArray[0] + numArray[1];
            break;
          case 2:
            //min
            numArray.sort();
            sum = numArray[0] + numArray[1];
            break;
          case 3:
            //odd
            for (int i = 0; i < numArray.length; i++) {
              if (numArray[i] % 2 == 1) sum += numArray[i];
            }
            break;
          case 4:
            break;
        }
        if (sum == userArray[0]) numOfCorrectAns = numArray.length;
        break;
      default:
        break;
    }
    // reward is determined by correct rate
    correctRate = numOfCorrectAns / numberOfDigits;
    gameReward = 0;
    if (correctRate > 0 && correctRate <= 0.5) {
      gameReward = coinReward[0];
    } else if (correctRate > 0.5 && correctRate <= 0.75) {
      gameReward = coinReward[1];
    } else if (correctRate > 0.75 && correctRate <= 1) {
      gameReward = coinReward[2];
    }
    correctRate != 0.0 ? playerWin = true : playerWin = false;
  }

  void changeDigitByResult() {
    if (playerWin) {
      if (loseInCurrentDigits > 0) loseInCurrentDigits--;
      // *  if correctrate >= 0.5 continuously two times add the digit
      if (correctRate >= 0.5) {
        continuousCorrectRateBiggerThan50++;
      } else {
        if (continuousCorrectRateBiggerThan50 > 0) {
          continuousCorrectRateBiggerThan50--;
        }
      }
      if (continuousCorrectRateBiggerThan50 >= 2) {
        continuousCorrectRateBiggerThan50 = 0;
        numberOfDigits++;
        loseInCurrentDigits = 0;
      }
      if (numberOfDigits > maxNumberLength[gameLevel]) {
        levelUpgrades();
      }
    } else {
      if (continuousCorrectRateBiggerThan50 > 0) {
        continuousCorrectRateBiggerThan50--;
      }
      loseInCurrentDigits++;
      if (loseInCurrentDigits >= 2) {
        if (numberOfDigits > 2) {
          numberOfDigits--;
          loseInCurrentDigits = 0;
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
