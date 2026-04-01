import 'dart:convert';
import 'package:thrifty/core/providers/shared_preferences_provider.dart';
import 'package:thrifty/features/settings/domain/notification_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  NotificationRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'notification_settings';

  NotificationSettings getSettings() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) {
      return const NotificationSettings();
    }
    try {
      return NotificationSettings.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } on Object catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationRepository(prefs);
}
