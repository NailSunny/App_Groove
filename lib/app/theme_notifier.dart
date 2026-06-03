import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'groove_theme_mode';

/// Управление светлой/тёмной темой (по умолчанию — тёмная).
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _load();
  }

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModeKey);
    if (stored == 'light') {
      _mode = ThemeMode.light;
    } else if (stored == 'dark') {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setDark(bool dark) async {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, dark ? 'dark' : 'light');
  }

  Future<void> toggle() => setDark(!isDark);
}
