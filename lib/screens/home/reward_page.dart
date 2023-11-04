import 'dart:math';

import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/reward_page_const.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            image: const DecorationImage(
              image: AssetImage(RewardPageConst.background),
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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext buildContext, BoxConstraints constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                RewardPageConst.title,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Consumer<UserCheckinProvider>(
                builder: (context, provider, child) {
              Logger().i(provider.loginCycle);
              Logger().i(provider.loginRewardCycle);
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  for (int i = 0;
                      i < RewardPageConst.numString.length;
                      i++) ...[
                    Expanded(
                      child:
                          provider.loginCycle[i] && provider.loginRewardCycle[i]
                              ? rewardImage(i, rewardTaken: true)
                              : provider.loginCycle[i] &&
                                      !provider.loginRewardCycle[i]
                                  ? rewardImage(i, haveReward: true)
                                  : rewardImage(i),
                    ),
                    // if (provider.loginCycle[i] &&
                    //     provider.loginRewardCycle[i]) ...[
                    //   Expanded(child: rewardImage(i, rewardTaken: true)),
                    // ] else if (provider.loginCycle[i] &&
                    //     !provider.loginRewardCycle[i]) ...[
                    //   Expanded(child: rewardImage(i, haveReward: true)),
                    // ] else ...[
                    //   Expanded(child: rewardImage(i)),
                    // ]
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
    return Column(
      key: ValueKey(day),
      children: [
        Expanded(
          flex: 12,
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (BuildContext buildContext, BoxConstraints constraints) {
                // double minValue =
                //     min(constraints.maxHeight, constraints.maxWidth);
                return Consumer2<UserInfoProvider, UserCheckinProvider>(
                    builder: (_, userInfoProvider, userCheckinProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      if (haveReward) {
                        Logger().i(day);
                        userInfoProvider.coins +=
                            userCheckinProvider.updateRewardStatus(day);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: haveReward ? 1 : 0.7,
                          child: Image.asset(
                            RewardPageConst.calenderWithoutTap,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.0, 0.65),
                          child: FractionallySizedBox(
                            heightFactor: 0.5,
                            widthFactor: 0.5,
                            child: Opacity(
                              opacity: haveReward ? 1 : 0.3,
                              child: Image.asset(
                                Globals.coinWithoutTap,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        if (rewardTaken)
                          Center(
                            child: Transform.rotate(
                              angle: pi / 6,
                              child: Image.asset(
                                RewardPageConst.receivedSeal,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            RewardPageConst.dayString[day],
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            RewardPageConst.numString[day],
            fit: BoxFit.contain,
          ),
        ),
      ],
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
                image: AssetImage(RewardPageConst.bonusRewardBackground),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(RewardPageConst.bonusRewardLabel),
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
                                    RewardPageConst.bonusRewardBadge,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      RewardPageConst.thirtyStraightMins,
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
                                    RewardPageConst.bonusRewardBadge,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      RewardPageConst.threeTimesInWeek,
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
                                    RewardPageConst.bonusRewardBadge,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      RewardPageConst.thirtyMinsThreeTimes,
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }
}
