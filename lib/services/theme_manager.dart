import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum ThemeMode { light, dark, system }

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  Color _themeColor = const Color(0xFF0052D9);

  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;

  Future<void> init() async {
    await _loadThemeMode();
    await _loadThemeColor();

    // Listen for system brightness changes
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
          if (_themeMode == ThemeMode.system) {
            notifyListeners();
          }
        };
  }

  Future<void> _loadThemeMode() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/theme_preference.txt');

      if (await file.exists()) {
        final value = await file.readAsString();
        switch (value) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> _loadThemeColor() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/theme_color.txt');

      if (await file.exists()) {
        final value = await file.readAsString();
        final colorValue = int.tryParse(value);
        if (colorValue != null) {
          _themeColor = Color(colorValue);
        }
      }
    } catch (e) {
      debugPrint('Error loading theme color: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/theme_preference.txt');

      String value;
      switch (mode) {
        case ThemeMode.light:
          value = 'light';
          break;
        case ThemeMode.dark:
          value = 'dark';
          break;
        case ThemeMode.system:
          value = 'system';
          break;
      }

      await file.writeAsString(value);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> setThemeColor(Color color) async {
    if (_themeColor == color) return;

    _themeColor = color;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/theme_color.txt');
      await file.writeAsString(color.toARGB32().toString());
    } catch (e) {
      debugPrint('Error saving theme color: $e');
    }
  }

  Brightness getBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  bool isDarkMode(BuildContext context) {
    return getBrightness(context) == Brightness.dark;
  }
}
