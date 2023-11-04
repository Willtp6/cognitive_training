import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/global_info_provider.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<GlobalInfoProvider>(
          builder: (BuildContext context, globalInfoProvider, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/ranking_page/ranking_background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: globalInfoProvider.rankingUsers.length != 0 &&
                      globalInfoProvider.currentUser != null
                  ? Stack(
                      children: [
                        Align(
                          alignment: const Alignment(0.0, -0.6),
                          child: UserIndexBar(
                            userName:
                                globalInfoProvider.rankingUsers[0].username,
                            numOfCoins:
                                globalInfoProvider.rankingUsers[0].ownedCoins,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.0, -0.15),
                          child: UserIndexBar(
                            userName:
                                globalInfoProvider.rankingUsers[1].username,
                            numOfCoins:
                                globalInfoProvider.rankingUsers[1].ownedCoins,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.0, 0.325),
                          child: UserIndexBar(
                            userName:
                                globalInfoProvider.rankingUsers[2].username,
                            numOfCoins:
                                globalInfoProvider.rankingUsers[2].ownedCoins,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.0, 0.95),
                          child: UserIndexBar(
                            userName: globalInfoProvider.currentUser.username,
                            numOfCoins:
                                globalInfoProvider.currentUser.ownedCoins,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.85, 0.55),
                          child: GestureDetector(
                            onTap: () {
                              // Logger().d('tapped');
                              globalInfoProvider.updateRanking();
                            },
                            child: FractionallySizedBox(
                              heightFactor: 0.1,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: LayoutBuilder(
                                  builder: (buildContext, constraints) => Icon(
                                    Icons.replay_circle_filled,
                                    size: constraints.maxHeight,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            // child: IconButton(
                            //   icon: Icon(
                            //     Icons.replay,
                            //     color: Colors.lightBlueAccent,
                            //     size: MediaQuery.of(context).size.height * 0.15,
                            //   ),
                            //   onPressed: () {
                            //     Logger().d('tapped');
                            //   },
                            // ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.9, -0.9),
                          child: FractionallySizedBox(
                            heightFactor: 0.15,
                            child: ExitButton(callBackFunction: () {
                              context.pop();
                            }),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            );
          },
        ),
      ),
    );
  }
}

class UserIndexBar extends StatelessWidget {
  const UserIndexBar(
      {super.key, required this.userName, required this.numOfCoins});

  final String userName;
  final int numOfCoins;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.15,
      widthFactor: 0.75,
      child: Row(
        children: [
          Expanded(flex: 5, child: Container()),
          Expanded(
            flex: 12,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              widthFactor: 0.9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  userName,
                  style: const TextStyle(
                      color: Colors.amber, fontSize: 100, fontFamily: 'GSR_B'),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 7,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              widthFactor: 0.9,
              child: Center(
                child: AutoSizeText(
                  numOfCoins.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.amber, fontSize: 100, fontFamily: 'GSR_B'),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container())
        ],
      ),
    );
  }
}
