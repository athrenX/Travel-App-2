import 'package:flutter/material.dart';

// Definisi Warna Dasar yang konsisten di seluruh aplikasi

// Light Theme Colors
const Color lightPrimaryColor = Color(0xFF3498DB); // Primary Blue
const Color lightSecondaryColor = Color(0xFFFF9800); // Accent Orange
const Color lightBackgroundColor = Color(0xFFF5F7FA); // Very light background
const Color lightCardColor = Colors.white; // Light card color
const Color lightTextColor = Color(0xFF2C3E50); // Dark text for light mode
const Color lightDisabledColor = Color(0xFFE0E0E0); // Disabled color
const Color lightErrorColor = Color(0xFFE74C3C); // Error color

// Dark Theme Colors
const Color darkPrimaryColor = Color(0xFF9B59B6); // Primary Purple for dark mode
const Color darkSecondaryColor = Color(0xFFFFA000); // Accent Orange for dark mode
const Color darkBackgroundColor = Color(0xFF1A1A2E); // Very dark background
const Color darkCardColor = Color(0xFF2D2D44); // Dark card color
const Color darkTextColor = Color(0xFFE0E0E0); // Light text for dark mode
const Color darkDisabledColor = Color(0xFF4A4A5A); // Disabled color for dark mode
const Color darkErrorColor = Color(0xFFE57373); // Error color for dark mode

// Extension to lighten/darken colors if needed
extension ColorBrightness on Color {
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

// Light Theme Definition
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimaryColor,
  scaffoldBackgroundColor: lightBackgroundColor,
  cardColor: lightCardColor,
  // Using ColorScheme for consistent color application
  colorScheme: ColorScheme.light(
    primary: lightPrimaryColor,
    secondary: lightSecondaryColor,
    surface: lightCardColor, // Used for surfaces like Card, Dialog
    background: lightBackgroundColor,
    error: lightErrorColor,
    onPrimary: Colors.white, // Text/icons on primary color
    onSecondary: Colors.white, // Text/icons on secondary color
    onSurface: lightTextColor, // Text/icons on surface color
    onBackground: lightTextColor, // Text/icons on background color
    onError: Colors.white, // Text/icons on error color
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: lightPrimaryColor,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(color: lightTextColor),
    displayMedium: TextStyle(color: lightTextColor),
    displaySmall: TextStyle(color: lightTextColor),
    headlineLarge: TextStyle(color: lightTextColor),
    headlineMedium: TextStyle(color: lightTextColor),
    headlineSmall: TextStyle(color: lightTextColor),
    titleLarge: TextStyle(color: lightTextColor),
    titleMedium: TextStyle(color: lightTextColor),
    titleSmall: TextStyle(color: lightTextColor),
    bodyLarge: TextStyle(color: lightTextColor),
    bodyMedium: TextStyle(color: lightTextColor),
    bodySmall: TextStyle(color: lightTextColor),
    labelLarge: TextStyle(color: lightTextColor),
    labelMedium: TextStyle(color: lightTextColor),
    labelSmall: TextStyle(color: lightTextColor),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: lightPrimaryColor,
      side: BorderSide(color: lightPrimaryColor.lighten(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: lightPrimaryColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: lightPrimaryColor,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightBackgroundColor.darken(0.02), // Slightly darker than background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: lightPrimaryColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    labelStyle: TextStyle(color: lightTextColor.withOpacity(0.6)),
    hintStyle: TextStyle(color: lightTextColor.withOpacity(0.4)),
    prefixIconColor: lightTextColor.withOpacity(0.7),
    suffixIconColor: lightTextColor.withOpacity(0.7),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightCardColor,
    selectedItemColor: lightPrimaryColor,
    unselectedItemColor: Colors.grey[600],
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
  ),
  iconTheme: const IconThemeData(color: lightTextColor),
  // Colors for widgets like progress indicators, chips, etc.
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: lightPrimaryColor,
    circularTrackColor: Colors.grey,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: lightCardColor,
    selectedColor: lightPrimaryColor.withOpacity(0.1),
    checkmarkColor: lightPrimaryColor,
    labelStyle: TextStyle(color: lightTextColor.withOpacity(0.8)),
    secondaryLabelStyle: TextStyle(color: lightPrimaryColor),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide(color: Colors.grey[300]!, width: 1),
  ),
);

// Dark Theme Definition
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: darkBackgroundColor,
  cardColor: darkCardColor,
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkSecondaryColor,
    surface: darkCardColor,
    background: darkBackgroundColor,
    error: darkErrorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: darkTextColor,
    onBackground: darkTextColor,
    onError: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackgroundColor, // AppBar in dark mode can be darker
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(color: darkTextColor),
    displayMedium: TextStyle(color: darkTextColor),
    displaySmall: TextStyle(color: darkTextColor),
    headlineLarge: TextStyle(color: darkTextColor),
    headlineMedium: TextStyle(color: darkTextColor),
    headlineSmall: TextStyle(color: darkTextColor),
    titleLarge: TextStyle(color: darkTextColor),
    titleMedium: TextStyle(color: darkTextColor),
    titleSmall: TextStyle(color: darkTextColor),
    bodyLarge: TextStyle(color: darkTextColor),
    bodyMedium: TextStyle(color: darkTextColor),
    bodySmall: TextStyle(color: darkTextColor),
    labelLarge: TextStyle(color: darkTextColor),
    labelMedium: TextStyle(color: darkTextColor),
    labelSmall: TextStyle(color: darkTextColor),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: darkPrimaryColor,
      side: BorderSide(color: darkPrimaryColor.lighten(0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: darkPrimaryColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkBackgroundColor.lighten(0.05), // Slightly lighter than background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    labelStyle: TextStyle(color: darkTextColor.withOpacity(0.8)),
    hintStyle: TextStyle(color: darkTextColor.withOpacity(0.6)),
    prefixIconColor: darkTextColor.withOpacity(0.8),
    suffixIconColor: darkTextColor.withOpacity(0.8),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkCardColor,
    selectedItemColor: darkPrimaryColor, // Or a more prominent color in dark mode
    unselectedItemColor: Colors.grey[400],
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
  ),
  iconTheme: const IconThemeData(color: darkTextColor),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: darkPrimaryColor,
    circularTrackColor: Colors.grey,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: darkCardColor,
    selectedColor: darkPrimaryColor.withOpacity(0.1),
    checkmarkColor: darkPrimaryColor,
    labelStyle: TextStyle(color: darkTextColor.withOpacity(0.8)),
    secondaryLabelStyle: TextStyle(color: darkPrimaryColor),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide(color: Colors.grey.shade700, width: 1),
  ),
);