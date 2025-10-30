import 'package:flutter/material.dart';

class AppTheme {
  // --- DEFINE YOUR COLORS ---
  static const Color pokedexRed = Color(0xFFD92A2A);
  static const Color pokedexBlue = Color(0xFF3B4CCA);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color darkGrey = Color(0xFF3B3B3B); // For cards/surfaces
  static const Color lightGrey = Color(0xFFF5F5F5); // For light text

  // --- DEFINE YOUR THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins', // This is your default font now

    // --- COLOR SCHEME ---
    scaffoldBackgroundColor: charcoal,
    primaryColor: pokedexRed,
    
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: pokedexRed,
      onPrimary: lightGrey, // Text on top of red
      secondary: pokedexBlue,
      onSecondary: lightGrey, // Main body text
      surface: darkGrey, // Card backgrounds
      onSurface: lightGrey, // Text on cards
      error: Colors.redAccent,
      onError: Colors.black,
    ),

    // --- APP BAR THEME ---
    appBarTheme: const AppBarTheme(
      backgroundColor: pokedexRed,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700, // Bold
        fontSize: 20,
      ),
    ),

    // --- FLOATING ACTION BUTTON THEME ---
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: pokedexBlue,
      foregroundColor: lightGrey,
    ),

    // --- TAB BAR THEME ---
    tabBarTheme: const TabBarThemeData(
      indicatorColor: pokedexBlue,
      labelColor: lightGrey,
      unselectedLabelColor: Colors.white54,
    ),

    // --- TEXT THEME ---
    textTheme: const TextTheme(
      // For large titles (like "DigiDex" on home screen)
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700, // Bold
        fontSize: 48.0,
        color: lightGrey,
      ),
      // For titles in AppBars or dialogs
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700, // Bold
        fontSize: 22.0,
        color: lightGrey,
      ),
      // For list tile titles, card headers
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500, // Medium
        fontSize: 18.0,
        color: lightGrey,
      ),
      // Default body text
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400, // Regular
        fontSize: 16.0,
        color: lightGrey,
        height: 1.5, // Line spacing
      ),
      // For subtitles
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400, // Regular
        fontSize: 14.0,
        color: Colors.white70,
      ),
    ),
  );
}
