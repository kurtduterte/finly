import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _persistMode(ThemeMode mode) async {
    final prefs = await _prefs();
    await prefs.setString(_key, mode.name);
  }

  @override
  ThemeMode build() {
    unawaited(_loadSaved());
    return ThemeMode.dark;
  }

  Future<void> _loadSaved() async {
    final prefs = await _prefs();
    final saved = prefs.getString(_key);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await _persistMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _persistMode(mode);
  }
}
