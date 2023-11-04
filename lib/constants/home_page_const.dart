class HomePageConst {
  HomePageConst._();
  //* images
  static const choosingGameBanner =
      'assets/images/home_page/choosing_game_banner.png';
  static const choosingGameTitle =
      'assets/images/home_page/choosing_game_title.png';

  static const List<String> gameImagePaths = [
    'assets/images/home_page/choosing_game_lottery.png',
    'assets/images/home_page/choosing_game_fishing.png',
    'assets/images/home_page/choosing_game_poker.png',
    'assets/images/home_page/choosing_game_route.png',
  ];

  //* strings
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

  //* audios
  static const gameDescriptionAudio = [
    {
      'chinese': 'audio/home_page/chinese/lottery_game_description.m4a',
      'taiwanese': 'audio/home_page/taiwanese/lottery_game_description.m4a',
    },
    {
      'chinese': 'audio/home_page/chinese/fishing_game_description.m4a',
      'taiwanese': 'audio/home_page/taiwanese/fishing_game_description.m4a',
    },
    {
      'chinese': 'audio/home_page/chinese/poker_game_description.m4a',
      'taiwanese': 'audio/home_page/taiwanese/poker_game_description.m4a',
    },
    {
      'chinese': 'audio/home_page/chinese/route_planning_game_description.m4a',
      'taiwanese':
          'audio/home_page/taiwanese/route_planning_game_description.m4a',
    },
  ];

  static const tutorialAudio = [
    {
      'chinese': 'audio/home_page/chinese/tutorial/step1.m4a',
      'taiwanese': 'audio/home_page/taiwanese/tutorial/step1.m4a',
    },
    {
      'chinese': 'audio/home_page/chinese/tutorial/step2.m4a',
      'taiwanese': 'audio/home_page/taiwanese/tutorial/step2.m4a',
    },
    {
      'chinese': 'audio/home_page/chinese/tutorial/step3.m4a',
      'taiwanese': 'audio/home_page/taiwanese/tutorial/step3.m4a',
    },
  ];
}
