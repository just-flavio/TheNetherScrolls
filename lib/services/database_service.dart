import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thenetherscrolls/data/character.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'netherscrolls.db'),
      version: 1,
      onCreate: (db, version) {
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

  // READ: tutti i personaggi
  static Future<List<CharacterSheet>> getAllCharacters() async {
    final db = await database;
    final rows = await db.query('characters', orderBy: 'id');
    return rows.map((row) {
      final json = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return CharacterSheet.fromJson(json, id: row['id'] as int);
    }).toList();
  }

  // CREATE
  static Future<void> insertCharacter(CharacterSheet c) async {
    final db = await database;
    c.id = await db.insert('characters', {
      'name': c.characterName,
      'data': jsonEncode(c.toJson()),
    });
  }

  // UPDATE
  static Future<void> updateCharacter(CharacterSheet c) async {
    if (c.id == null) return;
    final db = await database;
    await db.update(
      'characters',
      {'name': c.characterName, 'data': jsonEncode(c.toJson())},
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  // DELETE
  static Future<void> deleteCharacter(CharacterSheet c) async {
    if (c.id == null) return;
    final db = await database;
    await db.delete('characters', where: 'id = ?', whereArgs: [c.id]);
  }
}