import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RoutePlanningGameConst {
  RoutePlanningGameConst._();

  //* route planning game menu
  static const menuBackground =
      'assets/images/route_planning_game/scene/at_home01.png';
  static const phoneRingImage =
      'assets/images/route_planning_game/scene/phone_ring.png';
  static const dialogBox =
      'assets/images/route_planning_game/scene/dialog_box.png';
  static const dialogBoxMom =
      'assets/images/route_planning_game/scene/dialog_box_mom.png';
  static const riderInMenu =
      'assets/images/route_planning_game/scene/rider_left.png';

  //* rule text
  static const level1RuleText = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(
            text: '請前往目標地幫家人辦事後回家\n', style: TextStyle(color: Colors.black)),
        TextSpan(text: '越快', style: TextStyle(color: Colors.red)),
        TextSpan(text: '完成越好喔!', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 2,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  static const level2RuleText = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(
            text: '前往目標地幫家人辦事後回家\n', style: TextStyle(color: Colors.black)),
        TextSpan(text: '越快', style: TextStyle(color: Colors.red)),
        TextSpan(
            text: '完成越好! 注意錯誤只會提示一次喔!', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 2,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  static const level3to5RuleText = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(
            text: '前往目標地幫家人辦事後回家\n', style: TextStyle(color: Colors.black)),
        TextSpan(text: '不要走錯', style: TextStyle(color: Colors.red)),
        TextSpan(text: '且', style: TextStyle(color: Colors.black)),
        TextSpan(text: '越快', style: TextStyle(color: Colors.red)),
        TextSpan(text: '完成越好喔!', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 2,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );

  //* images
  static const targetList = 'route_planning_game/scene/targetLabel.png';
  static const riderLeft = 'route_planning_game/scene/rider_left.png';
  static const riderRight = 'route_planning_game/scene/rider_right.png';
  static const homeImagePath = 'route_planning_game/buildings/Home.png';
  static const homeLightImagePath =
      'route_planning_game/buildings/Home_light.png';
  static const List<String> buildingsImagePath = [
    'route_planning_game/buildings/Building01.png',
    'route_planning_game/buildings/Building02.png',
    'route_planning_game/buildings/Building03.png',
    'route_planning_game/buildings/Building04.png',
    'route_planning_game/buildings/Building05.png',
    'route_planning_game/buildings/Building06.png',
    'route_planning_game/buildings/Building07.png',
    'route_planning_game/buildings/Building08.png',
    'route_planning_game/buildings/Building09.png',
    'route_planning_game/buildings/Building10.png',
    'route_planning_game/buildings/Building11.png',
    'route_planning_game/buildings/Building12.png',
    'route_planning_game/buildings/Building13.png',
    'route_planning_game/buildings/Building14.png',
    'route_planning_game/buildings/Building15.png',
    'route_planning_game/buildings/Building16.png',
    'route_planning_game/buildings/Building17.png',
    'route_planning_game/buildings/Building18.png',
    'route_planning_game/buildings/Building19.png',
    'route_planning_game/buildings/Building20.png',
    'route_planning_game/buildings/Building21.png',
    'route_planning_game/buildings/Building22.png',
    'route_planning_game/buildings/Building23.png',
    'route_planning_game/buildings/Building24.png',
    'route_planning_game/buildings/Building25.png',
    'route_planning_game/buildings/Building26.png',
    'route_planning_game/buildings/Building27.png',
    'route_planning_game/buildings/Building28.png',
    'route_planning_game/buildings/Building29.png',
    'route_planning_game/buildings/Building30.png',
    'route_planning_game/buildings/Building31.png',
    'route_planning_game/buildings/Building32.png',
    'route_planning_game/buildings/Building33.png',
    'route_planning_game/buildings/Building34.png',
    'route_planning_game/buildings/Building35.png',
    'route_planning_game/buildings/Building36.png',
    'route_planning_game/buildings/Building37.png',
    'route_planning_game/buildings/Building38.png',
    'route_planning_game/buildings/Building39.png',
    'route_planning_game/buildings/Building40.png',
  ];
  static const List<String> buildingsLightImagePath = [
    'route_planning_game/buildings/Building01_light.png',
    'route_planning_game/buildings/Building02_light.png',
    'route_planning_game/buildings/Building03_light.png',
    'route_planning_game/buildings/Building04_light.png',
    'route_planning_game/buildings/Building05_light.png',
    'route_planning_game/buildings/Building06_light.png',
    'route_planning_game/buildings/Building07_light.png',
    'route_planning_game/buildings/Building08_light.png',
    'route_planning_game/buildings/Building09_light.png',
    'route_planning_game/buildings/Building10_light.png',
    'route_planning_game/buildings/Building11_light.png',
    'route_planning_game/buildings/Building12_light.png',
    'route_planning_game/buildings/Building13_light.png',
    'route_planning_game/buildings/Building14_light.png',
    'route_planning_game/buildings/Building15_light.png',
    'route_planning_game/buildings/Building16_light.png',
    'route_planning_game/buildings/Building17_light.png',
    'route_planning_game/buildings/Building18_light.png',
    'route_planning_game/buildings/Building19_light.png',
    'route_planning_game/buildings/Building20_light.png',
    'route_planning_game/buildings/Building21_light.png',
    'route_planning_game/buildings/Building22_light.png',
    'route_planning_game/buildings/Building23_light.png',
    'route_planning_game/buildings/Building24_light.png',
    'route_planning_game/buildings/Building25_light.png',
    'route_planning_game/buildings/Building26_light.png',
    'route_planning_game/buildings/Building27_light.png',
    'route_planning_game/buildings/Building28_light.png',
    'route_planning_game/buildings/Building29_light.png',
    'route_planning_game/buildings/Building30_light.png',
    'route_planning_game/buildings/Building31_light.png',
    'route_planning_game/buildings/Building32_light.png',
    'route_planning_game/buildings/Building33_light.png',
    'route_planning_game/buildings/Building34_light.png',
    'route_planning_game/buildings/Building35_light.png',
    'route_planning_game/buildings/Building36_light.png',
    'route_planning_game/buildings/Building37_light.png',
    'route_planning_game/buildings/Building38_light.png',
    'route_planning_game/buildings/Building39_light.png',
    'route_planning_game/buildings/Building40_light.png',
  ];

  //* hints
  static const errorHint = 'route_planning_game/hints/error_hint.png';
  static const repeatedHint = 'route_planning_game/hints/repeated_hint.png';

  static const flagImagePath = 'route_planning_game/buildings/Flag.png';

  static const Map<int, int> numberOfBuildings = {
    1: 6,
    2: 8,
    3: 8,
    4: 8,
    5: 10,
  };
  static const Map<int, int> numberOfTargets = {
    1: 3,
    2: 3,
    3: 4,
    4: 4,
    5: 4,
  };

  static const routeWin =
      'assets/images/route_planning_game/scene/Route_Win.png';
  static const routeLose =
      'assets/images/route_planning_game/scene/Route_Lose.png';

  //* sfx
  static const pickFlagAudio = 'route_planning_game/sfx/pick_flag.mp3';
  static const bgm = 'route_planning_game/sfx/bgm.mp3';
  static const winAudio = 'route_planning_game/sfx/win.mp3';
  static const loseAudio = 'route_planning_game/sfx/lose.mp3';
  static const tapWrongBuilding = 'route_planning_game/sfx/wrong_building.mp3';
  static const tictocAudio = 'route_planning_game/sfx/tictoc.mp3';
  static const phoneVibration = 'route_planning_game/sfx/phone_vibration2.mp3';

  //* instruction part
  static const gameRuleLevel1 = {
    'chinese':
        'audio/route_planning_game/instruction_record/chinese/level1.m4a',
    'taiwanese':
        'audio/route_planning_game/instruction_record/taiwanese/level1.m4a'
  };
  static const gameRuleLevel2 = {
    'chinese':
        'audio/route_planning_game/instruction_record/chinese/level2.m4a',
    'taiwanese':
        'audio/route_planning_game/instruction_record/taiwanese/level2.m4a'
  };
  static const gameRuleLevel3to5 = {
    'chinese':
        'audio/route_planning_game/instruction_record/chinese/level3to5.m4a',
    'taiwanese':
        'audio/route_planning_game/instruction_record/taiwanese/level3to5.m4a'
  };
}
