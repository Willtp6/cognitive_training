import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          image: const DecorationImage(
            image: AssetImage('assets/login_reward/reward_background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(children: [
          Row(
            children: [
              Flexible(flex: 1, child: Container()),
              Flexible(
                flex: 5,
                child: Column(
                  children: [
                    Flexible(flex: 1, child: Container()),
                    const Flexible(flex: 8, child: CheckinReward()),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    const Flexible(flex: 8, child: BonusReward()),
                    Flexible(flex: 1, child: Container()),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Container()),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: FractionallySizedBox(
              heightFactor: 0.25,
              widthFactor: 0.1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const CircleBorder()),
                    child: const Icon(
                      Icons.cancel,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class CheckinReward extends StatefulWidget {
  const CheckinReward({super.key});

  @override
  State<CheckinReward> createState() => CheckinRewardState();
}

class CheckinRewardState extends State<CheckinReward> {
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
  late UserInfoProvider infoProvider;
  late UserCheckinProvider checkinProvider;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    infoProvider = Provider.of<UserInfoProvider>(context);
    checkinProvider = Provider.of<UserCheckinProvider>(context);

    return LayoutBuilder(
        builder: (BuildContext buildContext, BoxConstraints constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(title, scale: 3),
            ),
          ),
          Expanded(
            flex: 5,
            child: Consumer<UserCheckinProvider>(
                builder: (context, provider, child) {
              Logger().i(provider.loginCycle);
              Logger().i(provider.loginRewardCycle);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < numString.length; i++) ...[
                    if (provider.loginCycle[i] &&
                        provider.loginRewardCycle[i]) ...[
                      rewardImage(i, rewardTaken: true),
                    ] else if (provider.loginCycle[i] &&
                        !provider.loginRewardCycle[i]) ...[
                      rewardImage(i, haveReward: true),
                    ] else ...[
                      rewardImage(i),
                    ]
                  ]
                ],
              );
            }),
          ),
        ],
      );
    });
  }

  Widget rewardImage(int day,
      {bool haveReward = false, bool rewardTaken = false}) {
    return Expanded(
      key: ValueKey(day),
      child: Column(
        children: [
          Expanded(
            flex: 12,
            child: LayoutBuilder(
              builder: (BuildContext buildContext, BoxConstraints constraints) {
                double minValue =
                    min(constraints.maxHeight, constraints.maxWidth);
                return GestureDetector(
                  onTap: () {
                    if (haveReward) {
                      Logger().i(day);
                      infoProvider.coins +=
                          checkinProvider.updateRewardStatus(day);
                    }
                  },
                  child: Center(
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: haveReward ? 1 : 0.7,
                          child: Image.asset(
                            'assets/login_reward/calendar_without_tap.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: minValue,
                          width: minValue,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: minValue * 0.4,
                              bottom: minValue * 0.1,
                            ),
                            child: Opacity(
                              opacity: haveReward ? 1 : 0.3,
                              child: Image.asset(
                                'assets/login_reward/coin_without_tap.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            //child: Placeholder(),
                          ),
                        ),
                        if (rewardTaken)
                          Center(
                              child: Transform.rotate(
                            angle: pi / 6,
                            child: Image.asset(
                                'assets/login_reward/received seal.png'),
                          ))
                      ],
                    ),
                  ),
                );
              },
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child:
                          Image.asset('assets/login_reward/bonus_reward.png'),
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
                ),
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
                  flex: 3,
                  child: Image.asset('assets/login_reward/Mystery_gift.png'),
                ),
                Expanded(
                  flex: 2,
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
