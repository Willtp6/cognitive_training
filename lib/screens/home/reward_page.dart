import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[100],
        image: const DecorationImage(
          image: AssetImage('assets/login_reward/reward_background.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          Flexible(flex: 1, child: Container()),
          Flexible(
              flex: 5,
              child: Column(
                children: [
                  Flexible(flex: 1, child: Container()),
                  const Flexible(flex: 4, child: CheckinReward()),
                  const Flexible(flex: 4, child: BonusReward()),
                  Flexible(flex: 1, child: Container()),
                ],
              )),
          Flexible(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class CheckinReward extends StatefulWidget {
  const CheckinReward({super.key});

  @override
  State<CheckinReward> createState() => CheckinRewardState();
}

class CheckinRewardState extends State<CheckinReward>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final String title = 'assets/login_reward/reward_title.png';
  final List<String> dayString = [
    'assets/login_reward/day1.png',
    'assets/login_reward/day2.png',
    'assets/login_reward/day3.png',
    'assets/login_reward/day4.png',
    'assets/login_reward/day5.png',
    'assets/login_reward/day6.png',
    'assets/login_reward/day7.png',
  ];
  final List<String> numString = [
    'assets/login_reward/100.png',
    'assets/login_reward/200.png',
    'assets/login_reward/300.png',
    'assets/login_reward/400.png',
    'assets/login_reward/500.png',
    'assets/login_reward/600.png',
    'assets/login_reward/700.png',
  ];
  late Animation animation;
  @override
  void initState() {
    super.initState();
    // controller = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // );
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // animation = Tween(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(controller);
    return LayoutBuilder(
        builder: (BuildContext buildContext, BoxConstraints constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
                child: Padding(
              padding: EdgeInsets.only(top: constraints.maxHeight * 0.1),
              child: Image.asset(title, scale: 3),
            )),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                for (int i = 0; i < numString.length; i++) ...[
                  rewardImage(i),
                ]
              ],
            ),
          )
        ],
      );
    });
  }

  Widget rewardImage(int day) {
    //controller.repeat(reverse: true);
    return Expanded(
      child: Column(
        children: [
          Expanded(
            flex: 12,
            child: LayoutBuilder(builder:
                (BuildContext buildContext, BoxConstraints constraints) {
              double minValue =
                  min(constraints.maxHeight, constraints.maxWidth);
              return GestureDetector(
                onTap: () {
                  Logger().i(day);
                },
                child: Center(
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/login_reward/calendar_without_tap.png',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        height: minValue,
                        width: minValue,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: minValue * 0.4,
                            bottom: minValue * 0.1,
                          ),
                          child: Image.asset(
                            'assets/login_reward/coin_without_tap.png',
                            fit: BoxFit.contain,
                          ),
                          //child: Placeholder(),
                        ),
                      ),
                      /*
                      AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: animation.value,
                            child: SizedBox(
                              height: minValue,
                              width: minValue,
                              child: Image.asset(
                                'assets/login_reward/Mystery gift_click.png',
                              ),
                            ),
                          );
                        },
                      ),
                      */
                    ],
                  ),
                ),
              );
            }),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              dayString[day],
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              numString[day],
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class BonusReward extends StatefulWidget {
  const BonusReward({super.key});

  @override
  State<BonusReward> createState() => _BonusRewardState();
}

class _BonusRewardState extends State<BonusReward> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 5,
          child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/login_reward/bonus_reward_background.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset('assets/login_reward/bonus_reward.png'),
                  ),
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    'assets/login_reward/bonus_reward_badge.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/login_reward/30_straight_minutes.png',
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    'assets/login_reward/bonus_reward_badge.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/login_reward/3_times_in_week.png',
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    'assets/login_reward/bonus_reward_badge.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/login_reward/30_mins_3_times.png',
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              )),
        ),
        Expanded(
          flex: 2,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset('assets/login_reward/Mystery_gift.png'),
                ),
                Expanded(
                  flex: 1,
                  child:
                      Image.asset('assets/login_reward/Mystery_gift_title.png'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
