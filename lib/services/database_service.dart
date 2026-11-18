import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  //apre il db "static" perche di database ce ne solo uno per tutta l'app
  static Database? _db;
  //se è già aperto lo restituisce altrimenti ne apre uno creandolo nuovo
  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'nether.db'),
      version: 1,
      onCreate: ((db, version) {
        return db.execute(
          'CREATE TABLE notes(id Integer Primary Key AutoIncrement, text TEXT)',
        );
      }),
    );
    return _db!;
  }
}
