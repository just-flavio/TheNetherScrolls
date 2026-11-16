import 'package:flutter/material.dart';
import 'package:thenetherscrolls/screens/CharacterDetailsView.dart';
import 'package:thenetherscrolls/screens/AddNewCharacterView.dart';
import 'package:thenetherscrolls/screens/DiceScreen.dart';
import 'package:thenetherscrolls/widgets/AppBottomNavBar.dart';
import 'package:thenetherscrolls/widgets/character_tile.dart';
import 'package:thenetherscrolls/data/character.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        title: const Text('"The Nether Scrolls"'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return CharacterTile(
            character: character,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterDetails(character: character),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddnewCharacter()),
          );
          setState(() {}); // ridisegna la lista
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiceScreen()),
            );
          } else {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiceScreen()),
              );
              return;
            }
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
