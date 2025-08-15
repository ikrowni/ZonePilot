import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CORRECTED: "extends" instead of "with"
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  ThemeMode get getThemeMode => _themeMode;

  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners(); // This will now work correctly

    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.name);
  }
}