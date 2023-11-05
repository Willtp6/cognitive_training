import 'package:audioplayers/audioplayers.dart';
import 'package:cognitive_training/constants/home_page_const.dart';
import 'package:cognitive_training/settings/setting_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class AudioController {
  static final _log = Logger();

  // final AudioPlayer _bgmPlayer;
  final AudioPlayer instructionPlayer;

  final List<AudioPlayer> _sfxPlayers;

  int _currentSfxPlayer = 0;

  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  SettingsController? _settings;
  String _currentLanguage = 'chinese';

  AudioController({int polyphony = 3})
      : assert(polyphony >= 1),
        instructionPlayer = AudioPlayer(playerId: 'instructionPlayer'),
        _sfxPlayers = List.generate(
            polyphony, (i) => AudioPlayer(playerId: 'sfxPlayer#$i'),
            growable: false) {
    // instructionPlayer.onPlayerComplete.listen((event) {
    //   Logger().d('done');
    //   instructionPlayer.release();
    // });
  }
  // _bgmPlayer = AudioPlayer(playerId: 'bgmPlayer');

  /// Preloads all sound effects.
  Future<void> initialize() async {
    _log.i('Preloading sound effects');
    // This assumes there is only a limited number of sound effects in the game.
    // If there are hundreds of long sound effect files, it's better
    // to be more selective when preloading.
    //todo this needs to be modified or skip this function
    //todo maybe load global first and load each game audio in game menu page ?
    await AudioCache.instance.loadAll(['audio/shared/click_button.wav']);
  }

  // Future<void> loadLotteryGameAudio() async {
  //   logger.i('Loading lotteryGameAudio');
  //   final tmpDir = await getTemporaryDirectory();
  //   String tmpPath = tmpDir.path;

  //   Directory audioDirectory = Directory('$tmpPath/lottery_game_sound');
  //   logger.d(tmpPath);
  //   if (await audioDirectory.exists()) {
  //     // ! for cache the audio but this part is undone and have bugs
  //     // List<FileSystemEntity> fileList =
  //     //     audioDirectory.listSync(recursive: false);
  //     // final audioFiles = fileList.where((element) =>
  //     //     element.path.endsWith('.mp3') || element.path.endsWith('.wav'));
  //     // logger.i(audioFiles);
  //     // await Future.forEach(audioFiles, (file) async {
  //     //   final filePath = file.path;
  //     //   await AudioCache.instance.load(filePath);
  //     // });
  //   } else {
  //     logger.i('path doesn\'t exists');
  //   }
  //   logger.i('Loading complete');
  // }

  void dispose() {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);
    _stopAllSound();
    // _bgmPlayer.dispose();
    instructionPlayer.dispose();
    for (final player in _sfxPlayers) {
      player.dispose();
    }
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

  void _stopAllSound() {
    instructionPlayer.stop();
    for (final player in _sfxPlayers) {
      player.stop();
    }
  }

  void _resumeMusic() {
    // * check template
    if (instructionPlayer.state == PlayerState.paused) {
      instructionPlayer.resume();
    }
    for (final player in _sfxPlayers) {
      if (player.state == PlayerState.paused) {
        try {
          player.resume();
        } catch (e) {
          _log.d(e);
        }
      }
    }
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

  void _languageHandler() {
    _currentLanguage =
        _settings?.language.value == '國語' ? 'chinese' : 'taiwanese';
    Logger().d(_currentLanguage);
  }

  void stopPlayingInstruction() {
    instructionPlayer.stop();
  }

  void playInstructionRecord(Map<String, String> path) async {
    instructionPlayer.stop();
    instructionPlayer.release();
    instructionPlayer.play(AssetSource(path[_currentLanguage]!));
  }

  void pauseAllAudio() {
    if (instructionPlayer.state == PlayerState.playing) {
      instructionPlayer.pause();
    }
    for (final player in _sfxPlayers) {
      if (player.state == PlayerState.playing) {
        player.pause();
      }
    }
  }

  void resumeAllAudio() {
    if (instructionPlayer.state == PlayerState.paused) {
      instructionPlayer.resume();
    }
    // for (final player in _sfxPlayers) {
    //   if (player.state == PlayerState.paused) {
    //     try {
    //       player.resume();
    //     } catch (e) {
    //       _log.d(e);
    //     }
    //   }
    // }
  }

  void stopAllAudio() {
    instructionPlayer.stop();
    for (final player in _sfxPlayers) {
      player.stop();
    }
  }

  void playSfx(String path) {
    final currentPlayer = _sfxPlayers[_currentSfxPlayer];
    currentPlayer.play(AssetSource(path));
    _currentSfxPlayer = (_currentSfxPlayer + 1) % _sfxPlayers.length;
  }

  void stopAllSfx() {
    for (final player in _sfxPlayers) {
      player.stop();
    }
  }

  void playGameDescription(int index) {
    instructionPlayer.play(
      AssetSource(HomePageConst.gameDescriptionAudio[index][_currentLanguage]!),
    );
  }
}
