import 'package:cognitive_training/constants/poker_game_const.dart';
import 'package:cognitive_training/firebase/record_game.dart';
import 'package:logger/logger.dart';

import 'models/deck.dart';
import 'models/player.dart';
import 'models/poker_card.dart';

enum ResultType {
  none,
  win,
  tie,
  lose,
}

class GameInstance {
  int gameLevel;
  List<int> responseTimeList;
  bool isTutorial;
  int continuousWin;
  int continuousLose;

  List<int> numberOfCards = [5, 6, 6, 8];
  String backgroundPath = PokerGameConst.backgroundImage;

  Player player = Player();
  Player computer = Player();
  late Deck deck;

  int opponentCoin = 10000;

  late DateTime start;
  late DateTime end;

  bool cardDealed = false;
  bool isPlayerTurn = false;
  ResultType resultType = ResultType.none;

  PokerCard? playerCard;
  PokerCard? computerCard;
  late List<bool> isChosen;
  late List<bool> isChosenComputer;

  final List<int> coinWin = [100, 200, 250, 300];
  final List<int> coinLose = [100, 100, 150, 150];

  GameInstance(
      {required this.gameLevel,
      required this.continuousWin,
      required this.continuousLose,
      required this.responseTimeList,
      required this.isTutorial}) {
    deck = Deck()..shuffle();
  }

  void dealCards() {
    Logger().d(gameLevel);
    deck.shuffle();
    for (int i = 0; i < numberOfCards[gameLevel]; i++) {
      player.addCard(deck.draw());
      computer.addCard(deck.draw());
    }
    int numOfCards = numberOfCards[gameLevel];
    isChosen = List.generate(numOfCards, (index) => false);
    isChosenComputer = List.generate(numOfCards, (index) => false);
  }

  void putBack() {
    deck.cards.add(computerCard!);
    if (playerCard != null) {
      deck.cards.add(playerCard!);
    }
    playerCard = null;
    computerCard = null;
  }

  void shuffleBack() {
    deck.cards
      ..addAll(player.hand)
      ..addAll(computer.hand);
    player.hand.clear();
    computer.hand.clear();
    deck.shuffle();
  }

  void getResult() {
    end = DateTime.now();
    List<String> suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];
    resultType = ResultType.none;

    if (playerCard != null) {
      if (gameLevel > 1) {
        // suit the same or rank the same
        if (playerCard!.rank == computerCard!.rank ||
            playerCard!.suit == computerCard!.suit) {
          resultType = ResultType.win;
        } else {
          resultType = ResultType.lose;
        }
      } else {
        int playerRank = playerCard!.rank == 1 ? 14 : playerCard!.rank;
        int computerRank = computerCard!.rank == 1 ? 14 : computerCard!.rank;
        int playerSuitIndex = suits.indexOf(playerCard!.suit);
        int computerSuitIndex = suits.indexOf(computerCard!.suit);
        if (playerRank > computerRank ||
            (playerRank == computerRank &&
                playerSuitIndex < computerSuitIndex)) {
          resultType = ResultType.win;
        } else {
          resultType = ResultType.lose;
        }
      }
    } else {
      // check if any of card in hand is winable
      for (PokerCard card in player.hand) {
        if (gameLevel > 1) {
          // suit the same or rank the same
          if (card.suit == computerCard!.suit ||
              card.rank == computerCard!.rank) {
            resultType = ResultType.lose;
            break;
          } else {
            resultType = ResultType.tie;
          }
        } else {
          int cardRank = card.rank == 1 ? 14 : card.rank;
          int computerRank = computerCard!.rank == 1 ? 14 : computerCard!.rank;
          int playerSuitIndex = suits.indexOf(card.suit);
          int computerSuitIndex = suits.indexOf(computerCard!.suit);
          if (cardRank > computerRank ||
              (cardRank == computerRank &&
                  playerSuitIndex < computerSuitIndex)) {
            resultType = ResultType.lose;
            break;
          } else {
            resultType = ResultType.tie;
          }
        }
      }
    }
    continuousWinLose();
    int resTime = end.difference(start).inMilliseconds;
    responseTimeList.add(resTime);
    responseTimeList.sort();
    if (responseTimeList.length > 100) {
      responseTimeList.removeAt(0);
      responseTimeList.removeLast();
    }
    recordGame();
  }

  void continuousWinLose() {
    switch (resultType) {
      case ResultType.none:
        break;
      case ResultType.win:
        continuousLose = 0;
        continuousWin++;
        break;
      case ResultType.tie:
        break;
      case ResultType.lose:
        continuousWin = 0;
        continuousLose++;
        break;
    }
  }

  int gameLevelChange() {
    if (continuousWin >= 5) {
      continuousWin = 0;
      continuousLose = 0;
      if (gameLevel < 3) {
        gameLevel++;
        return 1;
      }
    }
    if (continuousLose >= 5) {
      continuousWin = 0;
      continuousLose = 0;
      if (gameLevel > 0) {
        gameLevel--;
        return 2;
      }
    }
    return 0;
  }

  void recordGame() {
    end = DateTime.now();
    final results = {
      ResultType.win: 'Win',
      ResultType.tie: 'Tie',
      ResultType.lose: 'Lose',
    };
    RecordGame.recordPokerGame(
      gameLevel: gameLevel,
      result: results[resultType] ?? 'error',
      start: start,
      end: end,
      computerSuit: computerCard!.suit,
      computerRank: computerCard!.rank.toString(),
      playerSuit: playerCard?.suit ?? 'no card',
      playerRank: playerCard?.rank.toString() ?? 'no card',
    );
  }

  int getTimeLimit() {
    switch (gameLevel) {
      case 0:
        return 20000;
      case 1:
        return responseTimeList[responseTimeList.length ~/ 2] + 8000;
      case 2:
        return responseTimeList[responseTimeList.length ~/ 2] + 5000;
      case 3:
        return responseTimeList[responseTimeList.length ~/ 2] + 3000;
      default:
        return responseTimeList[responseTimeList.length ~/ 2];
    }
  }

  Map<String, String> getRulePath() {
    return gameLevel <= 1
        ? PokerGameConst.gameRuleFindBiggerAudio
        : PokerGameConst.gameRuleFindTheSameAudio;
  }
}
