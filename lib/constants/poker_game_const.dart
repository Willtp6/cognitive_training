import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PokerGameConst {
  PokerGameConst._();

  //* route planning game menu

  //* images

  static const menuBackground =
      'assets/images/poker_game/scene/menu_background.png';
  static const String backgroundImage =
      'assets/images/poker_game/scene/play_board.png';
  static const playerWinBackground =
      'assets/images/poker_game/scene/player_win.png';
  static const playerLoseBackground =
      'assets/images/poker_game/scene/player_lose.png';

  static const String cardBack = 'assets/images/poker_game/card/card_back.png';
  static const Map<String, List<String>> cardImageList = {
    'Spades': [
      'assets/images/poker_game/card/Spades_1.png',
      'assets/images/poker_game/card/Spades_2.png',
      'assets/images/poker_game/card/Spades_3.png',
      'assets/images/poker_game/card/Spades_4.png',
      'assets/images/poker_game/card/Spades_5.png',
      'assets/images/poker_game/card/Spades_6.png',
      'assets/images/poker_game/card/Spades_7.png',
      'assets/images/poker_game/card/Spades_8.png',
      'assets/images/poker_game/card/Spades_9.png',
      'assets/images/poker_game/card/Spades_10.png',
      'assets/images/poker_game/card/Spades_11.png',
      'assets/images/poker_game/card/Spades_12.png',
      'assets/images/poker_game/card/Spades_13.png'
    ],
    'Hearts': [
      'assets/images/poker_game/card/Hearts_1.png',
      'assets/images/poker_game/card/Hearts_2.png',
      'assets/images/poker_game/card/Hearts_3.png',
      'assets/images/poker_game/card/Hearts_4.png',
      'assets/images/poker_game/card/Hearts_5.png',
      'assets/images/poker_game/card/Hearts_6.png',
      'assets/images/poker_game/card/Hearts_7.png',
      'assets/images/poker_game/card/Hearts_8.png',
      'assets/images/poker_game/card/Hearts_9.png',
      'assets/images/poker_game/card/Hearts_10.png',
      'assets/images/poker_game/card/Hearts_11.png',
      'assets/images/poker_game/card/Hearts_12.png',
      'assets/images/poker_game/card/Hearts_13.png'
    ],
    'Diamonds': [
      'assets/images/poker_game/card/Diamonds_1.png',
      'assets/images/poker_game/card/Diamonds_2.png',
      'assets/images/poker_game/card/Diamonds_3.png',
      'assets/images/poker_game/card/Diamonds_4.png',
      'assets/images/poker_game/card/Diamonds_5.png',
      'assets/images/poker_game/card/Diamonds_6.png',
      'assets/images/poker_game/card/Diamonds_7.png',
      'assets/images/poker_game/card/Diamonds_8.png',
      'assets/images/poker_game/card/Diamonds_9.png',
      'assets/images/poker_game/card/Diamonds_10.png',
      'assets/images/poker_game/card/Diamonds_11.png',
      'assets/images/poker_game/card/Diamonds_12.png',
      'assets/images/poker_game/card/Diamonds_13.png'
    ],
    'Clubs': [
      'assets/images/poker_game/card/Clubs_1.png',
      'assets/images/poker_game/card/Clubs_2.png',
      'assets/images/poker_game/card/Clubs_3.png',
      'assets/images/poker_game/card/Clubs_4.png',
      'assets/images/poker_game/card/Clubs_5.png',
      'assets/images/poker_game/card/Clubs_6.png',
      'assets/images/poker_game/card/Clubs_7.png',
      'assets/images/poker_game/card/Clubs_8.png',
      'assets/images/poker_game/card/Clubs_9.png',
      'assets/images/poker_game/card/Clubs_10.png',
      'assets/images/poker_game/card/Clubs_11.png',
      'assets/images/poker_game/card/Clubs_12.png',
      'assets/images/poker_game/card/Clubs_13.png'
    ],
  };

  static const clock = 'assets/images/poker_game/scene/clock.png';
  static const questionLight =
      'assets/images/poker_game/scene/question_light.png';
  static const questionDark =
      'assets/images/poker_game/scene/question_dark.png';
  static const winFeedback = 'assets/images/poker_game/scene/win_feedback.png';
  static const loseFeedback =
      'assets/images/poker_game/scene/lose_feedback.png';

  //* game rule
  static const AutoSizeText getBigger = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請從牌中挑選出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '比我數字還大', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的牌！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '只要你在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(text: '找到這張牌就是你贏了！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: '如果牌裡面沒有比我數字還大的牌，請按下', style: TextStyle(color: Colors.black)),
        TextSpan(text: '「沒有」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的按鈕！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  static const AutoSizeText getSameRankOrSuit = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請從牌中挑選出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '數字或花色一樣', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的牌！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '只要你在', style: TextStyle(color: Colors.black)),
        TextSpan(text: '時限內', style: TextStyle(color: Colors.red)),
        TextSpan(text: '找到這張牌就是你贏了！', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: '如果牌裡面沒有跟我一樣數字或花色的牌，請按下',
            style: TextStyle(color: Colors.black)),
        TextSpan(text: '「沒有」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的按鈕！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );
  static const AutoSizeText getSizeRule = AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '比大小規則:', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(text: '黑桃>愛心>方塊>梅花', style: TextStyle(color: Colors.black)),
        TextSpan(text: '\n'),
        TextSpan(
            text: 'A>K>Q>J>10>9>8>7>6>5>4>3>2',
            style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 3,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );

  //* hints

  //* audio
  static const gameRuleFindBiggerAudio = {
    'chinese': 'audio/poker_game/instruction_record/chinese/find_bigger.m4a',
    'taiwanese':
        'audio/poker_game/instruction_record/taiwanese/find_bigger.m4a',
  };
  static const gameRuleFindTheSameAudio = {
    'chinese': 'audio/poker_game/instruction_record/chinese/find_the_same.m4a',
    'taiwanese':
        'audio/poker_game/instruction_record/taiwanese/find_the_same.m4a',
  };
  static const ticTokSfx = 'audio/poker_game/sfx/tictoc.mp3';
  static const winSfx = 'audio/poker_game/sfx/win_new.mp3';
  static const loseSfx = 'audio/poker_game/sfx/lose.mp3';
}
