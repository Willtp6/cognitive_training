import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/constants/route_planning_game_const.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/widgets/overlays/exit_button.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:logger/logger.dart';
import 'components/wall_component.dart';
import 'components/background_component.dart';
import 'components/target_list.dart';
import 'components/rider.dart';
import 'components/map_entity.dart';
import 'models/building.dart';
import 'widgets/overlays/game_lose.dart';
import 'widgets/overlays/game_win.dart';

class RoutePlanningGameForge2d extends Forge2DGame
    with HasTappables /*, HasDraggables*/ {
  int gameLevel;
  int continuousWin;
  int continuousLose;
  bool isTutorial;
  UserInfoProvider userInfoProvider;
  RoutePlanningGameForge2d({
    this.gameLevel = 0,
    this.continuousWin = 0,
    this.continuousLose = 0,
    this.isTutorial = false,
    required this.userInfoProvider,
  }) : super(gravity: Vector2.zero());

  static const List<int> numOfBuildings = [6, 8, 8, 8, 10];

  static const List<int> numOfTarget = [3, 3, 4, 4, 4];

  static const List<List<int>> possibleMapIndex = [
    [0, 1, 2, 3],
    [0, 1, 2, 3],
    [2, 3, 4, 5, 6, 7],
    [4, 5, 6, 7, 8, 9],
    [4, 5, 6, 7, 8, 9],
  ];

  static const List<double> hintImageShowTime = [double.infinity, 1, 0, 0, 0];

  late List<Building> buildings = [];
  late TargetList targetList;
  late Rider rider;
  late JoystickComponent joystick;
  late MapEntity map;
  late int chosenMap;
  late double remainRepeatedHintShowTime;
  late double remainErrorHintShowTime;

  // late TimerComponent countDownTimer;
  Timer? countDownTimer;
  late int remainTime;
  bool timerEnabled = true;
  late SpriteComponent alarmClock;
  bool alarmClockAdded = false;
  AudioPlayer? alarmClockAudio;

  //* record data
  late DateTime startTime;
  late DateTime endTime;
  List<int> timeToEachHalfwayPoint = [];
  int nonTargetError = 0;
  int repeatedError = 0;

  @override
  void onAttach() {
    FlameAudio.bgm.initialize();
    super.onAttach();
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    countDownTimer?.cancel();
    Logger().d('detached');
  }

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    //? the problem is that the size need to times 10 ?
    //? because in forge2d game size is 10 times smaller than in flame game.
    //? while the other which takes gameRef.size to get size don't need to
    //? times 10 reason is unknown.
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: size.y / 5,
        paint: BasicPalette.red.withAlpha(0).paint(),
      ),
      background: CircleComponent(
        radius: size.y / 2,
        paint: BasicPalette.red.withAlpha(0).paint(),
      ),
      // margin: EdgeInsets.only(
      //     left: (size.y / 10 + 215 / 720 * size.y) * 10, bottom: size.y),
      position: size / 2,
    );
    map = MapEntity(
      size: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    targetList = TargetList();

    //* all of them are static component
    addAll([
      BackgroundComponent(),
      //* four edges
      WallComponent(v1: Vector2(0, 0), v2: Vector2(size.x, 0)),
      WallComponent(v1: Vector2(0, size.y), v2: Vector2(size.x, size.y)),
      WallComponent(
          v1: Vector2(215 / 720 * size.y, 0),
          v2: Vector2(215 / 720 * size.y, size.y)),
      WallComponent(v1: Vector2(size.x, 0), v2: Vector2(size.x, size.y)),

      map,
      joystick,
      targetList,
      // rider,
    ]);
    alarmClock = SpriteComponent(
      sprite: await loadSprite('route_planning_game/hints/alarm_clock.png'),
      size: Vector2.all(size.y / 5),
      position: Vector2(size.x * 0.8, size.y / 2),
      angle: -pi / 16,
      anchor: Anchor.center,
    )..add(RotateEffect.by(
        pi / 8,
        EffectController(
          duration: 0.4,
          reverseDuration: 0.4,
          infinite: true,
        )));
    return super.onLoad();
  }

  void startGame() async {
    //! for debugging
    FlameAudio.bgm.play(RoutePlanningGameConst.bgm);
    //* get a new map index
    int numOfPossibleMap = possibleMapIndex[gameLevel].length;
    chosenMap = possibleMapIndex[gameLevel][Random().nextInt(numOfPossibleMap)];
    //* set hint image show time
    remainRepeatedHintShowTime = hintImageShowTime[gameLevel];
    remainErrorHintShowTime = hintImageShowTime[gameLevel];
    //* add rider
    rider = Rider();
    add(rider);
    //* add countdown timer
    addAlarm();
    generateBuildings();
    targetList.addBuildings(buildings: buildings);

    map.addBlocks(mapIndex: chosenMap);
    //! test for all block
    // map.addAllBuildingsAsHome();
    map.addBuildings(buildings: buildings);
    startTime = DateTime.now();
  }

  /// remove all added dynamic components
  /// also reset all values
  void resetGame() {
    targetList.removeAllBuildings();
    map.removeBlocks();
    map.removeBuildings();
    remove(rider);
  }

  void generateBuildings() {
    buildings.clear();
    while (buildings.length < numOfBuildings[gameLevel]) {
      int toAddId = Random().nextInt(40);
      //* which means the is already in the list
      if (buildings.where((element) => element.id == toAddId).isNotEmpty) {
        continue;
      } else {
        //* if target is not enough then set to target
        bool needMoreTarget =
            buildings.where((element) => element.isTarget).length <
                numOfTarget[gameLevel];
        buildings.add(Building(id: toAddId, isTarget: needMoreTarget));
      }
    }
  }

  void gameWin() {
    alarmClock.removeFromParent();
    alarmClockAdded = false;
    alarmClockAudio?.pause();
    countDownTimer?.cancel();
    recordGame('Win');
    FlameAudio.bgm.stop();
    overlays.remove(ExitButton.id);
    overlays.add(GameWin.id);
    resetGame();
  }

  void gameLose() {
    recordGame('Lose');
    FlameAudio.bgm.stop();
    overlays.remove(ExitButton.id);
    overlays.add(GameLose.id);
    resetGame();
  }

  void recordGame(String result) {
    endTime = DateTime.now();
    //* record game result
    RecordGame().recordRoutePlanningGame(
      end: endTime,
      gameDifficulties: gameLevel,
      mapIndex: chosenMap,
      nonTargetError: nonTargetError,
      numOfTargets: numOfTarget[gameLevel],
      repeatedError: repeatedError,
      result: result,
      start: startTime,
      timeToEachHalfwayPoint: timeToEachHalfwayPoint,
    );
    //* reset data
    nonTargetError = 0;
    repeatedError = 0;
    timeToEachHalfwayPoint.clear();
    checkContinuousWinLose(result);
    updateDatabase();
  }

  /// update game level
  void checkContinuousWinLose(String result) {
    if (result == 'Win') {
      continuousWin++;
      continuousLose = 0;
    } else {
      continuousLose++;
      continuousWin = 0;
    }
    //* change game level
    if (continuousWin >= 5) {
      continuousWin = 0;
      if (gameLevel < 4) gameLevel++;
    } else if (continuousLose >= 5) {
      continuousLose = 0;
      if (gameLevel > 0) gameLevel--;
    }
  }

  /// Update database info about gameLevel...
  void updateDatabase() {
    //* update list of response time
    RoutePlanningGameDatabase database =
        userInfoProvider.routePlanningGameDatabase;
    database.responseTimeList
      ..add(endTime.difference(startTime).inMilliseconds)
      ..sort();
    //* remove first and last item
    if (database.responseTimeList.length > 100) {
      database.responseTimeList
        ..removeAt(0)
        ..removeLast();
    }
    userInfoProvider.routePlanningGameDatabase = RoutePlanningGameDatabase(
      currentLevel: gameLevel,
      historyContinuousWin: continuousWin,
      historyContinuousLose: continuousLose,
      doneTutorial: database.doneTutorial,
      responseTimeList: database.responseTimeList,
    );
  }

  /// add countdown timer
  void addAlarm() {
    if (gameLevel > 0) {
      final List<int> addedTime = [0, 10, 8, 5, 3];
      final responseTimeList =
          userInfoProvider.routePlanningGameDatabase.responseTimeList;
      remainTime =
          (responseTimeList[responseTimeList.length ~/ 2] / 1000).ceil() +
              addedTime[gameLevel];
      countDownTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (timerEnabled) {
          // Logger().d(timer.tick);
          remainTime--;
          Logger().d(remainTime);
          //* start alarm clock animation
          if (remainTime <= 5 && !alarmClockAdded) {
            add(alarmClock);
            alarmClockAdded = true;
            alarmClockAudio =
                await FlameAudio.loop(RoutePlanningGameConst.tictocAudio);
          }
          //* cancel timer and trigger time up event
          if (remainTime <= 0) {
            alarmClock.removeFromParent();
            alarmClockAdded = false;
            alarmClockAudio?.pause();
            countDownTimer?.cancel();
            gameLose();
          }
        }
      });
    }
  }
}
