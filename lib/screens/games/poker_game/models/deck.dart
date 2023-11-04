import 'poker_card.dart';

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
