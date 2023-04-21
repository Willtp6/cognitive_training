import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
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
  final String imagePathWin = 'assets/lottery_game_scene/BuyLotter_win.png';
  final String imagePathLose = 'assets/lottery_game_scene/BuyLotter_lose.png';
  final List<String> gameRules = [
    '接下來你會聽到加看到數字，請試著記下所有的數字吧(不用依照順序喔)',
    'level 2 rule',
    'level 3 rule',
    'level 4 rule',
    'level 5 rule'
  ];

  int gameProgress = 0;
  bool playerWin = false;
  bool disableButton = false;
  bool isPaused = false;
  bool isCaseFunctioned = false;
  int numOfChosen = 0;
  int currentIndex = 0;
  int loseInCurrentDigits = 0;
  int continuousWinInEightDigits = 0;
  int specialRules = 0;
  String showNumber = '';
  int numOfCorrectAns = 0;
  String currentImagePath = 'assets/lottery_game_scene/Temple2_withoutWord.png';
  List<int> coinReward = [200, 400, 800];
  int gameReward = 0;

  late DateTime start;
  late DateTime end;
  late bool doneTutorial;
  late List<bool> isChosen;

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
        start: start);
  }

  void levelUpgrades() {
    currentIndex = 0;
    loseInCurrentDigits = 0;
    continuousWinInEightDigits = 0;
    numberOfDigits = 2;
    gameProgress = 0;
    gameLevel++;
  }

  void randomGenerateRules() {
    specialRules = Random().nextInt(4);
  }

  void getResult() {
    numOfCorrectAns = 0;
    switch (gameLevel) {
      case 0:
      case 1:
        Logger().d(numArray);
        for (int i = 0; i < numArray.length; i++) {
          if (isChosen[numArray[i]]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 2:
      case 3:
        for (int i = 0; i < numArray.length; i++) {
          if (numArray[i] == userArray[i]) {
            numOfCorrectAns++;
          }
        }
        break;
      case 4:
        switch (specialRules) {
          case 0:
          case 1:
          case 2:
          case 3:
            break;
        }
        break;
      default:
        break;
    }
    // reward is determined by correct rate
    double correctRate = numOfCorrectAns / numberOfDigits;
    gameReward = 0;
    if (correctRate > 0 && correctRate <= 0.5) {
      gameReward = coinReward[0];
    } else if (correctRate > 0.5 && correctRate <= 0.75) {
      gameReward = coinReward[1];
    } else if (correctRate > 0.75 && correctRate <= 1) {
      gameReward = coinReward[2];
    }
    correctRate != 0.0 ? playerWin = true : playerWin = false;
    print(correctRate);
    print(playerWin);
  }

  void changeDigitByResult() {
    if (playerWin) {
      if (numberOfDigits == 8) {
        continuousWinInEightDigits++;
        if (continuousWinInEightDigits == 2) levelUpgrades();
      } else {
        numberOfDigits++;
        if (loseInCurrentDigits > 0) loseInCurrentDigits--;
      }
    } else {
      if (numberOfDigits == 8) continuousWinInEightDigits = 0;
      if (numOfCorrectAns / numberOfDigits < 0.5) loseInCurrentDigits++;
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
  }

  void setNextGame() {
    playerWin = false;
    currentIndex = 0;
    gameProgress = -1; // because change Image will add the process
  }
}
