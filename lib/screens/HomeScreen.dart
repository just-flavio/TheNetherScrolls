//////////////////////////////////////////////////
///
/// Flavio Ricci
///
//////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:thenetherscrolls/screens/CharacterDetailsView.dart';
import 'package:thenetherscrolls/screens/AddNewCharacterView.dart';
import 'package:thenetherscrolls/screens/DiceScreen.dart';
import 'package:thenetherscrolls/widgets/AppBottomNavBar.dart';
import 'package:thenetherscrolls/widgets/character_tile.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/data/themeController.dart';

// StatefulWidget = pagina che può cambiare mentre la guardi.
// Qui serve perché la lista si aggiorna (nuovo personaggio, eliminazione).
class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  // Collega il widget al suo "stato" (_HomescreenState), dove sta la logica
  @override
  State<Homescreen> createState() => _HomescreenState();
}

// Lo stato: contiene i dati che cambiano e il metodo build che disegna la pagina.
// Il "_" davanti lo rende privato a questo file.
class _HomescreenState extends State<Homescreen> {
  // Quale voce della barra in basso è selezionata (0 = Personaggi)
  int _currentIndex = 0;

  // build() viene richiamato ogni volta che chiami setState: ridisegna la pagina
  @override
  Widget build(BuildContext context) {
    // Scaffold = lo "scheletro" della pagina: barra in alto, corpo, pulsante, barra in basso
    return Scaffold(
      // ===== BARRA IN ALTO =====
      appBar: AppBar(
        title: const Text('"The Nether Scrolls"'),
        actions: [
          // Pulsante per cambiare tema, a destra nella barra
          IconButton(
            tooltip: 'Cambia tema', // testo che compare tenendo premuto
            icon: Icon(
              // Se il tema è scuro mostra il sole, altrimenti la luna
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Controllo com'è il tema adesso...
              final isDark = Theme.of(context).brightness == Brightness.dark;
              // ...e imposto quello opposto. Il controller ridisegna tutta l'app e salva la scelta.
              ThemeController.set(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),

      // ===== CORPO: la lista dei personaggi =====
      // ListView.builder crea le righe una alla volta, solo quando servono
      body: ListView.builder(
        itemCount: characters.length, // quante righe: una per personaggio
        itemBuilder: (context, index) {
          // index = numero della riga (0, 1, 2...): prendo il personaggio corrispondente
          final character = characters[index];
          return CharacterTile(
            character: character, // i dati da mostrare nella riga
            onTap: () async {
              // Quando tocchi la riga: apro la scheda...
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterDetails(character: character),
                ),
              );
              // ...e quando torno indietro ridisegno la lista
              // (il personaggio potrebbe essere stato modificato o eliminato)
              setState(() {});
            },
          );
        },
      ),

      // ===== PULSANTE "+" per creare un personaggio =====
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await = aspetta che la pagina di creazione si chiuda
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddnewCharacter()),
          );
          setState(() {}); // ridisegna la lista: ora c'è il personaggio nuovo
        },
        child: const Icon(Icons.add), // l'icona "+" dentro il pulsante
      ),

      // ===== BARRA IN BASSO =====
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _currentIndex, // quale voce è evidenziata
        onDestinationSelected: (index) {
          // index = la voce toccata (0 = Personaggi, 1 = Dadi, ...)
          if (index == 1) {
            // Voce 1: apro la pagina Dadi
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiceScreen()),
            );
          } else {
            if (index == 2) {
              // Voce 2: per ora apre ancora i Dadi (era un segnaposto per le Note)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiceScreen()),
              );
              return; // esco, così non eseguo il setState qui sotto
            }
          }
          // Arrivo qui solo toccando la voce 0, o dopo la voce 1
          setState(() {
            _currentIndex = index; // evidenzio la voce toccata
          });
        },
      ),
    );
  }
}