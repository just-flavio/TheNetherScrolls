// ===== IMPORT =====
import 'dart:convert'; // jsonEncode / jsonDecode: oggetto <-> testo JSON
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb = true se l'app gira su Chrome
import 'package:sqflite/sqflite.dart'; // il database SQL (solo Android/iOS)
import 'package:path/path.dart'; // join(): costruisce percorsi di file
import 'package:thenetherscrolls/data/character.dart'; // CharacterSheet con toJson/fromJson

// Questa classe contiene SOLO codice che parla col database.
// Le schermate non scrivono mai SQL: chiamano questi metodi.
// I metodi sono "static": si usano senza creare un oggetto,
// es. DatabaseService.getAllCharacters()
class DatabaseService {
  // Il database aperto. Parte vuoto (null) e si riempie alla prima richiesta.
  // "_" = privato: nessun altro file può toccarlo.
  static Database? _db;

  // Getter: restituisce il database, aprendolo se serve.
  static Future<Database> get database async {
    // Se è già aperto, lo restituisco subito (non lo riapro)
    if (_db != null) return _db!; // "!" = so che qui non è null

    // openDatabase: se il file non esiste lo CREA, altrimenti lo apre
    _db = await openDatabase(
      // Percorso: cartella dei database dell'app + nome del file
      join(await getDatabasesPath(), 'netherscrolls.db'),
      version: 1, // aumenterai questo numero quando cambierai la struttura
      // onCreate parte UNA sola volta, quando il file viene creato
      onCreate: (db, version) {
        // Crea la tabella "characters" con 3 colonne:
        //  id   = numero unico, assegnato dal database (1, 2, 3...)
        //  name = nome del personaggio
        //  data = tutto il personaggio in formato JSON (testo)
        return db.execute(
          'CREATE TABLE characters('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'data TEXT)',
        );
      },
    );
    return _db!;
  }

  // ===== READ: legge tutti i personaggi =====
  static Future<List<CharacterSheet>> getAllCharacters() async {
    if (kIsWeb) return []; // su Chrome il database non esiste: lista vuota

    final db = await database;
    // query = SELECT * FROM characters ORDER BY id
    // Restituisce una lista di righe; ogni riga è una Map {'id': 1, 'name': ..., 'data': ...}
    final rows = await db.query('characters', orderBy: 'id');

    // Trasformo ogni riga in un CharacterSheet
    return rows.map((row) {
      // 1. il testo JSON nella colonna "data" -> Map
      final json = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      // 2. Map -> personaggio, mettendogli l'id del database
      return CharacterSheet.fromJson(json, id: row['id'] as int);
    }).toList();
  }

  // ===== CREATE: salva un personaggio nuovo =====
  static Future<void> insertCharacter(CharacterSheet character) async {
    if (kIsWeb) return; // su Chrome non salva (il personaggio resta solo in memoria)

    final db = await database;
    // insert restituisce l'id assegnato alla nuova riga: lo scrivo nel personaggio.
    // Servirà dopo per aggiornarlo o eliminarlo.
    character.id = await db.insert('characters', {
      'name': character.characterName,
      'data': jsonEncode(character.toJson()), // personaggio -> testo JSON
    });
  }

  // ===== UPDATE: riscrive un personaggio già salvato =====
  static Future<void> updateCharacter(CharacterSheet character) async {
    if (kIsWeb) return;
    if (character.id == null) return; // mai salvato: niente da aggiornare

    final db = await database;
    await db.update(
      'characters',
      {'name': character.characterName, 'data': jsonEncode(character.toJson())},
      where: 'id = ?', // SOLO la riga con questo id (senza where cambierebbe tutte!)
      whereArgs: [character.id], // il "?" viene sostituito in modo sicuro
    );
  }

  // ===== DELETE: elimina un personaggio =====
  static Future<void> deleteCharacter(CharacterSheet character) async {
    if (kIsWeb) return;
    if (character.id == null) return;

    final db = await database;
    await db.delete('characters', where: 'id = ?', whereArgs: [character.id]);
  }
}