import 'dart:math';

import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/constants/reward_page_const.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/shared/exit_button_template.dart';
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
            const Row(
              children: [
                Flexible(flex: 1, child: SizedBox.expand()),
                Flexible(
                  flex: 5,
                  child: Column(
                    children: [
                      Flexible(flex: 1, child: SizedBox.expand()),
                      Flexible(flex: 8, child: CheckinReward()),
                      Flexible(flex: 1, child: SizedBox.expand()),
                      Flexible(flex: 8, child: BonusReward()),
                      Flexible(flex: 1, child: SizedBox.expand()),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: SizedBox.expand()),
              ],
            ),
            ExitButton(
              callback: () {
                context.pop();
              },
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
            child: Consumer<DatabaseInfoProvider>(
                builder: (context, databaseInfoProvider, child) {
              // Logger().i(provider.loginCycle);
              // Logger().i(provider.loginRewardCycle);
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  for (int i = 0;
                      i < RewardPageConst.numString.length;
                      i++) ...[
                    Expanded(
                      child: databaseInfoProvider.loginCycle[i] &&
                              databaseInfoProvider.loginRewardCycle[i]
                          ? rewardImage(i, rewardTaken: true)
                          : databaseInfoProvider.loginCycle[i] &&
                                  !databaseInfoProvider.loginRewardCycle[i]
                              ? rewardImage(i, haveReward: true)
                              : rewardImage(i),
                    ),
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
                return Consumer<DatabaseInfoProvider>(
                    builder: (_, databaseInfoProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      if (haveReward) {
                        Logger().i(day);
                        databaseInfoProvider.updateRewardStatus(day);
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
        const Expanded(
          flex: 2,
          child: SizedBox.expand(),
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
                    child: Consumer<DatabaseInfoProvider>(
                        builder: (context, databaseInfoProvider, child) {
                      Logger().d(databaseInfoProvider.bonusRewardCycle);
                      return Row(
                        children: [
                          for (int i = 0; i < 3; i++) ...[
                            Expanded(
                              child: bonusRewardImage(
                                index: i,
                                databaseInfoProvider: databaseInfoProvider,
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(
          flex: 2,
          child: SizedBox.expand(),
        ),
      ],
    );
  }

  Widget bonusRewardImage({required index, required databaseInfoProvider}) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              if (databaseInfoProvider.bonusRewardCycle[index] ==
                  'uncollected') {
                setState(() {
                  databaseInfoProvider.achieveBonusReward(index);
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: databaseInfoProvider.bonusRewardCycle[index] ==
                          'uncollected'
                      ? 1.0
                      : 0.3,
                  child: Image.asset(
                    RewardPageConst.bonusRewardBadge,
                    fit: BoxFit.contain,
                  ),
                ),
                if (databaseInfoProvider.bonusRewardCycle[index] ==
                    'collected') ...[
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
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Image.asset(
            index == 0
                ? RewardPageConst.thirtyStraightMins
                : index == 1
                    ? RewardPageConst.threeTimesInWeek
                    : RewardPageConst.thirtyMinsThreeTimes,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class ExitButton extends ExitButtonTemplate {
  const ExitButton({super.key, required this.callback});

  final Function callback;

  @override
  void onTapFunction() {
    callback();
  }
}
