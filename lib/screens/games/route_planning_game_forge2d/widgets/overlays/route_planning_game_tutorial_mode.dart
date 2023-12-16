import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/tutorial_mode_const.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/components/building_component.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/components/rider.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/widgets/overlays/route_planning_game_rule.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'exit_button.dart';

class RoutePlanningGameTutorialMode extends StatefulWidget {
  static const id = 'RoutePlanningGameTutorialMode';

  const RoutePlanningGameTutorialMode({super.key, required this.game});

  final RoutePlanningGameForge2d game;

  @override
  State<RoutePlanningGameTutorialMode> createState() =>
      _RoutePlanningGameTutorialModeState();
}

class _RoutePlanningGameTutorialModeState
    extends State<RoutePlanningGameTutorialMode> {
  late RectangleComponent background;

  late UserInfoProvider _userInfoProvider;

  BuildingComponent? _targetComponent;

  int tutorialProgress = 0;

  void nextTutorialProgress() async {
    if (tutorialProgress < 10) tutorialProgress++;
    switch (tutorialProgress) {
      case 1:
        //* add blopcks and buildings

        widget.game.generateBuildings();
        widget.game.targetList.addBuildings(buildings: widget.game.buildings);

        widget.game.map.priority = 0;
        await widget.game.map.addBuildings(buildings: widget.game.buildings);
        //*
        widget.game.rider = Rider();
        widget.game.add(widget.game.rider);
        widget.game.targetList.priority = 3;

        for (var building in widget.game.map.buildingComponents) {
          if (building.buildingPosition ==
              (widget.game.map.mapInfo.buildingInfo[0][8][0].buildingPosition +
                  widget.game.map.plusOffset(
                      widget.game.map.mapInfo.blockStartPosition[0][8]))) {
            _targetComponent = building;
            break;
          } else {
            _targetComponent = building;
          }
        }
        Logger().d(widget.game.map.buildingInBlock[8].length);
        //* set if the one is not originally in the map
        if (widget.game.map.buildingInBlock[8].length != 1) {
          _targetComponent!.buildingPosition = widget
                  .game.map.mapInfo.buildingInfo[0][8][0].buildingPosition +
              widget.game.map
                  .plusOffset(widget.game.map.mapInfo.blockStartPosition[0][8]);
          widget.game.map.buildingComponents.add(_targetComponent!);
        }
        break;
      case 2:
        widget.game.targetList.priority = 0;
        widget.game.rider.priority = 3;

        break;
      case 3:
        widget.game.rider.riderSpriteComponent.add(
            MoveEffect.by(Vector2(0.0, -10.0), EffectController(duration: 0)));
        widget.game.rider.riderSpriteComponent.add(MoveEffect.by(
            Vector2(0.0, 10.0),
            EffectController(duration: 1, startDelay: 0.1)));
        Future.delayed(const Duration(seconds: 2), () {
          _targetComponent!.buildingSprite.current = ImageType.light;
          _targetComponent!.buildingSprite.size *= 2;
        });
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        // widget.game.targetList
        widget.game.targetList.priority = 3;
        widget.game.targetList.targetsSprite[2].opacity = 0.3;
        break;
      case 7:
        widget.game.targetList.priority = 0;
        //* error
        _targetComponent!.errorSprite
            .add(OpacityEffect.to(1, EffectController(duration: 0.1)));
        break;
      case 8:
        _targetComponent!.errorSprite
            .add(OpacityEffect.to(0, EffectController(duration: 0.1)));
        //* repeated
        _targetComponent!.repeatedSprite
            .add(OpacityEffect.to(1, EffectController(duration: 0.1)));
        break;
      case 9:
        _targetComponent!.repeatedSprite
            .add(OpacityEffect.to(0, EffectController(duration: 0.1)));
        _targetComponent!.buildingSprite.current = ImageType.normal;
        _targetComponent!.buildingSprite.size /= 2;
        widget.game.map.homeComponent.buildingSprite.current = ImageType.light;
        widget.game.map.homeComponent.buildingSprite.size *= 2;
        final newPosition =
            widget.game.rider.addOffset(widget.game.rider.startPosition[0]);
        widget.game.rider.body.position.x = newPosition.x;
        widget.game.rider.body.position.y = newPosition.y;
        //* add ping
        break;
      case 10:
        _userInfoProvider.routePlanningGameDoneTutorial();
        widget.game.isTutorial = false;

        //* set the game level back to it's original status
        widget.game.gameLevel =
            _userInfoProvider.routePlanningGameDatabase.currentLevel;
        //* remove rider
        widget.game.resetGame();
        // widget.game.rider.removeFromParent();

        //* reset overlays
        widget.game.overlays
            .removeAll([RoutePlanningGameTutorialMode.id, ExitButton.id]);
        widget.game.overlays.addAll([RoutePlanningGameRule.id, ExitButton.id]);

        break;
      default:
        break;
    }
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //* add gray background first
      background = RectangleComponent(
        position: widget.game.size / 2,
        size: widget.game.size,
        anchor: Anchor.center,
        paint: BasicPalette.gray.withAlpha(100).paint(),
        priority: 1,
      );
      widget.game.add(background);

      widget.game.chosenMap = 0;
      widget.game.map.addBlocks(mapIndex: widget.game.chosenMap);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userInfoProvider = context.read<UserInfoProvider>();
    final padding = MediaQuery.of(context).viewPadding;
    Logger().d('${padding.bottom}_${padding.top}');
    final height =
        MediaQuery.of(context).size.height - padding.top - padding.bottom;
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: height * 0.5,
          width: width * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        if (tutorialProgress <= 9) ...[
          TutorialDoctor(tutorialProgress: tutorialProgress),
          ChatBubble(tutorialProgress: tutorialProgress),
        ],
        if (tutorialProgress == 1 ||
            tutorialProgress == 2 ||
            tutorialProgress == 4 ||
            tutorialProgress == 5 ||
            tutorialProgress == 6 ||
            tutorialProgress == 7 ||
            tutorialProgress == 8) ...[
          DottedContainer(
            tutorialProgress: tutorialProgress,
            screenHeight: height,
            screenWidth: width,
          ),
          HintArrow(
            tutorialProgress: tutorialProgress,
            screenHeight: height,
            screenWidth: width,
          ),
        ],
        Align(
          alignment: tutorialProgress <= 1
              ? const Alignment(0.8, -0.9)
              : const Alignment(0.0, -0.9),
          child: FractionallySizedBox(
            heightFactor: 0.15,
            child: ButtonWithText(
              text: '點我繼續',
              onTapFunction: nextTutorialProgress,
            ),
          ),
        ),
      ],
    );
  }
}

class TutorialDoctor extends StatelessWidget {
  final int tutorialProgress;
  const TutorialDoctor({
    required this.tutorialProgress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: tutorialProgress <= 1
          ? const Alignment(1.0, 1.0)
          : const Alignment(0.0, 1.0),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(TutorialModeConst.doctors),
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final int tutorialProgress;
  const ChatBubble({super.key, required this.tutorialProgress});
  static const List<AutoSizeText> tutorialMessage = [
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '哈囉！我是小幫\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '手！接下來我會\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '教你怎麼玩這個\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '遊戲！'),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '畫面左側會出現\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '任務列表，這些\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '是你需要到達的\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '地方。', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '你需要移動這台\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '紅色摩托車，來\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '到達任務列表中\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '的所有地標', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '請你直接用手按\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '著摩托車拖曳就\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '可以移動了!\n', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '當你到達某個地\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '標時，建築物會\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '亮起來', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '這時你可以選擇\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '是否要按下它來\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '完成任務', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '成功後，任務列\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '表中的地標就會\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '像這樣消失', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '若建築物上方輛\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '起叉叉符號，代\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '表你走錯了!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '但如果建築物上方\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '亮起驚嘆號，代表\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '你已經來過了!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
    AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(text: '因此，請正確的\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '選擇要去的地方，\n', style: TextStyle(color: Colors.black)),
          TextSpan(text: '並盡快回到家!', style: TextStyle(color: Colors.black)),
        ],
      ),
      softWrap: true,
      maxLines: 3,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: tutorialProgress <= 1
            ? const Alignment(1.0, -0.3)
            : const Alignment(0.0, -0.3),
        child: FractionallySizedBox(
          heightFactor: 0.55,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    TutorialModeConst.chatBubble,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 0.6,
                  child: Align(
                    alignment: Alignment.center,
                    child: tutorialMessage[tutorialProgress],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DottedContainer extends StatelessWidget {
  final int tutorialProgress;
  final double screenHeight;
  final double screenWidth;

  late final double roadWidth2Roads;
  late final double streetBlockHeight2Roads;
  late final double streetBlockWidth22Roads;
  late final double buildingSize;
  late final double targetBarHeight;
  late final double targetBarWidth;

  DottedContainer({
    super.key,
    required this.tutorialProgress,
    required this.screenWidth,
    required this.screenHeight,
  }) {
    final double mapWidth = screenWidth - screenHeight * 215 / 720;
    roadWidth2Roads = screenHeight * 2 / 13;

    streetBlockHeight2Roads = screenHeight * 3 / 13;
    streetBlockWidth22Roads = (mapWidth - 2 * roadWidth2Roads) / 3;

    buildingSize = streetBlockHeight2Roads / 2;
    targetBarHeight = screenHeight;
    targetBarWidth = targetBarHeight * 215 / 720;
  }

  late final List<Map<String, double?>> positions = [
    {"top": null, "left": null, "bottom": null, "right": null},
    {
      "top": targetBarHeight * 0.125,
      "left": targetBarWidth * 0.11,
      "bottom": null,
      "right": null
    },
    {
      "top": null,
      "left": null,
      "bottom": (streetBlockHeight2Roads - buildingSize) * 0.4,
      "right": streetBlockWidth22Roads - buildingSize
    },
    {"top": null, "left": null, "bottom": null, "right": null},
    {
      "top": null,
      "left": null,
      "bottom": (streetBlockHeight2Roads - buildingSize) * 0.275,
      "right": streetBlockWidth22Roads - buildingSize - buildingSize * 0.125
    },
    {
      "top": null,
      "left": null,
      "bottom": (streetBlockHeight2Roads - buildingSize) * 0.275,
      "right": streetBlockWidth22Roads - buildingSize - buildingSize * 0.125
    },
    {
      "top": targetBarHeight * 0.5,
      "left": targetBarWidth * 0.12,
      "bottom": null,
      "right": null
    },
    {
      "top": null,
      "left": null,
      "bottom": (streetBlockHeight2Roads - buildingSize) * 0.275,
      "right": streetBlockWidth22Roads - buildingSize - buildingSize * 0.125
    },
    {
      "top": null,
      "left": null,
      "bottom": (streetBlockHeight2Roads - buildingSize) * 0.275,
      "right": streetBlockWidth22Roads - buildingSize - buildingSize * 0.125
    },
  ];

  late final List<double?> dottedLineContainerWidth = [
    null,
    targetBarWidth * 0.7,
    buildingSize + roadWidth2Roads,
    null,
    buildingSize * 1.625,
    buildingSize * 1.625,
    targetBarWidth * 0.65,
    buildingSize * 1.625,
    buildingSize * 1.625,
  ];
  late final List<double?> dottedLineContainerHeight = [
    null,
    targetBarHeight * 0.775,
    roadWidth2Roads,
    null,
    buildingSize * 1.625,
    buildingSize * 1.625,
    targetBarWidth * 0.65,
    buildingSize * 1.625,
    buildingSize * 1.625,
  ];
  // static const List<double> dottedLineContainerASRatio = [
  //   1,
  //   215 / 720,
  //   2,
  //   1,
  //   1,
  //   1,
  //   1,
  //   1,
  //   1,
  // ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: positions[tutorialProgress]['top'],
      bottom: positions[tutorialProgress]['bottom'],
      left: positions[tutorialProgress]['left'],
      right: positions[tutorialProgress]['right'],
      width: dottedLineContainerWidth[tutorialProgress],
      height: dottedLineContainerHeight[tutorialProgress],
      child: tutorialProgress == 1 ||
              tutorialProgress == 2 ||
              tutorialProgress == 4 ||
              tutorialProgress == 5 ||
              tutorialProgress == 6 ||
              tutorialProgress == 7 ||
              tutorialProgress == 8
          ? DottedBorder(
              color: Colors.red,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              strokeWidth: 2,
              dashPattern: const [8, 4],
              // padding: const EdgeInsets.all(10),
              strokeCap: StrokeCap.round,
              child: Container(),
            )
          : Container(),
    );
  }

  // double? multiplyTheHeight(double? heightFactor) {
  //   if (heightFactor != null) {
  //     return heightFactor * screenHeight;
  //   }
  //   return null;
  // }

  // double? multiplyTheWidth(double? widthFactor) {
  //   if (widthFactor != null) {
  //     return widthFactor * screenWidth;
  //   }
  //   return null;
  // }

  // double? multiplyMapWidth(double? widthFactor) {
  //   if (widthFactor != null) {
  //     return widthFactor * (screenWidth - screenHeight * 215 / 720);
  //   }
  //   return null;
  // }
}

class HintArrow extends StatelessWidget {
  final int tutorialProgress;
  final double screenHeight;
  final double screenWidth;

  late final double roadWidth2Roads;
  late final double streetBlockHeight2Roads;
  late final double streetBlockWidth22Roads;
  late final double buildingSize;
  late final double targetBarHeight;
  late final double targetBarWidth;
  HintArrow({
    super.key,
    required this.tutorialProgress,
    required this.screenWidth,
    required this.screenHeight,
  }) {
    final double mapWidth = screenWidth - screenHeight * 215 / 720;
    roadWidth2Roads = screenHeight * 2 / 13;

    streetBlockHeight2Roads = screenHeight * 3 / 13;
    streetBlockWidth22Roads = (mapWidth - 2 * roadWidth2Roads) / 3;

    buildingSize = streetBlockHeight2Roads / 2;
    targetBarHeight = screenHeight;
    targetBarWidth = targetBarHeight * 215 / 720;
  }

  // static const List<Alignment> hintArrowAlignment = [
  //   Alignment.center,
  //   Alignment(-0.65, 0.0),
  //   Alignment(0.55, 0.45),
  //   Alignment.center,
  //   Alignment(0.65, 0.4),
  //   Alignment(0.65, 0.4),
  //   Alignment(-0.7, 0.325),
  //   Alignment(0.65, 0.4),
  //   Alignment(0.65, 0.4),
  // ];

  late final List<Map<String, double?>> positions = [
    {"top": null, "left": null, "bottom": null, "right": null},
    {
      "top": targetBarHeight * 0.5,
      "left": targetBarWidth * 1.0,
      "bottom": null,
      "right": null
    },
    {
      "top": null,
      "left": null,
      "bottom": streetBlockHeight2Roads + roadWidth2Roads * 0.1,
      "right": streetBlockWidth22Roads - screenHeight * 0.15 * 0.4
    },
    {"top": null, "left": null, "bottom": null, "right": null},
    {
      "top": null,
      "left": null,
      "bottom": streetBlockHeight2Roads + roadWidth2Roads * 0.1,
      "right": streetBlockWidth22Roads -
          buildingSize * 0.5 -
          screenHeight * 0.15 * 0.5
    },
    {
      "top": null,
      "left": null,
      "bottom": streetBlockHeight2Roads + roadWidth2Roads * 0.1,
      "right": streetBlockWidth22Roads -
          buildingSize * 0.5 -
          screenHeight * 0.15 * 0.5
    },
    {
      "top": targetBarHeight * 0.55,
      "left": targetBarWidth * 0.95,
      "bottom": null,
      "right": null
    },
    {
      "top": null,
      "left": null,
      "bottom": streetBlockHeight2Roads + roadWidth2Roads * 0.1,
      "right": streetBlockWidth22Roads -
          buildingSize * 0.5 -
          screenHeight * 0.15 * 0.5
    },
    {
      "top": null,
      "left": null,
      "bottom": streetBlockHeight2Roads + roadWidth2Roads * 0.1,
      "right": streetBlockWidth22Roads -
          buildingSize * 0.5 -
          screenHeight * 0.15 * 0.5
    },
  ];

  @override
  Widget build(BuildContext context) {
    // return Align(
    //   alignment: hintArrowAlignment[tutorialProgress],
    //   child: FractionallySizedBox(
    //     heightFactor: 0.15,
    //     child: AspectRatio(
    //       aspectRatio: 1,
    //       child: tutorialProgress == 2 ||
    //               tutorialProgress == 4 ||
    //               tutorialProgress == 5 ||
    //               tutorialProgress == 7 ||
    //               tutorialProgress == 8
    //           ? Image.asset(TutorialModeConst.downArrow)
    //           : tutorialProgress == 1 || tutorialProgress == 6
    //               ? Image.asset(TutorialModeConst.leftArrow)
    //               : Container(),
    //     ),
    //   ),
    // );
    return Positioned(
      top: positions[tutorialProgress]['top'],
      bottom: positions[tutorialProgress]['bottom'],
      left: positions[tutorialProgress]['left'],
      right: positions[tutorialProgress]['right'],
      height: screenHeight * 0.15,
      width: screenHeight * 0.15,
      child: tutorialProgress == 2 ||
              tutorialProgress == 4 ||
              tutorialProgress == 5 ||
              tutorialProgress == 7 ||
              tutorialProgress == 8
          ? Image.asset(TutorialModeConst.downArrow)
          : tutorialProgress == 1 || tutorialProgress == 6
              ? Image.asset(TutorialModeConst.leftArrow)
              : Container(),
    );
  }
}
