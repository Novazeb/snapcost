import 'package:flutter/material.dart';
import '../../../../services/database_service.dart';
import '../../../../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isBiometricsEnabled = false;
  bool _isDailyReminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  ThemeMode get themeMode => _themeMode;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final themeStr = await DatabaseService.instance.getSetting('theme_mode');
      if (themeStr != null) {
        if (themeStr == 'dark') _themeMode = ThemeMode.dark;
        if (themeStr == 'light') _themeMode = ThemeMode.light;
      }

      final bioStr = await DatabaseService.instance.getSetting('biometrics_enabled');
      if (bioStr != null) {
        _isBiometricsEnabled = bioStr == 'true';
      }

      final remStr = await DatabaseService.instance.getSetting('daily_reminder_enabled');
      if (remStr != null) {
        _isDailyReminderEnabled = remStr == 'true';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String val = 'system';
    if (mode == ThemeMode.dark) val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    await DatabaseService.instance.saveSetting('theme_mode', val);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    _isBiometricsEnabled = enabled;
    await DatabaseService.instance.saveSetting('biometrics_enabled', enabled.toString());
    notifyListeners();
  }

  Future<void> toggleDailyReminder(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    await DatabaseService.instance.saveSetting('daily_reminder_enabled', enabled.toString());

    if (enabled) {
      await NotificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await NotificationService.cancelAll();
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    if (_isDailyReminderEnabled) {
      await NotificationService.scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
    notifyListeners();
  }
}
