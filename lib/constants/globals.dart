import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Globals {
  Globals._();

  //* shared
  static const String orangeButton = "assets/images/shared/orange_button.png";
  static const String starLight = 'assets/images/shared/star_light.png';
  static const String starDark = 'assets/images/shared/star_dark.png';
  static const String clickButtonSound = 'audio/shared/click_button.wav';

  //* home page
  static const List<String> gameImagePaths = [
    'assets/images/home_page/choosing_game_lottery.png',
    'assets/images/home_page/choosing_game_fishing.png',
    'assets/images/home_page/choosing_game_poker.png',
    'assets/images/home_page/choosing_game_route.png',
  ];
  static const List<String> gameName = [
    '樂透彩券',
    '釣魚',
    '撲克牌',
    '路線規劃',
  ];
  static const List<String> gameDescription = [
    '廟裡的神明會給你一組樂透彩券號碼，將號碼記憶下來，去彩券行下注贏取獎金!想成為樂透得主嗎？那就試著記下中獎號碼吧！',
    '到海邊釣魚，水面上漣漪越大，水底下的魚越大。選擇正確的釣竿，一起來釣大魚吧！',
    '公園散步巧遇朋友，展開一場撲克牌遊戲，想在這場遊戲中勝利，就要選擇適合的牌打出去！一起來挑戰吧！',
    '接到家人的電話請求幫忙出門辦事。請用最快的速度完成家人交辦的各項任務，再回到家中！我們出發吧！',
  ];
  static const List<String> gameTrainingArea = [
    '注意力/工作記憶',
    '執行功能',
    '注意力',
    '執行功能',
  ];
  static const List<String> gameRoutes = [
    '/home/lottery_game_menu',
    '/home/fishing_game_menu',
    '/home/poker_game_menu',
    '/home/route_planning_game_menu',
  ];

  //* fishing game
  static const String fishingGameMenu =
      'assets/fishing_game/scene/menu_and_result.png';
  static const String fishingGameBackground =
      'fishing_game/scene/rocky_shore.png';
  static const String fishingGameResult =
      'fishing_game/scene/menu_and_result.png';
  static const List<int> numOfRods = [2, 3, 3, 4, 4];

  static const List<String> rodList = [
    'fishing_game/rod/rod1.png',
    'fishing_game/rod/rod2.png',
    'fishing_game/rod/rod3.png',
    'fishing_game/rod/rod4.png',
  ];
  static const List<String> rodLightList = [
    'fishing_game/rod/rod1_L.png',
    'fishing_game/rod/rod2_L.png',
    'fishing_game/rod/rod3_L.png',
    'fishing_game/rod/rod4_L.png',
  ];
  static const String rippleAnimation =
      'assets/images/fishing_game/ripple/ripple_animation.riv';
  static const AutoSizeText fishingGameRule = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請找出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '「最大」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的水波紋，釣到大魚！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 1,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  static const Map<String, List<String>> fishesImages = {
    "C": [
      'fishing_game/fish/Fish_rankC1.png',
      'fishing_game/fish/Fish_rankC2.png',
      'fishing_game/fish/Fish_rankC3.png',
      'fishing_game/fish/Fish_rankC4.png',
      'fishing_game/fish/Fish_rankC5.png',
      'fishing_game/fish/Fish_rankC6.png',
      'fishing_game/fish/Fish_rankC7.png',
      'fishing_game/fish/Fish_rankC8.png',
    ],
    "B": [
      'fishing_game/fish/Fish_rankB1.png',
      'fishing_game/fish/Fish_rankB2.png',
      'fishing_game/fish/Fish_rankB3.png',
      'fishing_game/fish/Fish_rankB4.png',
      'fishing_game/fish/Fish_rankB5.png',
      'fishing_game/fish/Fish_rankB6.png',
      'fishing_game/fish/Fish_rankB7.png',
    ],
    "A": [
      'fishing_game/fish/Fish_rankA1.png',
      'fishing_game/fish/Fish_rankA2.png',
      'fishing_game/fish/Fish_rankA3.png',
      'fishing_game/fish/Fish_rankA4.png',
      'fishing_game/fish/Fish_rankA5.png',
      'fishing_game/fish/Fish_rankA6.png',
      'fishing_game/fish/Fish_rankA7.png',
    ],
  };
  static const String fishingResultBackGround =
      "fishing_game/scene/reward_background.png";
  static const String fishingResultEmptyRod = "fishing_game/rod/rod_empty.png";

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
  //* route planning game
  static const targetList = 'route_planning_game/scene/targetLabel.png';
  static const riderLeft = 'route_planning_game/scene/rider_left.png';
  static const riderRight = 'route_planning_game/scene/rider_right.png';
  static const List<String> buildings = [
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
}
