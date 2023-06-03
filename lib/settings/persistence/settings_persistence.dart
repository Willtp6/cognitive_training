abstract class SettingsPersistence {
  Future<void> saveAudioLanguage(String language);

  Future<String> getAudioLanguage();
}
