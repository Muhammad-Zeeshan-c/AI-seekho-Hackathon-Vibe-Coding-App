import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-wide theme mode (light / dark / system).
/// Persists preference to SharedPreferences.
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadSaved();
  }

  /// Loads saved theme preference from device storage
  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggle(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set a specific ThemeMode and save to storage
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
    } catch (_) {}
  }

  /// Returns true if current state is dark
  bool get isDark => state == ThemeMode.dark;
}
