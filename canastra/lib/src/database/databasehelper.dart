import 'package:canastra/src/model/partida.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'canastra.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE partidas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        jogadores TEXT,
        pontuacao TEXT
      )
    ''');
  }

  Future<int> insertPartida(Partida partida) async {
    final db = await database;
    return await db.insert('partidas', partida.toMap());
  }

  Future<List<Partida>> getPartidas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('partidas');

    return List.generate(maps.length, (i) {
      return Partida.fromMap(maps[i]);
    });
  }

  Future<void> deletePartida(int id) async {
    final db = await database;
    await db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }
}
