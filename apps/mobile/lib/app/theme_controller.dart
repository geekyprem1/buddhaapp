import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// App theme mode (system / light / dark), persisted in the `app_prefs` Hive
/// box (opened at startup by AlarmLocalStore.init). Watched by the root
/// [MaterialApp] so a change applies immediately across the app.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _boxName = 'app_prefs';
  static const _key = 'theme_mode';

  Box<dynamic>? get _box =>
      Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;

  @override
  ThemeMode build() => _decode(_box?.get(_key) as String?);

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _box?.put(_key, _encode(mode));
  }

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
