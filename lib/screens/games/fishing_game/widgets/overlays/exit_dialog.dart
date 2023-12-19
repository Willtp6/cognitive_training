import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../fishing_game.dart';
import 'package:flutter/material.dart';

import 'exit_button.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final FishingGame game;

  @override
  Widget build(BuildContext context) {
    DatabaseInfoProvider databaseInfoProvider =
        context.read<DatabaseInfoProvider>();
    AudioController audioController = context.read<AudioController>();
    audioController.pauseAllAudio();
    return game.isTutorial
        ? Globals.dialogTemplate(
            title: '確定要離開嗎?',
            subTitle: '直接離開會跳過教學模式喔!!!',
            option1: '確定離開',
            option1Callback: () {
              databaseInfoProvider.fishingGameDoneTutorial();
              game.overlays.remove(ExitDialog.id);
              audioController.stopAllAudio();
              context.pop();
            },
            option2: '繼續教學',
            option2Callback: () {
              game.overlays.remove(ExitDialog.id);
              game.overlays.add(ExitButton.id);
              game.resumeEngine();
              audioController.resumeAllAudio();
            },
          )
        : Globals.dialogTemplate(
            title: '確定要離開嗎?',
            subTitle: '遊戲將不會被記錄下來喔!!!',
            option1: '確定離開',
            option1Callback: () {
              game.overlays.remove(ExitDialog.id);
              audioController.stopAllAudio();
              context.pop();
            },
            option2: '繼續遊戲',
            option2Callback: () {
              game.overlays.remove(ExitDialog.id);
              game.overlays.add(ExitButton.id);
              game.resumeEngine();
              audioController.resumeAllAudio();
            },
          );
  }
}
