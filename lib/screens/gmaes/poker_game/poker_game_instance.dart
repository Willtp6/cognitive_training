class Card {
  String suit;
  int rank;

  Card(this.suit, this.rank);
}

class Deck {
  late List<Card> cards;

  Deck() {
    cards = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 1; j <= 13; j++) {
        Card card = Card(_getSuit(i), j);
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

  Card draw() {
    return cards.removeLast();
  }
}

class Player {
  late List<Card> hand;

  Player() {
    hand = [];
  }

  void addCard(Card card) {
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
        Card card = deck.draw();
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
