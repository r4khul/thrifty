import 'package:flutter/material.dart';
import 'package:thrifty/core/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// Theme Controller: Manages the application's overall theme mode.
/// Responsibility:
/// - Persists/recovers theme preference (future enhancement).
/// - Provides deterministic switching between light, dark, and system modes.
@riverpod
class ThemeController extends _$ThemeController {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeString = prefs.getString(_themeKey);

    // Default to dark mode as per refined design aesthetics
    if (themeString == null) return ThemeMode.dark;

    return ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.dark,
    );
  }

  /// Sets the application theme mode.
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveTheme(mode);
  }

  /// Toggles between light and dark modes.
  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    _saveTheme(newMode);
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeKey, mode.name);
  }
}
