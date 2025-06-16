import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    // We can still call the private method here for initial load
    // when the provider is created.
    _loadThemeFromPrefs();
  }

  // Private method to load the saved theme from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false; // Default to false (light mode)
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners about the theme change
  }

  // Public method to explicitly load the theme (what main.dart was trying to call)
  Future<void> loadTheme() async {
    await _loadThemeFromPrefs(); // Just call the private loading logic
  }

  // Method to toggle and save the new theme preference
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('is_dark_mode', isDark); // Save the new theme preference
    notifyListeners(); // Notify listeners about the theme change
  }
}