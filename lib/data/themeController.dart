import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const _key = 'theme_mode';

  // Un "contenitore" che avvisa chi lo ascolta quando il valore cambia
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  // Leggi la scelta salvata (da chiamare all'avvio)
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      mode.value = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // se non riesce a leggere, resta "system"
    }
  }

  // Cambia e salva
  static Future<void> set(ThemeMode newMode) async {
    mode.value = newMode; // l'app si ridisegna subito
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newMode.name); // "light" / "dark" / "system"
    } catch (_) {}
  }
}