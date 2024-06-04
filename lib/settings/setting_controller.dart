import 'package:flutter/foundation.dart';

import 'persistence/settings_persistence.dart';

class SettingsController {
  final SettingsPersistence _persistence;
  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence;

  ValueNotifier<String> language = ValueNotifier('國語');
  ValueNotifier<bool> statusOfDailyNotification = ValueNotifier(true);
  ValueNotifier<String> timeOfDailyNotification1 = ValueNotifier('');
  ValueNotifier<String> timeOfDailyNotification2 = ValueNotifier('');
  ValueNotifier<String> timeOfDailyNotification3 = ValueNotifier('');
  ValueNotifier<String> timeOfLastDatabaseUpdate = ValueNotifier('');
  ValueNotifier<List<String>> ruleListenedLotteryGame =
      ValueNotifier(['false', 'false', 'false', 'false', 'false']);
  ValueNotifier<List<String>> ruleListenedFishingGame =
      ValueNotifier(['false', 'false', 'false', 'false', 'false']);
  ValueNotifier<List<String>> ruleListenedPokerGame =
      ValueNotifier(['false', 'false', 'false', 'false', 'false']);
  ValueNotifier<List<String>> ruleListenedRoutePlanningGame =
      ValueNotifier(['false', 'false', 'false', 'false', 'false']);

  Future<void> loadStateFromPersistence() async {
    await Future.wait([
      _persistence.getAudioLanguage().then((value) => language.value = value),
      _persistence
          .getStatusOfDailyNotification()
          .then((value) => statusOfDailyNotification.value = value),
      _persistence
          .getDailyNotificationTime1()
          .then((value) => timeOfDailyNotification1.value = value),
      _persistence
          .getDailyNotificationTime2()
          .then((value) => timeOfDailyNotification2.value = value),
      _persistence
          .getDailyNotificationTime3()
          .then((value) => timeOfDailyNotification3.value = value),
      _persistence
          .getTimeOfLastDatabaseUpdate()
          .then((value) => timeOfLastDatabaseUpdate.value = value),
      _persistence
          .getRuleListenedLotteryGame()
          .then((value) => ruleListenedLotteryGame.value = value),
      _persistence
          .getRuleListenedFishingGame()
          .then((value) => ruleListenedFishingGame.value = value),
      _persistence
          .getRuleListenedPokerGame()
          .then((value) => ruleListenedPokerGame.value = value),
      _persistence
          .getRuleListenedRoutePlanningGame()
          .then((value) => ruleListenedRoutePlanningGame.value = value),
    ]);
  }

  void setLanguage(String value) {
    language.value = value;
    _persistence.saveAudioLanguage(language.value);
  }

  void setStatusOfDailyNotification(bool value) {
    statusOfDailyNotification.value = value;
    _persistence.saveStatusOfDailyNotification(value);
  }

  void setDailyNotificationTime1(String time) {
    timeOfDailyNotification1.value = time;
    _persistence.saveDailyNotificationTime1(time);
  }

  void setDailyNotificationTime2(String time) {
    timeOfDailyNotification2.value = time;
    _persistence.saveDailyNotificationTime2(time);
  }

  void setDailyNotificationTime3(String time) {
    timeOfDailyNotification3.value = time;
    _persistence.saveDailyNotificationTime3(time);
  }

  void setTimeOfLastDatabaseUpdate(String time) {
    timeOfLastDatabaseUpdate.value = time;
    _persistence.saveTimeOfLastDatabaseUpdate(time);
  }

  void setRuleListenedLotteryGame(List<String> status) {
    ruleListenedLotteryGame.value = status;
    _persistence.saveRuleListenedLotteryGame(status);
  }

  void setRuleListenedFishingGame(List<String> status) {
    ruleListenedFishingGame.value = status;
    _persistence.saveRuleListeneFishingGame(status);
  }

  void setRuleListenedPokerGame(List<String> status) {
    ruleListenedPokerGame.value = status;
    _persistence.saveRuleListenedPokerGame(status);
  }

  void setRuleListenedRoutePlanningGame(List<String> status) {
    ruleListenedRoutePlanningGame.value = status;
    _persistence.saveRuleListenedRoutePlanningGame(status);
  }
}
