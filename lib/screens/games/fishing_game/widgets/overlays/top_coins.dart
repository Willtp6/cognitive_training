import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import '../../fishing_game.dart';

class TopCoins extends StatefulWidget {
  TopCoins({super.key, required this.game});

  static const String id = "TopCoins";
  FishingGame game;

  @override
  State<TopCoins> createState() => _TopCoinsState();
}

class _TopCoinsState extends State<TopCoins> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, userInfo, child) {
        return Align(
          alignment: Alignment(0.05, -0.925),
          child: FractionallySizedBox(
            widthFactor: 0.125,
            heightFactor: 0.075,
            child: AutoSizeText(
              userInfo.coins.toString(),
              style: const TextStyle(fontFamily: 'GSR_B', fontSize: 100),
              textAlign: TextAlign.end,
            ),
          ),
        );
      },
    );
  }
}
