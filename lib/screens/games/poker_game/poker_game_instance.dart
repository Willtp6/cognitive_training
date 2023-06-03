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
  List<int> numberOfCards = [5, 6, 6, 8];

  Player player = Player();
  Player computer = Player();
  late Deck deck;

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

  GameInstance({required this.gameLevel}) {
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
    isTie = false;
    isPlayerWin = false;

    if (playerCard != null) {
      if (gameLevel > 1) {
        // suit the same or rank the same
        isPlayerWin = playerCard!.suit == computerCard!.suit ||
            playerCard!.rank == computerCard!.rank;
      } else {
        isPlayerWin = playerCard!.rank > computerCard!.rank ||
            (playerCard!.rank == computerCard!.rank &&
                suits.indexOf(playerCard!.suit) <
                    suits.indexOf(computerCard!.suit));
      }
    } else {
      // check if any of card in hand is winable
      for (PokerCard card in player.hand) {
        if (gameLevel > 1) {
          isTie = !(card.suit == computerCard!.suit ||
              card.rank == computerCard!.rank);
          if (!isTie) break;
        } else {
          isTie = !(card.rank > computerCard!.rank ||
              (card.rank == computerCard!.rank &&
                  suits.indexOf(card.suit) <
                      suits.indexOf(computerCard!.suit)));
          if (!isTie) break;
        }
      }
    }
    continuousWinLose();
    recordGame();
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
      if (gameLevel < 3) gameLevel++;
      continuousWin = 0;
      continuousLose = 0;
      return 1;
    }
    if (continuousLose >= 5) {
      if (gameLevel > 0) gameLevel--;
      continuousWin = 0;
      continuousLose = 0;
      return 2;
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
}
