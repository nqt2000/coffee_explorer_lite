import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "coffeeApp.db";
  static final _databaseVersion = 1;

  // Bảng users
  static final userTable = 'users';
  static final userId = 'id';
  static final userName = 'name';
  static final userEmail = 'email';
  static final userPassword = 'password';
  static final userIsAdmin = 'isAdmin';

  // Bảng cafes
  static final cafeTable = 'cafes';
  static final cafeId = 'id';
  static final cafeName = 'name';
  static final cafeImagePath = 'imagePath';
  static final cafeAddress = 'address';
  static final cafeDescription = 'description';

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
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        $userId INTEGER PRIMARY KEY AUTOINCREMENT,
        $userName TEXT NOT NULL,
        $userEmail TEXT NOT NULL,
        $userPassword TEXT NOT NULL,
        $userIsAdmin INTEGER NOT NULL DEFAULT 0 )
    ''');

    final users = [
      {
        'name': 'Admin',
        'email': 'admin@admin.admin',
        'password': 'Admin@123',
        'isAdmin': 1,
      },
      {
        'name': 'User01',
        'email': 'abc@abc.abc',
        'password': 'A@123123',
      },
    ];

    for (var user in users) {
      await db.insert(userTable, user);
    }

    await db.execute('''
      CREATE TABLE $cafeTable (
        $cafeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $cafeName TEXT NOT NULL,
        $cafeImagePath TEXT NOT NULL,
        $cafeAddress TEXT NOT NULL,
        $cafeDescription TEXT NOT NULL
      )
    ''');
  }

  // Chức năng dành cho users
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(userTable, row);
  }

  Future<Map?> queryUser(String email, String password) async {
    Database? db = await instance.database;
    List<Map> result = await db!.query(userTable,
        where: '$userEmail = ? AND $userPassword = ?',
        whereArgs: [email, password]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> isAdmin(String email) async {
    Database? db = await instance.database;
    List<Map> result = await db!.query(
      userTable,
      where: '$userEmail = ? AND $userIsAdmin = 1',
      whereArgs: [email],
    );
    print('check');
    return result.isNotEmpty;
  }

    Future<bool> emailExists(String email) async {
    final db = await instance.database;
    var result = await db!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Chức năng dành cho cafes
  Future<int> insertCafe(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(cafeTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllCafes() async {
    Database? db = await instance.database;
    return await db!.query(cafeTable);
  }
}
