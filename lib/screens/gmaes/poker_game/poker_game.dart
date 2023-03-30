import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'poker_game_instance.dart';

class PokerGame extends StatefulWidget {
  const PokerGame({super.key});

  @override
  State<PokerGame> createState() => _PokerGameState();
}

class _PokerGameState extends State<PokerGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosen;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controllerChosen = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosen.dispose();
    super.dispose();
  }

  void dealCard() {
    deck.shuffle();
    for (int i = 0; i < 5; i++) {
      player.addCard(deck.draw());
      computer.addCard(deck.draw());
    }
    isChosen = List.generate(5, (index) => false);
  }

  void reshuffleDeck() {
    deck.cards
      ..addAll(player.hand)
      ..addAll(computer.hand);
    player.hand.clear();
    computer.hand.clear();
    deck.shuffle();
  }

  void shuffleDeck() {
    deck.shuffle();
  }

  int gameLevel = 0;
  int continuousWin = 0;
  bool cardDealed = false;
  Deck deck = Deck();
  Player player = Player();
  Player computer = Player();
  late List<bool> isChosen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/poker_game_scene/play_board.png'),
                fit: BoxFit.fill),
          ),
        ),
        Column(
          children: [
            Expanded(flex: 8, child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < player.hand.length; i++) ...[
                  Image.asset(
                      'assets/poker_game_card/${computer.hand[i].suit}_${computer.hand[i].rank}.png',
                      scale: 6,
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(
                              curve: Interval(i / computer.hand.length,
                                  (i + 1) / computer.hand.length)))
                          .animate(_controller)),
                ]
              ],
            ),
            Expanded(flex: 4, child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!cardDealed) ...[
                  ElevatedButton(
                    onPressed: () {
                      cardDealed = true;
                      dealCard();
                      setState(() {});
                      _controller.reset();
                      _controller.forward();
                    },
                    child: const Text('發牌'),
                  ),
                ],
                for (int i = 0; i < player.hand.length; i++) ...[
                  SlideTransition(
                    position: isChosen[i]
                        ? Tween(
                                begin: const Offset(0.0, 0.0),
                                end: const Offset(0.0, 0.2))
                            .animate(_controllerChosen)
                        : Tween(
                                begin: const Offset(0.0, 0.2),
                                end: const Offset(0.0, 0.0))
                            .animate(_controllerChosen),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isChosen.fillRange(0, isChosen.length, false);
                          isChosen[i] = true;
                        });
                      },
                      child: Image.asset(
                          'assets/poker_game_card/${player.hand[i].suit}_${player.hand[i].rank}.png',
                          scale: 6,
                          opacity: Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(
                                  curve: Interval(i / player.hand.length,
                                      (i + 1) / player.hand.length)))
                              .animate(_controller)),
                    ),
                  ),
                ]
              ],
            ),
            Expanded(flex: 2, child: Container()),
          ],
        ),
      ],
    ));
  }
}
