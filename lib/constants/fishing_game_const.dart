import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FishingGameConst {
  FishingGameConst._();
  //* game info
  static const List<int> numOfRods = [2, 3, 3, 4, 4];

  //* images
  static const String fishingGameMenu =
      'assets/images/fishing_game/scene/menu_and_result.png';
  static const String fishingGameBackground =
      'fishing_game/scene/rocky_shore.png';
  static const String fishingGameResult =
      'fishing_game/scene/menu_and_result.png';

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

  //* animation
  static const String rippleAnimation =
      'assets/images/fishing_game/ripple/ripple_animation.riv';

  //* audio
  static const bgmAudio = 'fishing_game/sound/bgm.mp3';
  static const bubbleAudio = 'fishing_game/sound/Bubbles.wav';
  static const winAudio = 'fishing_game/sound/fishing_win.mp3';
  static const loseAudio = 'fishing_game/sound/fishing_lose.mp3';

  //* tutorial mode
  static const dottedLineContaierAlignment = [
    Alignment(0.0, 0.15),
    Alignment(0.0, -0.85),
    Alignment(0.4, 0.825),
    Alignment(0.0, -0.2),
    Alignment(0.0, 0.85),
    Alignment(0.85, -0.25),
  ];

  static const List<double?> dottedLineContainerWFactor = [
    0.65,
    0.6,
    null,
    null,
    null,
    null,
  ];
  static const List<double> dottedLineContainerHFactor = [
    0.4,
    0.25,
    0.15,
    0.25,
    0.28,
    0.3,
  ];
  static const List<double> dottedLineContainerASRatio = [
    1,
    1,
    835 / 353,
    970 / 254,
    2750 / 641,
    1,
  ];
}
