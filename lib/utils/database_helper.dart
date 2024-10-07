import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "coffeeApp.db";
  static final _databaseVersion = 2;

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

  // Bảng images
  static final cafeImages = 'images';
  static final imageId = 'id';
  static final idCafe = 'cafeId';

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

    await db.execute('''
      CREATE TABLE $cafeTable (
        $cafeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $cafeName TEXT NOT NULL,
        $cafeImagePath TEXT NOT NULL,
        $cafeAddress TEXT NOT NULL,
        $cafeDescription TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE $cafeImages (
    $imageId INTEGER PRIMARY KEY AUTOINCREMENT,
    $idCafe INTEGER NOT NULL,
    $cafeImagePath TEXT NOT NULL,
    FOREIGN KEY ($idCafe) REFERENCES $cafeTable ($cafeId) ON DELETE CASCADE
  )
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
  }

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

  Future<int> insertCafe(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (row[cafeName] == null || row[cafeName].toString().isEmpty) {
      throw Exception('Cafe name is required!');
    }

    if (row[cafeAddress] == null || row[cafeAddress].toString().isEmpty) {
      throw Exception('Cafe address is required!');
    }
    return await db!.insert(cafeTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllCafes() async {
    Database? db = await instance.database;
    return await db!.query(cafeTable);
  }

  Future<Map<String, dynamic>?> queryCafeById(int id) async {
    Database? db = await instance.database;

    List<Map<String, dynamic>> result = await db!.query(
      cafeTable,
      where: '$cafeId = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> insertCafeImages(int cafeId, List<String> imagePaths) async {
    Database? db = await instance.database;
    for (String imagePath in imagePaths) {
      await db!.insert(cafeImages, {
        idCafe: cafeId,
        cafeImagePath: imagePath,
      });
    }
  }

  Future<List<String>> getCafeImages(int cafeId) async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(
      cafeImages,
      where: '$idCafe = ?',
      whereArgs: [cafeId],
    );
    return result.map((row) => row[cafeImagePath].toString()).toList();
  }

  Future<int> deleteCafe(int id) async {
    final db = await database;
    return await db!.delete(
        'cafes',
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}
