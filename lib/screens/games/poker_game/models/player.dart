import 'poker_card.dart';

class Player {
  late List<PokerCard> hand;

  Player() {
    hand = [];
  }

  void addCard(PokerCard card) {
    hand.add(card);
  }
}
