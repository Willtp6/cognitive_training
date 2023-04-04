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

class Game {
  late List<Player> players;
  late Deck deck;

  Game() {
    players = [];
    deck = Deck();
    deck.shuffle();
  }

  void addPlayer(Player player) {
    players.add(player);
  }

  void dealCards() {
    for (int i = 0; i < 2; i++) {
      for (var player in players) {
        PokerCard card = deck.draw();
        player.addCard(card);
      }
    }
  }

  void play() {
    dealCards();
    for (var player in players) {
      player.showHand();
    }
  }
}
