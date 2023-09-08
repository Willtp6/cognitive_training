import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
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

List<List<int>> possibleRippleList = [
  [0, 3],
  [0, 1, 3],
  [0, 1, 3],
  [0, 1, 2, 3],
  [0, 1, 2, 3],
];

class FishingGame extends FlameGame with HasCollisionDetection, HasTappables {
  FishingGame({
    this.gameLevel = 0,
    required this.userInfoProvider,
  });

  int gameLevel;
  int continuousWin = 0;
  int continuousLose = 0;
  UserInfoProvider userInfoProvider;

  late BackGroundComponent backGroundComponent;
  late List<TimerComponent> rippleTimers;
  late TimerComponent resultDialogTimer;
  late List<RodComponent> rodComponents;
  late ResultComponent resultComponent;
  late AudioPlayer _audioPlayer;
  // late FishComponent fishComponent;

  late int ansRod;
  late int playerChosenRod;
  int reachedAnimationCounter = 0;
  int repeatTime = 0;
  bool rodTappable = false;

  bool gameLevelChanged = false;

  late DateTime startTime;
  late DateTime endTime;

  @override
  void onAttach() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('fishing_game/sound/bgm.mp3', volume: 0.7);
    super.onAttach();
    Logger().d('attach complete');
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    _audioPlayer.dispose();
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
        });
    resultComponent = ResultComponent();
    // fishComponent = FishComponent();
    await addAll([
      backGroundComponent,
      resultDialogTimer,
      resultComponent,
      // fishComponent,
    ]);
    _audioPlayer = AudioPlayer();
    super.onLoad();
    Logger().d('load complete');
  }

  void startGame() {
    //* reset
    reachedAnimationCounter = 0;
    repeatTime = 0;
    rodTappable = false;
    gameLevelChanged = false;
    //* initialize rods and timers
    generateRods();
    generateRippleTimers();
  }

  void generateRods() {
    List<int> scaleList = possibleRippleList[gameLevel];
    scaleList.shuffle();
    ansRod = scaleList.indexOf(3);
    Logger().d(ansRod);
    rodComponents = List.generate(
      Globals.numOfRods[gameLevel],
      (index) => RodComponent(rodId: index, scaleLevel: scaleList[index])
        ..add(OpacityEffect.to(1, EffectController(duration: 0.5))),
    );
    addAll(rodComponents);
  }

  //! startTime is count from here because here is the place which all timer start
  void generateRippleTimers() {
    rippleTimers = List.generate(
      Globals.numOfRods[gameLevel],
      (index) => TimerComponent(
        period: Random().nextDouble() * 4 + 1,
        autoStart: true,
        onTick: () {
          rodComponents[index].controller.isActive = true;
          reachedAnimationCounter++;
          checkCounterNumbers();
        },
      ),
    );
    addAll(rippleTimers);
    // FlameAudio.play('fishing_game/sound/Bubbles.wav');
    _audioPlayer.play(AssetSource('audio/fishing_game/sound/Bubbles.wav'));
    startTime = DateTime.now();
  }

  void checkCounterNumbers() {
    if (reachedAnimationCounter == Globals.numOfRods[gameLevel]) {
      //* all animation have been pleyed once
      rodTappable = true;
      Logger().d(rodTappable);
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
            reachedAnimationCounter = 0;
          }
          break;
        case 4:
          reachedAnimationCounter = 0;
          break;
        default:
          break;
      }
    }
  }

  void resetTimers() {
    // FlameAudio.play('fishing_game/sound/Bubbles.wav');
    _audioPlayer.play(AssetSource('audio/fishing_game/sound/Bubbles.wav'));

    add(TimerComponent(
      period: 1.5,
      removeOnFinish: true,
      onTick: () {
        reachedAnimationCounter = 0;
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
      if (item.isChosen) playerChosenRod = item.rodId;
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
    _audioPlayer.stop();
    overlays.remove(TopCoins.id);
    backGroundComponent.changeToResult();
    endTime = DateTime.now();
    if (ansRod == playerChosenRod) {
      resultComponent.isFish();
      FlameAudio.play('fishing_game/sound/fishing_win.mp3');
      continuousWin++;
      continuousLose = 0;
    } else {
      resultComponent.isEmpty();
      FlameAudio.play('fishing_game/sound/fishing_lose.mp3');
      continuousWin = 0;
      continuousLose++;
    }
    RecordFishingGame().recordGame(
      gameLevel: gameLevel,
      start: startTime,
      end: endTime,
      type: ansRod == playerChosenRod ? "fish" : "none",
    );
    if (continuousWin == 5 && gameLevel < 4) {
      gameLevel++;
      continuousWin = 0;
      gameLevelChanged = true;
    } else if (continuousLose == 5 && gameLevel > 1) {
      gameLevel--;
      continuousLose = 0;
      gameLevelChanged = true;
    }
    userInfoProvider.fishingGameDatabase = FishingGameDatabase(
      currentLevel: gameLevel,
      doneTutorial: userInfoProvider.fishingGameDatabase.doneTutorial,
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
    if (rodComponents.length != Globals.numOfRods[gameLevel]) {
      regenerateRods();
      return false;
    }
    return true;
  }
}
