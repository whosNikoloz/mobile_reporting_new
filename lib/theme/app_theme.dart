import 'package:flutter/material.dart';

class AppTheme {
  // Primary blue color - matches existing accent color
  static const Color primaryBlue = Color.fromARGB(255, 0, 68, 124);
  static const Color lightBlue = Color.fromARGB(255, 33, 150, 243);

  // Background colors
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // Text colors
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color hintTextColor = Color(0xFF9E9E9E);

  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: lightBlue,
      surface: surfaceColor,
      background: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryTextColor,
      onBackground: primaryTextColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryBlue),
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryBlue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryBlue, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      hintStyle: const TextStyle(color: hintTextColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryTextColor),
      displayMedium: TextStyle(color: primaryTextColor),
      displaySmall: TextStyle(color: primaryTextColor),
      headlineLarge: TextStyle(color: primaryTextColor),
      headlineMedium: TextStyle(color: primaryTextColor),
      headlineSmall: TextStyle(color: primaryTextColor),
      titleLarge: TextStyle(color: primaryTextColor),
      titleMedium: TextStyle(color: primaryTextColor),
      titleSmall: TextStyle(color: primaryTextColor),
      bodyLarge: TextStyle(color: primaryTextColor),
      bodyMedium: TextStyle(color: primaryTextColor),
      bodySmall: TextStyle(color: secondaryTextColor),
      labelLarge: TextStyle(color: primaryTextColor),
      labelMedium: TextStyle(color: primaryTextColor),
      labelSmall: TextStyle(color: secondaryTextColor),
    ),
  );
}
