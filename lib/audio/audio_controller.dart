import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AudioController {
  final logger = Logger();

  final AudioPlayer audioPlayer;
  final AudioPlayer audioPlayer2;
  // final AudioPlayer _bgmPlayer;

  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  SettingsController? _settings;

  AudioController({int polyphony = 2})
      : assert(polyphony >= 1),
        audioPlayer = AudioPlayer(playerId: 'audioPlayer'),
        audioPlayer2 = AudioPlayer(playerId: 'audioPlayer2');
  // _bgmPlayer = AudioPlayer(playerId: 'bgmPlayer');

  /// Preloads all sound effects.
  Future<void> initialize() async {
    logger.i('Preloading sound effects');
    // This assumes there is only a limited number of sound effects in the game.
    // If there are hundreds of long sound effect files, it's better
    // to be more selective when preloading.
    // * this needs to be modified or skip this function
    await AudioCache.instance.loadAll(['audio/shared/click_button.wav']);
  }

  Future<void> loadLotteryGameAudio() async {
    logger.i('Loading lotteryGameAudio');
    final tmpDir = await getTemporaryDirectory();
    String tmpPath = tmpDir.path;

    Directory audioDirectory = Directory('$tmpPath/lottery_game_sound');
    logger.d(tmpPath);
    if (await audioDirectory.exists()) {
      // ! for cache the audio but this part is undone and have bugs
      // List<FileSystemEntity> fileList =
      //     audioDirectory.listSync(recursive: false);
      // final audioFiles = fileList.where((element) =>
      //     element.path.endsWith('.mp3') || element.path.endsWith('.wav'));
      // logger.i(audioFiles);
      // await Future.forEach(audioFiles, (file) async {
      //   final filePath = file.path;
      //   await AudioCache.instance.load(filePath);
      // });
    } else {
      logger.i('path doesn\'t exists');
    }
    logger.i('Loading complete');
  }

  void dispose() {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);
    _stopAllSound();
    audioPlayer.dispose();
    audioPlayer2.dispose();
    // _bgmPlayer.dispose();
  }

  void attachLifecycleNotifier(
      ValueNotifier<AppLifecycleState> lifecycleNotifier) {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);

    lifecycleNotifier.addListener(_handleAppLifecycle);
    _lifecycleNotifier = lifecycleNotifier;
  }

  void _handleAppLifecycle() {
    switch (_lifecycleNotifier!.value) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopAllSound();
        break;
      case AppLifecycleState.resumed:
        // if (!_settings!.muted.value && _settings!.musicOn.value) {
        //   _resumeMusic();
        // }
        _resumeMusic();
        break;
      case AppLifecycleState.inactive:
        // No need to react to this state change.
        break;
    }
  }

  String getLanguage() {
    return _settings?.language.value == '國語' ? 'chinese' : 'taiwanese';
  }

  void _stopAllSound() {
    // * check template
  }

  void _resumeMusic() {
    // * check template
  }

  void attachSettings(SettingsController settingsController) {
    if (_settings == settingsController) return;
    final oldSettings = _settings;
    if (oldSettings != null) {
      oldSettings.language.removeListener(_languageHandler);
    }
    _settings = settingsController;

    settingsController.language.addListener(_languageHandler);
  }

  void _languageHandler() {}

  // void playBGM(String path) {
  //   _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  //   _bgmPlayer.play(AssetSource(path));
  // }

  // void pauseBGM() {
  //   _bgmPlayer.pause();
  // }

  // void resumeBGM() {
  //   _bgmPlayer.resume();
  // }

  // void stopBGM() {
  //   _bgmPlayer.pause();
  //   _bgmPlayer.release();
  // }

  void playInstructionRecord(String path) async {
    await audioPlayer.pause();
    await audioPlayer.release();
    String language = getLanguage();
    audioPlayer.play(AssetSource('instruction_record/$language/$path'));
  }

  void pauseAudio() {
    audioPlayer.pause();
  }

  void resumeAudio() {
    audioPlayer.resume();
  }

  void stopAudio() {
    audioPlayer.pause();
    audioPlayer.release();
  }

  void playLotteryGameNumber(String path) {
    String language = getLanguage();
    audioPlayer.play(AssetSource('lottery_game/sound/$language/$path'));
  }

  void playLotteryGameSoundEffect(String path) {
    audioPlayer.play(AssetSource('lottery_game/sound/$path'));
  }

  void playFishingGameSoundEffect(String path) {
    audioPlayer.play(AssetSource('fishing_game/sound/$path'));
  }

  void playPokerGameSoundEffect(String path) {
    audioPlayer.play(AssetSource('poker_game/sound/$path'));
  }

  void playGameDescription(int index) {
    List<String> game = [
      'lottery_game',
      'fishing_game',
      'poker_game',
      'routing_game'
    ];
    String language = getLanguage();
    audioPlayer.play(AssetSource(
        'instruction_record/$language/${game[index]}/game_description.m4a'));
  }

  void playByExtraPlayer(String path) {
    audioPlayer2.play(AssetSource(path));
  }

  Future<void> playPathAudio(String path) async {
    await audioPlayer.stop();
    await audioPlayer.release();
    await audioPlayer.play(AssetSource(path));
  }
}
