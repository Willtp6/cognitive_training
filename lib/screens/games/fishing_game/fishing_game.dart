import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/fishing_game_const.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/models/database_models.dart';
import 'components/rod_component.dart';
import 'components/result_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'components/background_component.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:logger/logger.dart';
import 'widgets/overlays/result_dialog.dart';
import 'widgets/overlays/exit_button.dart';
import 'widgets/overlays/top_coins.dart';

class FishingGame extends FlameGame with HasCollisionDetection, HasTappables {
  FishingGame({
    required this.gameLevel,
    required this.continuousWin,
    required this.continuousLose,
    this.isTutorial = false,
    required this.databaseInfoProvider,
    required this.audioController,
  });
  final List<List<int>> possibleRippleList = [
    [0, 3],
    [0, 1, 3],
    [0, 1, 2],
    [0, 1, 2, 3],
    [0, 1, 2, 3],
  ];

  final Map<String, int> fishReward = {'A': 1000, 'B': 800, 'C': 300};

  final List<Map<int, int>> penalty = [
    {0: 150, 1: 100, 2: 50},
    {0: 150, 1: 100, 2: 50},
    {0: 150, 1: 100, 2: 50},
    {0: 150, 1: 100, 2: 50},
    {0: 150, 1: 100, 2: 50},
  ];

  int gameLevel;
  bool isTutorial;
  int continuousWin;
  int continuousLose;
  DatabaseInfoProvider databaseInfoProvider;
  AudioController audioController;

  late BackGroundComponent backGroundComponent;
  late List<TimerComponent> rippleTimers;
  late TimerComponent resultDialogTimer;
  late List<RodComponent> rodComponents;
  late ResultComponent resultComponent;
  List<int> scaleList = [];
  // late AudioPlayer _audioPlayer;
  AudioPlayer? bubbleAudioPlayer;
  // late FishComponent fishComponent;

  late int ansRod;
  late int playerChosenRod;
  late int playerChosenRodRipple;
  int reachedAnimationCounter = 0;
  int repeatTime = 0;
  bool rodTappable = false;

  bool gameLevelChanged = false;

  late DateTime startTime;
  late DateTime endTime;

  @override
  void onAttach() {
    FlameAudio.bgm.initialize();
    super.onAttach();
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    bubbleAudioPlayer?.dispose();
    super.onDetach();
  }

  @override
  FutureOr<void> onLoad() async {
    //!!! run as debug mode
    //debugMode = true;

    backGroundComponent = BackGroundComponent();
    resultDialogTimer = TimerComponent(
      period: 2.5,
      autoStart: false,
      onTick: () {
        resultComponent.reset();
        overlays.remove(ExitButton.id);
        overlays.add(ResultDialog.id);
      },
    );
    resultComponent = ResultComponent();
    await addAll([
      backGroundComponent,
      resultDialogTimer,
      resultComponent,
    ]);
    super.onLoad();
  }

  Future<void> startGame() async {
    FlameAudio.bgm.play(FishingGameConst.bgmAudio, volume: 0.7);

    //* reset
    reachedAnimationCounter = 0;
    repeatTime = 0;
    rodTappable = false;
    gameLevelChanged = false;
    //* initialize rods and timers
    await generateRods();
    generateRippleTimers();
  }

  Future<void> generateRods() async {
    scaleList = possibleRippleList[gameLevel];
    scaleList.shuffle();
    ansRod = scaleList.indexOf(3);
    Logger().d(ansRod);
    rodComponents = List.generate(
      FishingGameConst.numOfRods[gameLevel],
      (index) => RodComponent(rodId: index, scaleLevel: scaleList[index])
        ..add(OpacityEffect.to(1, EffectController(duration: 0.5))),
    );
    await addAll(rodComponents);
  }

  //! startTime is count from here because here is the place which all timer start
  void generateRippleTimers() async {
    rippleTimers = List.generate(
      FishingGameConst.numOfRods[gameLevel],
      (index) => TimerComponent(
        period: Random().nextDouble() * 4 + 1,
        autoStart: true,
        onTick: () {
          rippleTimerUp(index);
        },
      ),
    );
    addAll(rippleTimers);
    bubbleAudioPlayer = await FlameAudio.loop(FishingGameConst.bubbleAudio);
    startTime = DateTime.now();
  }

  void rippleTimerUp(int index) {
    rodComponents[index].controller.isActive = true;
    reachedAnimationCounter++;
    if (reachedAnimationCounter == FishingGameConst.numOfRods[gameLevel]) {
      //* all animation have been pleyed once
      rodTappable = true;
      reachedAnimationCounter = 0;
      switch (gameLevel) {
        case 0:
        case 1:
          resetTimers();
          break;
        case 2:
        case 3:
          if (repeatTime < 1) {
            repeatTime++;
            resetTimers();
          } else {
            //* reset for next game but do not repeat animation
            repeatTime = 0;
            Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
              bubbleAudioPlayer?.pause();
            });
          }
          break;
        // case 4:
        //   Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        //     bubbleAudioPlayer?.pause();
        //   });
        //   break;
        default:
          Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
            bubbleAudioPlayer?.pause();
          });
          break;
      }
    }
  }

  // void checkCounterNumbers() {
  //   if (reachedAnimationCounter == Globals.numOfRods[gameLevel]) {
  //     //* all animation have been pleyed once
  //     rodTappable = true;
  //     reachedAnimationCounter = 0;
  //     switch (gameLevel) {
  //       case 0:
  //       case 1:
  //         resetTimers();
  //         break;
  //       case 2:
  //       case 3:
  //         if (repeatTime < 1) {
  //           repeatTime++;
  //           resetTimers();
  //         } else {
  //           //* reset for next game but do not repeat animation
  //           repeatTime = 0;
  //         }
  //         break;
  //       case 4:
  //         break;
  //       default:
  //         break;
  //     }
  //   }
  // }

  void resetTimers() {
    // _audioPlayer.play(AssetSource('audio/fishing_game/sfx/Bubbles.wav'));
    // FlameAudio.loop(FishingGameConst.bubbleAudio).then((value) => value.pause());
    //* delay for next bubble loop
    add(TimerComponent(
      period: 1.5,
      removeOnFinish: true,
      onTick: () {
        // reachedAnimationCounter = 0;
        for (var item in rippleTimers) {
          item.timer.start();
        }
      },
    ));
  }

  void resetAllRodImages() {
    for (var item in rodComponents) {
      item.setImageToNormal();
    }
  }

  void makeAllRodsInvisible() {
    rodTappable = false;
    for (var item in rodComponents) {
      item.add(OpacityEffect.to(0, EffectController(duration: 0.3)));
      item.removeRipple();
      if (item.isChosen) {
        playerChosenRod = item.rodId;
        playerChosenRodRipple = item.scaleLevel;
      }
      item.isChosen = false;
    }
    for (var item in rippleTimers) {
      item.timer.pause();
    }
  }

  void makeAllRodsVisible() {
    resetAllRodImages();
    List<int> scaleList = possibleRippleList[gameLevel];
    scaleList.shuffle();
    ansRod = scaleList.indexOf(3);
    Logger().d(ansRod);
    for (int i = 0; i < scaleList.length; i++) {
      rodComponents[i].setImageToNormal();
      rodComponents[i].scaleLevel = scaleList[i];
      rodComponents[i]
          .add(OpacityEffect.to(1, EffectController(duration: 0.3)));
      rodComponents[i].addRipple();
    }
  }

  void getResult() {
    //* stop bubble audio
    bubbleAudioPlayer?.pause();
    //*
    overlays.remove(TopCoins.id);
    backGroundComponent.changeToResult();
    bool isPlayerWin = false;
    bool isNotBiggestRipple = false;
    switch (gameLevel) {
      case 0:
        isPlayerWin = playerChosenRod == scaleList.indexOf(3);
        break;
      case 1:
        isPlayerWin = playerChosenRod == scaleList.indexOf(3) ||
            playerChosenRod == scaleList.indexOf(2);
        isNotBiggestRipple = playerChosenRod != scaleList.indexOf(3);
        break;
      case 2:
        isPlayerWin = playerChosenRod == scaleList.indexOf(2) ||
            playerChosenRod == scaleList.indexOf(1);
        isNotBiggestRipple = playerChosenRod != scaleList.indexOf(2);

        break;
      case 3:
        isPlayerWin = playerChosenRod == scaleList.indexOf(3) ||
            playerChosenRod == scaleList.indexOf(2);
        isNotBiggestRipple = playerChosenRod != scaleList.indexOf(3);

        break;
      case 4:
        isPlayerWin = playerChosenRod == scaleList.indexOf(3);
        isNotBiggestRipple = playerChosenRod != scaleList.indexOf(3);

        break;
    }

    if (isPlayerWin) {
      resultComponent.isFish();
      FlameAudio.play(FishingGameConst.winAudio);
      int coinChangeValue = 0;
      if (isNotBiggestRipple) {
        coinChangeValue -= penalty[gameLevel][playerChosenRodRipple]!;
      }
      coinChangeValue += fishReward[resultComponent.fishType]!;
      //* random size
      if (resultComponent.fishType == 'A' || resultComponent.fishType == 'B') {
        List<int> possibleSizeReward = [0, 100, 250];
        coinChangeValue +=
            possibleSizeReward[Random().nextInt(possibleSizeReward.length)];
      }
      databaseInfoProvider.coins += coinChangeValue;
      //* set for change level
      continuousWin++;
      continuousLose = 0;
    } else {
      resultComponent.isEmpty();
      FlameAudio.play(FishingGameConst.loseAudio);
      // todo minus coins
      databaseInfoProvider.coins -= penalty[gameLevel][playerChosenRodRipple]!;
      //* set for change level
      continuousWin = 0;
      continuousLose++;
    }
    //* get end time
    endTime = DateTime.now();
    RecordGame.recordFishingGame(
      gameLevel: gameLevel,
      start: startTime,
      end: endTime,
      type: ansRod == playerChosenRod ? "fish" : "none",
    );
    databaseInfoProvider.addPlayTime(startTime, endTime);
    if (continuousWin == 5 && gameLevel < 4) {
      gameLevel++;
      continuousWin = 0;
      gameLevelChanged = true;
    } else if (continuousLose == 5 && gameLevel > 1) {
      gameLevel--;
      continuousLose = 0;
      gameLevelChanged = true;
    }
    databaseInfoProvider.fishingGameDatabase = FishingGameDatabase(
      currentLevel: gameLevel,
      historyContinuousWin: continuousWin,
      historyContinuousLose: continuousLose,
      doneTutorial: databaseInfoProvider.fishingGameDatabase.doneTutorial,
    );
    resultDialogTimer.timer.start();
  }

  void resetGame() {
    overlays.add(TopCoins.id);
    backGroundComponent.changeToFishing();
    //* check number of rod if is enough than make visible
    //* otherwise generate new rod
    if (checkNumOfRods()) {
      makeAllRodsVisible();
    }
    //* set new timers for each rod
    regenerateRippleTimers();
  }

  void regenerateRods() {
    removeAll(rodComponents);
    generateRods();
  }

  void regenerateRippleTimers() {
    removeAll(rippleTimers);
    generateRippleTimers();
  }

  bool checkNumOfRods() {
    if (rodComponents.length != FishingGameConst.numOfRods[gameLevel]) {
      regenerateRods();
      return false;
    }
    return true;
  }
}
