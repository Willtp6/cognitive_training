import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Globals {
  Globals._();

  //* shared
  static const String orangeButton = "assets/images/shared/orange_button.png";
  static const String starLight = 'assets/images/shared/star_light.png';
  static const String starDark = 'assets/images/shared/star_dark.png';
  static const String clickButtonSound = 'audio/shared/click_button.wav';

  static AlertDialog exitDialog(
      {required Function continueCallback,
      required Function exitCallback,
      required bool isTutorialMode}) {
    Logger().d(isTutorialMode);
    return AlertDialog(
      title: const Center(
        child: Text(
          '確定要離開嗎?',
          style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
        ),
      ),
      // this part can put multiple messages
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Center(
              child: Text(
                isTutorialMode ? '直接離開會跳過教學模式喔!!!' : '遊戲將不會被記錄下來喔!!!',
                style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text(
            '確定離開',
            style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            exitCallback();
          },
        ),
        TextButton(
          child: Text(
            isTutorialMode ? '繼續教學' : '繼續遊戲',
            style: const TextStyle(fontFamily: 'GSR_B', fontSize: 30),
          ),
          onPressed: () {
            continueCallback();
          },
        ),
      ],
    );
  }

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

  //* tutorial mode
  static const tutorialDoctor = 'assets/login_page/tutorial_doctors.png';
}
