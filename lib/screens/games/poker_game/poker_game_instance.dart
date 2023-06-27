import 'package:cognitive_training/firebase/record_game.dart';
import 'package:logger/logger.dart';

class PokerCard {
  String suit;
  int rank;

  PokerCard(this.suit, this.rank);
}

class Deck {
  late List<PokerCard> cards;

  Deck() {
    cards = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 1; j <= 13; j++) {
        PokerCard card = PokerCard(_getSuit(i), j);
        cards.add(card);
      }
    }
  }

  String _getSuit(int index) {
    switch (index) {
      case 0:
        return 'Spades';
      case 1:
        return 'Hearts';
      case 2:
        return 'Diamonds';
      case 3:
        return 'Clubs';
      default:
        return '';
    }
  }

  void shuffle() {
    cards.shuffle();
  }

  PokerCard draw() {
    return cards.removeLast();
  }
}

class Player {
  late List<PokerCard> hand;

  Player() {
    hand = [];
  }

  void addCard(PokerCard card) {
    hand.add(card);
  }

  void showHand() {
    for (var card in hand) {
      print('${card.rank} of ${card.suit}');
    }
  }
}

class GameInstance {
  int gameLevel;
  List<int> responseTimeList;
  bool isTutorial;

  List<int> numberOfCards = [5, 6, 6, 8];
  String backgroundPath = 'assets/poker_game_scene/play_board.png';

  Player player = Player();
  Player computer = Player();
  late Deck deck;

  int opponentCoin = 10000;

  late DateTime start;
  late DateTime end;

  bool cardDealed = false;
  bool isPlayerTurn = false;
  late bool isPlayerWin;
  late bool isTie;

  PokerCard? playerCard;
  PokerCard? computerCard;
  late List<bool> isChosen;
  late List<bool> isChosenComputer;

  int continuousWin = 0;
  int continuousLose = 0;

  List<int> coinWin = [100, 200, 250, 300];
  List<int> coinLose = [100, 100, 150, 150];

  GameInstance(
      {required this.gameLevel,
      required this.responseTimeList,
      required this.isTutorial}) {
    deck = Deck();
    deck.shuffle();
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
    // reset isTie and isPlayerWin
    isTie = false;
    isPlayerWin = false;

    if (playerCard != null) {
      if (gameLevel > 1) {
        // suit the same or rank the same
        isPlayerWin = playerCard!.suit == computerCard!.suit ||
            playerCard!.rank == computerCard!.rank;
      } else {
        int playerRank = playerCard!.rank == 1 ? 14 : playerCard!.rank;
        int computerRank = computerCard!.rank == 1 ? 14 : computerCard!.rank;
        isPlayerWin = playerRank > computerRank ||
            (playerRank == computerRank &&
                suits.indexOf(playerCard!.suit) <
                    suits.indexOf(computerCard!.suit));
      }
    } else {
      // check if any of card in hand is winable
      for (PokerCard card in player.hand) {
        if (gameLevel > 1) {
          // suit the same or rank the same
          isTie = !(card.suit == computerCard!.suit ||
              card.rank == computerCard!.rank);
          if (!isTie) break;
        } else {
          int cardRank = card.rank == 1 ? 14 : card.rank;
          int computerRank = computerCard!.rank == 1 ? 14 : computerCard!.rank;
          isTie = !(cardRank > computerRank ||
              (cardRank == computerRank &&
                  suits.indexOf(card.suit) <
                      suits.indexOf(computerCard!.suit)));
          if (!isTie) break;
        }
      }
    }
    changeOpponentCoin();
    continuousWinLose();
    int resTime = end.difference(start).inMilliseconds;
    responseTimeList.add(resTime);
    responseTimeList.sort();
    if (responseTimeList.length > 50) {
      responseTimeList.removeAt(0);
      responseTimeList.removeLast();
    }
    recordGame();
  }

  void changeOpponentCoin() {
    if (isPlayerWin) {
      opponentCoin -= coinLose[gameLevel];
    } else {
      if (!isTie) opponentCoin += coinWin[gameLevel];
    }
  }

  void continuousWinLose() {
    if (isTie) {
    } else if (isPlayerWin) {
      continuousLose = 0;
      continuousWin++;
    } else {
      continuousWin = 0;
      continuousLose++;
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
    RecordPokerGame().recordGame(
      gameLevel: gameLevel,
      result: isTie
          ? 'Tie'
          : isPlayerWin
              ? 'Win'
              : 'Lose',
      start: start,
      end: end,
    );
  }

  int getTimeLimit() {
    switch (gameLevel) {
      case 0:
        return 10000;
      case 1:
        return responseTimeList[responseTimeList.length ~/ 2] + 3000;
      default:
        return responseTimeList[responseTimeList.length ~/ 2];
    }
  }

  String getRulePath() {
    String path = gameLevel <= 1 ? 'find_bigger.m4a' : 'find_the_same.m4a';
    return path;
  }
}
