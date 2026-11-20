import 'package:flutter/material.dart';
import 'package:thenetherscrolls/screens/HomeScreen.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/services/database_service.dart';
import 'package:thenetherscrolls/data/themeController.dart';
import 'package:thenetherscrolls/data/themeData.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.load(); // legge il tema salvato

  if (!kIsWeb) {
    try {
      characters.addAll(await DatabaseService.getAllCharacters());
    } catch (e) {
      debugPrint('ERRORE DATABASE: $e');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder = "ridisegna quando il tema cambia"
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'The Nether Scrolls',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const Homescreen(),
        );
      },
    );
  }
}
