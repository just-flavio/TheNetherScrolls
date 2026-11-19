import 'package:flutter/material.dart';
import 'package:thenetherscrolls/screens/HomeScreen.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // serve prima di usare il disco
  characters.addAll(await DatabaseService.getAllCharacters());
  runApp(const MyApp()); // il tuo runApp com'era
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Homescreen());
  }
}
