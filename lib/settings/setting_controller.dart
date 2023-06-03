import 'package:flutter/foundation.dart';

import 'persistence/settings_persistence.dart';

class SettingsController {
  final SettingsPersistence _persistence;
  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence;

  ValueNotifier<String> language = ValueNotifier('國語');

  Future<void> loadStateFromPersistence() async {
    await Future.wait([
      _persistence.getAudioLanguage().then((value) => language.value = value),
    ]);
  }

  void setLanguage(String value) {
    language.value = value;
    _persistence.saveAudioLanguage(language.value);
  }
}
