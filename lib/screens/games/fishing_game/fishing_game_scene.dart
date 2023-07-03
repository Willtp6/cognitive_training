import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/games/fishing_game/fishing_game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class FishingGameScene extends StatefulWidget {
  const FishingGameScene({super.key});

  @override
  State<FishingGameScene> createState() => _FishingGameStateScene();
}

class _FishingGameStateScene extends State<FishingGameScene> {
  late FishingGame _game;
  late AudioController _audioController;
  late UserInfoProvider _userInfoProvider;

  List<Timer?> _timerList = [];

  /// Controller for playback
  late RiveAnimationController _riveController1;
  late RiveAnimationController _riveController2;
  late RiveAnimationController _riveController3;
  late RiveAnimationController _riveController4;

  List<RiveAnimationController> _riveControllers = [];

  /// Is the animation currently playing?
  bool _isPlaying1 = false;
  bool _isPlaying2 = false;
  bool _isPlaying3 = false;
  bool _isPlaying4 = false;

  List<double?> rippleWFactor = [];
  List<Alignment> rippleAlignments = [
    const Alignment(-0.275, 0.7),
    const Alignment(0.275, 0.7),
    const Alignment(-0.85, -0.1),
    const Alignment(0.9, -0.1),
  ];

  int ansRod = 5;

  @override
  void initState() {
    super.initState();
    _game = FishingGame(gameLevel: 2, isTutorial: false);
    _riveController1 = OneShotAnimation(
      'animation',
      autoplay: false,
      onStop: () => setState(() => _isPlaying1 = false),
      onStart: () => setState(() => _isPlaying1 = true),
    );
    _riveController2 = OneShotAnimation(
      'animation',
      autoplay: false,
      onStop: () => setState(() => _isPlaying2 = false),
      onStart: () => setState(() => _isPlaying2 = true),
    );
    _riveController3 = OneShotAnimation(
      'animation',
      autoplay: false,
      onStop: () => setState(() => _isPlaying3 = false),
      onStart: () => setState(() => _isPlaying3 = true),
    );
    _riveController4 = OneShotAnimation(
      'animation',
      autoplay: false,
      onStop: () => setState(() => _isPlaying4 = false),
      onStart: () => setState(() => _isPlaying4 = true),
    );
    _riveControllers
      ..add(_riveController1)
      ..add(_riveController2)
      ..add(_riveController3)
      ..add(_riveController4);
  }

  @override
  void dispose() {
    cancelAllTimer();
    super.dispose();
  }

  void cancelAllTimer() {
    for (var timer in _timerList) {
      timer?.cancel();
    }
  }

  void startGame() {
    setState(() {
      _game.endFishing = false;
      _game.startFishing = true;
      _game.setGame();
      //* the w factor is in range 0.15 ~ 0.20 for garbage
      //* and  0.28 ~ 0.33 for the fish
      rippleWFactor = List.generate(
          _game.getNumOfRods(), (_) => Random().nextDouble() / 20 + 0.15);
      rippleWFactor[_game.rodWithFish] = Random().nextDouble() / 20 + 0.28;
    });
    //* reset all timer
    cancelAllTimer();
    _timerList.clear();
    //* add timer for each rod
    int addCounter = 0;
    while (addCounter < _game.getNumOfRods()) {
      //* radomly give a initial offset for showing ripple
      Timer(Duration(milliseconds: Random().nextInt(1000)), () {
        //* remember the index for each timer
        //* therefore it can cancel itself when run out of the repeat time
        int timerInList = _timerList.length;
        _timerList.add(Timer.periodic(
            Duration(milliseconds: Random().nextInt(1000) + 1500), (timer) {
          //* activate the timer
          _riveControllers[timerInList].isActive = true;
          //* cancel it self
          if (_game.gameLevel > 1 &&
              --_game.remainingRepeatedTime[timerInList] == 0) {
            _timerList[timerInList]?.cancel();
          }
        }));
      });
      addCounter++;
    }
    Logger().d(_timerList.length);
    for (var rod in _game.rodList) {
      Logger().i(rod.type);
      Logger().i(rod.rank);
      Logger().i(rod.id);
    }
    Logger().i(_game.rodWithFish);
  }

  bool isTutorialModePop() {
    return _game.isTutorial;
  }

  //* this function should get the result of the fishing
  void fishingRodCallback(int rodNumber) {
    Logger().d(rodNumber);
    //* cancel all timer first
    cancelAllTimer();
    //* change to result page
    setState(() {
      ansRod = rodNumber;
      _game.startFishing = false;
      _game.endFishing = true;
    });
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      _showGameEndDialog();
      setState(() {
        ansRod = 5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _audioController = context.read<AudioController>();
    _userInfoProvider = context.read<UserInfoProvider>();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _audioController.pauseAudio();
          if (isTutorialModePop()) {
            return await _showSkipTutorialDialog();
          } else {
            return await _showAlertDialog();
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _game.startFishing
                    ? const AssetImage(
                        'assets/fishing_game/scene/rocky_shore.png')
                    : const AssetImage(
                        'assets/fishing_game/scene/menu_and_result.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                topCoin(),
                for (int i = 0; i < _game.getNumOfRods(); i++) ...[
                  IgnorePointer(
                    child: Align(
                      alignment: rippleAlignments[i],
                      child: FractionallySizedBox(
                        widthFactor:
                            rippleWFactor.isNotEmpty ? rippleWFactor[i] : 0,
                        child: AspectRatio(
                          aspectRatio: 2,
                          child: RiveAnimation.asset(
                            'assets/fishing_game/ripple/ripple_test4.riv',
                            animations: const ['idle'],
                            controllers: [_riveControllers[i]],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                AnimatedOpacity(
                  opacity: _game.startFishing ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: FishingRods(
                    numOfRods: _game.getNumOfRods(),
                    callback: fishingRodCallback,
                  ),
                ),
                RuleScreen(
                  game: _game,
                  audioController: _audioController,
                  callback: startGame,
                ),
                if (_game.startFishing || _game.endFishing) ...[
                  for (int i = 0; i < _game.getNumOfRods(); i++) ...[
                    IgnorePointer(
                      child: Align(
                        child: AnimatedOpacity(
                          opacity: i == ansRod ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedFractionallySizedBox(
                            heightFactor: i == ansRod ? 0.8 : 0.0,
                            widthFactor: i == ansRod ? 0.8 : 0.0,
                            duration: const Duration(milliseconds: 700),
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/fishing_game/scene/reward_background.png'),
                                ),
                              ),
                              child: FractionallySizedBox(
                                heightFactor: 0.9,
                                child: Column(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: FractionallySizedBox(
                                          widthFactor: 0.6,
                                          child: Placeholder()),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: Image.asset(
                                        _game.rodList[i].type == 'fish'
                                            ? 'assets/fishing_game/fish/Fish_rank${_game.rodList[i].rank}${_game.rodList[i].id}.png'
                                            : 'assets/fishing_game/garbage/garbage_${_game.rodList[i].id}.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                exitButton(),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   // disable the button while playing the animation
          //   onPressed: _isPlaying1
          //       ? null
          //       : () {
          //           _riveController1.isActive = true;
          //           counter++;
          //           if (counter == 4) counter = 0;
          //         },
          //   tooltip: 'Play',
          //   child: const Icon(Icons.arrow_upward),
          // ),
        ),
      ),
    );
  }

  IgnorePointer topCoin() {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0.05, -0.95),
        child: FractionallySizedBox(
          widthFactor: 0.12,
          heightFactor: 0.1,
          child: Consumer<UserInfoProvider>(
            builder: (context, value, child) {
              return AutoSizeText(
                value.coins.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withOpacity(_game.startFishing ? 1 : 0),
                  fontSize: 100,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Align exitButton() {
    return Align(
      alignment: const Alignment(-0.95, -0.9),
      child: FractionallySizedBox(
        widthFactor: 0.5 * 1 / 7,
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () async {
              if (isTutorialModePop()) {
                if (await _showSkipTutorialDialog()) context.pop();
              } else {
                if (await _showAlertDialog()) context.pop();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink,
                border: Border.all(color: Colors.black, width: 1),
                shape: BoxShape.circle,
              ),
              child: FractionallySizedBox(
                heightFactor: 0.8,
                widthFactor: 0.8,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double iconSize = constraints.maxWidth;
                    return Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: iconSize,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showAlertDialog() async {
    _audioController.pauseAudio();
    bool shouldPop = false;
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '確定要離開嗎?',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Center(
                  child: Text(
                    '遊戲將不會被記錄下來喔!!!',
                    style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //game.isPaused = false;
                _audioController.resumeAudio();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                '確定離開',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => shouldPop = value);
    return shouldPop;
  }

  Future<bool> _showSkipTutorialDialog() async {
    _audioController.pauseAudio();
    bool shouldPop = false;
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '確定要離開嗎?',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Center(
                  child: Text(
                    '要退出教學模式嗎?',
                    style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '繼續教學',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //audioController.resumeAudio();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                '確定離開',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                //audioController.stopAudio();
                _userInfoProvider.pokerGameDoneTutorial();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => shouldPop = value);
    return shouldPop;
  }

  Future<void> _showGameEndDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '本局結束',
              style: TextStyle(fontFamily: 'GSR_B', fontSize: 40),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text(
                '回到選單',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '繼續遊戲',
                style: TextStyle(fontFamily: 'GSR_B', fontSize: 30),
              ),
              onPressed: () {
                startGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class RuleScreen extends StatefulWidget {
  const RuleScreen({
    super.key,
    required this.game,
    required this.audioController,
    //required this.lotteryGameTutorial,
    required this.callback,
  });

  final FishingGame game;
  final AudioController audioController;
  //final LotteryGameTutorial lotteryGameTutorial;
  final Function() callback;

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  List<Alignment> starPosition = [
    const Alignment(-1.0, -0.6),
    const Alignment(-0.5, -0.85),
    const Alignment(0.0, -1.0),
    const Alignment(0.5, -0.85),
    const Alignment(1.0, -0.6),
  ];
  String starLight = 'assets/global/star_light.png';
  String starDark = 'assets/global/star_dark.png';

  final rule = const AutoSizeText.rich(
    TextSpan(
      children: [
        TextSpan(text: '請找出', style: TextStyle(color: Colors.black)),
        TextSpan(text: '「最大」', style: TextStyle(color: Colors.red)),
        TextSpan(text: '的水波紋，釣到大魚！', style: TextStyle(color: Colors.black)),
      ],
    ),
    softWrap: true,
    maxLines: 1,
    style: TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: IgnorePointer(
          ignoring: widget.game.startFishing || widget.game.endFishing,
          child: AnimatedOpacity(
            opacity:
                widget.game.startFishing || widget.game.endFishing ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.blue
                        .withOpacity(widget.game.isTutorial ? 0.3 : 1),
                    width: 5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    //difficultyStars(),
                    for (int i = 0; i < 5; i++) ...[
                      Align(
                        alignment: starPosition[i],
                        child: FractionallySizedBox(
                          widthFactor: 0.2,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(i <= widget.game.gameLevel
                                ? starLight
                                : starDark),
                          ),
                        ),
                      ),
                    ],
                    //difficultyLabel(),
                    gameRule(),
                    Align(
                      alignment: const Alignment(0.0, 0.9),
                      child: FractionallySizedBox(
                        heightFactor: 0.15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _listenAgainButton(),
                            _startGameButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget gameRule() {
    return Align(
      alignment: const Alignment(0.0, 0.3),
      child: FractionallySizedBox(
        heightFactor: 0.25,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Center(
            child: rule,
          ),
        ),
      ),
    );
  }

  // Align difficultyLabel() {
  //   return Align(
  //     alignment: const Alignment(0.0, 0.0),
  //     child: FractionallySizedBox(
  //       heightFactor: 0.15,
  //       widthFactor: 0.5,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Flexible(
  //             flex: 3,
  //             child: AutoSizeText(
  //               '難度${difficulties[widget.game.gameLevel]} ',
  //               style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  //               maxFontSize: 100,
  //               minFontSize: 5,
  //               stepGranularity: 5,
  //               maxLines: 1,
  //             ),
  //           ),
  //           Flexible(
  //             flex: 5,

  //               child: AutoSizeText(
  //                 '號碼數量${widget.game.numberOfDigits}',
  //                 style: const TextStyle(fontSize: 100, fontFamily: 'GSR_B'),
  //                 maxFontSize: 100,
  //                 minFontSize: 5,
  //                 stepGranularity: 5,
  //                 maxLines: 1,
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Flexible _startGameButton() {
    return Flexible(
      flex: 1,
      child: Center(
        child: AspectRatio(
          aspectRatio: 835 / 353,
          child: GestureDetector(
            onTap: widget.game.isTutorial
                ? null
                : () {
                    widget.audioController.stopAudio();
                    widget.callback();
                  },
            child: Image.asset(
              'assets/lottery_game_scene/start_button.png',
            ),
          ),
        ),
      ),
    );
  }

  Flexible _listenAgainButton() {
    return Flexible(
      flex: 1,
      child: Center(
        child: AspectRatio(
          aspectRatio: 835 / 353,
          child: GestureDetector(
            onTap: widget.game.isTutorial
                ? null
                : () {
                    //String path = widget.game.getInstructionAudioPath();
                    //widget.audioController.playInstructionRecord(path);
                  },
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/global/continue_button.png',
                  ),
                ),
                const Center(
                  child: FractionallySizedBox(
                    heightFactor: 0.8,
                    widthFactor: 0.8,
                    child: Center(
                      child: AutoSizeText(
                        '再聽一次',
                        style: TextStyle(
                          fontFamily: 'GSR_B',
                          fontSize: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FishingRods extends StatefulWidget {
  final int numOfRods;
  Function callback;
  FishingRods({super.key, required this.numOfRods, required this.callback});

  @override
  State<FishingRods> createState() => _FishingRodsState();
}

class _FishingRodsState extends State<FishingRods> {
  List<Alignment> fishingRodAlgnment = [
    const Alignment(-0.425, 2),
    const Alignment(0.425, 2),
    const Alignment(-1.1, -0.8),
    const Alignment(1.1, -0.8),
  ];
  List<double?> fishingRodWFactor = [0.2, 0.2, 0.25, 0.25];
  List<double?> fishingRodHFactor = [0.8, 0.8, 0.6, 0.6];
  List<double?> detectorWFactor = [0.15, 0.15, 0.25, 0.25];
  List<double?> detectorHFactor = [0.8, 0.8, 0.45, 0.45];

  List<bool> isChosen = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < widget.numOfRods; i++) ...[
          Align(
            alignment: fishingRodAlgnment[i],
            child: FractionallySizedBox(
              heightFactor: fishingRodHFactor[i],
              widthFactor: fishingRodWFactor[i],
              child: Image.asset(
                isChosen[i]
                    ? 'assets/fishing_game/rod/rod${i + 1}_L.png'
                    : 'assets/fishing_game/rod/rod${i + 1}.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: fishingRodAlgnment[i],
            child: FractionallySizedBox(
              heightFactor: detectorHFactor[i],
              widthFactor: detectorWFactor[i],
              child: Container(
                color: Colors.white.withOpacity(0.0),
                child: GestureDetector(
                  onTap: isChosen[i]
                      ? () {
                          widget.callback(i);
                          isChosen[i] = false;
                        }
                      : () {
                          isChosen = List.generate(4, (_) => false);
                          setState(() {
                            isChosen[i] = true;
                          });
                        },
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
