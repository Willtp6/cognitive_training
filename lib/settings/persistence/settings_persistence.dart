abstract class SettingsPersistence {
  Future<void> saveAudioLanguage(String language);

  Future<String> getAudioLanguage();

  Future<void> saveStatusOfDailyNotification(bool status);

  Future<bool> getStatusOfDailyNotification();

  Future<void> saveDailyNotificationTime1(String time);

  Future<String> getDailyNotificationTime1();

  Future<void> saveDailyNotificationTime2(String time);

  Future<String> getDailyNotificationTime2();

  Future<void> saveDailyNotificationTime3(String time);

  Future<String> getDailyNotificationTime3();

  Future<void> saveTimeOfLastDatabaseUpdate(String time);

  Future<String> getTimeOfLastDatabaseUpdate();
}
