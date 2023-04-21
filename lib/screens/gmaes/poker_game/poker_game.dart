import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/firebase/record_game.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'poker_game_instance.dart';

class PokerGame extends StatefulWidget {
  final startLevel;
  final isTutorial;
  const PokerGame(
      {super.key, required this.startLevel, required this.isTutorial});

  @override
  State<PokerGame> createState() => _PokerGameState();
}

class _PokerGameState extends State<PokerGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerChosenPlayer;
  late AnimationController _controllerChosenComputer;
  late AnimationController _controllerPlay;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controllerChosenPlayer = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerChosenComputer = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerPlay = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerChosenPlayer.dispose();
    _controllerPlay.dispose();
    super.dispose();
  }

  void dealCard() {
    deck.shuffle();
    for (int i = 0; i < numberOfCards[gameLevel]; i++) {
      player.addCard(deck.draw());
      computer.addCard(deck.draw());
    }
    isChosen = List.generate(numberOfCards[gameLevel], (index) => false);
    isChosenComputer =
        List.generate(numberOfCards[gameLevel], (index) => false);
    Timer(const Duration(seconds: 2), () {
      simulatePlayerAction();
    });
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

  void simulatePlayerAction() {
    //random 1-3 times choose card
    final int numberOfRandomChoice = Random().nextInt(3) + 1;
    int counter = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (counter < numberOfRandomChoice) {
          isChosenComputer.fillRange(0, isChosenComputer.length, false);
          isChosenComputer[Random().nextInt(5)] = true;
          counter++;
        } else {
          timer.cancel();
          isPlayerTurn = true;
          computerCard = computer.hand
              .removeAt(computer.hand.indexWhere((element) => true));
          isChosenComputer.fillRange(0, isChosenComputer.length, false);
          start = DateTime.now();
        }
      });
    });
  }

  void getResult() {
    end = DateTime.now();
    List<String> suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];
    isTie = false;
    isPlayerWin = false;

    if (playerCard != null) {
      if (gameLevel > 1) {
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
          isPlayerWin = !(card.rank > computerCard!.rank ||
              (card.rank == computerCard!.rank &&
                  suits.indexOf(card.suit) <
                      suits.indexOf(computerCard!.suit)));
          if (!isPlayerWin) break;
        }
      }
    }
    if (isTie || isPlayerWin) {
      continuousWin++;
    } else {
      continuousWin = 0;
    }
    RecordPokerGame().recordGame(
        end: end,
        gameLevel: gameLevel,
        result: isTie
            ? 'Tie'
            : isPlayerWin
                ? 'Win'
                : 'Lose',
        start: start);
    userInfoProvider.pokerGameDatabase =
        PokerGameDatabase(currentLevel: gameLevel, doneTutorial: true);
    Timer(const Duration(seconds: 1), () {
      _showGameEndDialog();
    });
  }

  void setNextGame() {
    if (continuousWin >= 5) {
      gameLevel++;
      continuousWin = 0;
    }
    setState(() {
      deck.cards.add(computerCard!);
      if (playerCard != null) deck.cards.add(playerCard!);
      playerCard = null;
      computerCard = null;
    });
    _controller.reverse().whenComplete(() {
      setState(() {
        reshuffleDeck();
        dealCard();
      });
      _controller.forward();
    });
  }

  int gameLevel = 0;
  int continuousWin = 0;
  bool cardDealed = false;
  bool isPlayerTurn = false;
  bool isPlayerWin = false;
  bool isTie = false;
  List<int> numberOfCards = [5, 6, 6, 8];
  late DateTime start, end;
  late UserInfoProvider userInfoProvider;

  Deck deck = Deck();
  Player player = Player();
  Player computer = Player();
  PokerCard? playerCard;
  PokerCard? computerCard;
  late List<bool> isChosen;
  late List<bool> isChosenComputer;

  @override
  Widget build(BuildContext context) {
    userInfoProvider = Provider.of<UserInfoProvider>(context);
    return SizedBox(
        child: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/poker_game_scene/play_board.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(flex: 8, child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < computer.hand.length; i++) ...[
                  SlideTransition(
                    position: isChosenComputer[i]
                        ? Tween(
                                begin: const Offset(0.0, -0.2),
                                end: const Offset(0.0, 0.0))
                            .animate(_controllerChosenComputer)
                        : Tween(
                                begin: const Offset(0.0, 0.0),
                                end: const Offset(0.0, -0.2))
                            .animate(_controllerChosenComputer),
                    child: Image.asset('assets/poker_game_card/card_back.png',
                        scale: 5,
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .chain(CurveTween(
                                curve: Interval(i / computer.hand.length,
                                    (i + 1) / computer.hand.length)))
                            .animate(_controller)),
                  ),
                ]
              ],
            ),
            Expanded(
                flex: 4,
                child: computerCard != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Transform(
                              //transform: Matrix4.skewX(-0.3),
                              alignment: FractionalOffset.center,
                              transform: Matrix4.identity()
                                ..rotateX(0.5)
                                ..rotateZ(0.5),
                              child: Image.asset(
                                'assets/poker_game_card/${computerCard!.suit}_${computerCard!.rank}.png',
                              ),
                            ),
                            if (playerCard != null)
                              Transform(
                                alignment: FractionalOffset.center,
                                transform: Matrix4.identity()
                                  ..rotateX(0.5)
                                  ..rotateZ(-0.5),
                                child: Image.asset(
                                  'assets/poker_game_card/${playerCard!.suit}_${playerCard!.rank}.png',
                                ),
                              ),
                          ])
                    : Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: isPlayerTurn
                      ? Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () {
                                getResult();
                              },
                              child: const Text('no')),
                        )
                      : Container(),
                ),
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
                                begin: const Offset(0.0, -0.2),
                                end: const Offset(0.0, 0.0))
                            .animate(_controllerChosenPlayer)
                        : Tween(
                                begin: const Offset(0.0, 0.0),
                                end: const Offset(0.0, -0.2))
                            .animate(_controllerChosenPlayer),
                    child: GestureDetector(
                      onTap: () {
                        if (isPlayerTurn) {
                          if (!isChosen[i]) {
                            setState(() {
                              isChosen.fillRange(0, isChosen.length, false);
                              isChosen[i] = true;
                            });
                          } else {
                            setState(() {
                              isPlayerTurn = false;
                              playerCard = player.hand.removeAt(i);
                              isChosen.fillRange(0, isChosen.length, false);
                              getResult();
                            });
                          }
                        }
                      },
                      child: Image.asset(
                          'assets/poker_game_card/${player.hand[i].suit}_${player.hand[i].rank}.png',
                          scale: 7,
                          opacity: Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(
                                  curve: Interval(i / player.hand.length,
                                      (i + 1) / player.hand.length)))
                              .chain(ReverseTween(Tween(begin: 1.0, end: 0.0)))
                              .animate(_controller)),
                    ),
                  ),
                ],
                Expanded(flex: 1, child: Container()),
              ],
            ),
            Expanded(flex: 2, child: Container()),
          ],
        ),
      ],
    ));
  }

  Future<void> _showGameEndDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('結果發表'),
          // this part can put multiple messages
          content: isTie
              ? const Text('本局平手')
              : isPlayerWin
                  ? const Text('你贏得遊戲了!!!')
                  : const Text('真可惜下次努力吧'),
          actions: <Widget>[
            TextButton(
              child: const Text('回到選單'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('繼續下一場遊戲'),
              onPressed: () {
                setNextGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
