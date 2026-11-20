import 'package:flutter/material.dart';

class AppTheme {
  // Il colore "seme": Flutter genera da solo tutta la palette
  static const Color _seed = Color(0xFF8B5A2B); // marrone pergamena

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F1E8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F1E8),
      foregroundColor: Colors.black87,
      centerTitle: true,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1814),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1814),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}