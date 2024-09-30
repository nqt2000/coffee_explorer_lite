import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "userDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'users';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnEmail = 'email';
  static final columnPassword = 'password';

  // Tạo singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<Map?> queryUser(String email, String password) async {
    Database? db = await instance.database;
    List<Map> result = await db!.query(table,
        where: '$columnEmail = ? AND $columnPassword = ?',
        whereArgs: [email, password]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    var result = await db!.query(
      'users', // Bảng của bạn
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}
