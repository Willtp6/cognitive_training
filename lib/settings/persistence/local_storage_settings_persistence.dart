import 'package:shared_preferences/shared_preferences.dart';

import 'settings_persistence.dart';

class LocalStorageSettingsPersistence extends SettingsPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<String> getAudioLanguage() async {
    final pref = await instanceFuture;
    return pref.getString('chosenLanguage') ?? '國語';
  }

  @override
  Future<void> saveAudioLanguage(String language) async {
    final pref = await instanceFuture;
    pref.setString('chosenLanguage', language);
  }
}
