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

  @override
  Future<bool> getStatusOfDailyNotification() async {
    final pref = await instanceFuture;
    return pref.getBool('statusOfDailyNotification') ?? false;
  }

  @override
  Future<void> saveStatusOfDailyNotification(bool status) async {
    final pref = await instanceFuture;
    pref.setBool('statusOfDailyNotification', status);
  }

  @override
  Future<String> getDailyNotificationTime1() async {
    final pref = await instanceFuture;
    return pref.getString('timeOfDailyNotification1') ?? '';
  }

  @override
  Future<void> saveDailyNotificationTime1(String time) async {
    final pref = await instanceFuture;
    pref.setString('timeOfDailyNotification1', time);
  }

  @override
  Future<String> getDailyNotificationTime2() async {
    final pref = await instanceFuture;
    return pref.getString('timeOfDailyNotification2') ?? '';
  }

  @override
  Future<void> saveDailyNotificationTime2(String time) async {
    final pref = await instanceFuture;
    pref.setString('timeOfDailyNotification2', time);
  }

  @override
  Future<String> getDailyNotificationTime3() async {
    final pref = await instanceFuture;
    return pref.getString('timeOfDailyNotification3') ?? '';
  }

  @override
  Future<void> saveDailyNotificationTime3(String time) async {
    final pref = await instanceFuture;
    pref.setString('timeOfDailyNotification3', time);
  }

  @override
  Future<String> getTimeOfLastDatabaseUpdate() async {
    final pref = await instanceFuture;
    return pref.getString('timeOfLastDatabaseUpdate') ?? '';
  }

  @override
  Future<void> saveTimeOfLastDatabaseUpdate(String time) async {
    final pref = await instanceFuture;
    pref.setString('timeOfLastDatabaseUpdate', time);
  }

  @override
  Future<List<String>> getRuleListenedLotteryGame() async {
    final pref = await instanceFuture;
    return pref.getStringList('ruleListenedLotteryGame') ??
        ['false', 'false', 'false', 'false', 'false'];
  }

  @override
  Future<void> saveRuleListenedLotteryGame(List<String> status) async {
    final pref = await instanceFuture;
    pref.setStringList('ruleListenedLotteryGame', status);
  }

  @override
  Future<List<String>> getRuleListenedFishingGame() async {
    final pref = await instanceFuture;
    return pref.getStringList('ruleListenedFisingingGame') ??
        ['false', 'false', 'false', 'false', 'false'];
  }

  @override
  Future<void> saveRuleListeneFishingGame(List<String> status) async {
    final pref = await instanceFuture;
    pref.setStringList('ruleListenedFisingingGame', status);
  }

  @override
  Future<List<String>> getRuleListenedPokerGame() async {
    final pref = await instanceFuture;
    return pref.getStringList('ruleListenedPokerGame') ??
        ['false', 'false', 'false', 'false', 'false'];
  }

  @override
  Future<void> saveRuleListenedPokerGame(List<String> status) async {
    final pref = await instanceFuture;
    pref.setStringList('ruleListenedPokerGame', status);
  }

  @override
  Future<List<String>> getRuleListenedRoutePlanningGame() async {
    final pref = await instanceFuture;
    return pref.getStringList('ruleListenedRoutePlanningGame') ??
        ['false', 'false', 'false', 'false', 'false'];
  }

  @override
  Future<void> saveRuleListenedRoutePlanningGame(List<String> status) async {
    final pref = await instanceFuture;
    pref.setStringList('ruleListenedRoutePlanningGame', status);
  }
}
