import 'package:cognitive_training/audio/audio_controller.dart';
import 'package:cognitive_training/constants/globals.dart';
import 'package:cognitive_training/models/database_info_provider.dart';
import 'package:cognitive_training/screens/games/route_planning_game_forge2d/route_planning_game_forge2d.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'exit_button.dart';

class ExitDialog extends StatelessWidget {
  static const id = "ExitDialog";
  const ExitDialog({super.key, required this.game});
  final RoutePlanningGameForge2d game;

  void continueCallback() {
    game.overlays.remove(ExitDialog.id);
    game.resumeEngine();
  }

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
              databaseInfoProvider.routePlanningGameDoneTutorial();
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
              game.timerEnabled = true;
              game.alarmClockAudio?.resume();
              FlameAudio.bgm.resume();
              audioController.resumeAllAudio();
            },
          );
  }
}
