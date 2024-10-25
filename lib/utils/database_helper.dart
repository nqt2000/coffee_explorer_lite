import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "coffeeApp.db";
  static final _databaseVersion = 3;

  static final userTable = 'users';
  static final userId = 'id';
  static final userName = 'name';
  static final userEmail = 'email';
  static final userPassword = 'password';
  static final userIsAdmin = 'isAdmin';

  static final cafeTable = 'cafes';
  static final cafeId = 'id';
  static final cafeName = 'name';
  static final cafeImagePath = 'imagePath';
  static final cafeAddress = 'address';
  static final cafeDescription = 'description';

  static final imageTable = 'images';
  static final imageId = 'id';
  static final idCafe = 'cafeId';

  static final commentTable = 'comments';
  static final commentId = 'id';
  static final idUser = 'userId';
  static final commentUserText = 'commentText';
  static final commentTimestamp = 'timestamp';
  static final commentIsHidden = 'isHidden';

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
      CREATE TABLE $imageTable (
        $imageId INTEGER PRIMARY KEY AUTOINCREMENT,
        $idCafe INTEGER NOT NULL,
        $cafeImagePath TEXT NOT NULL,
      FOREIGN KEY ($idCafe) REFERENCES $cafeTable ($cafeId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $commentTable (
        $commentId INTEGER PRIMARY KEY AUTOINCREMENT,
        $idCafe INTEGER NOT NULL,
        $idUser INTEGER NOT NULL,
        $commentUserText TEXT NOT NULL,
        $commentTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        $commentIsHidden INTEGER DEFAULT 0,
        FOREIGN KEY ($idCafe) REFERENCES $cafeTable ($cafeId),
        FOREIGN KEY ($idUser) REFERENCES $userTable ($userId)
      )
    ''');

    final users = [
      {
        userName: 'Admin',
        userEmail: 'admin@admin.admin',
        userPassword: 'Admin@123',
        userIsAdmin: 1,
      },
      {
        userName: 'User01',
        userEmail: 'abc@abc.abc',
        userPassword: 'A@123123',
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

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    var result = await db!.query(
      userTable,
      where: '$userEmail = ?',
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
      await db!.insert(imageTable, {
        idCafe: cafeId,
        cafeImagePath: imagePath,
      });
    }
  }

  Future<List<String>> getCafeImages(int cafeId) async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(
      imageTable,
      where: '$idCafe = ?',
      whereArgs: [cafeId],
    );
    return result.map((row) => row[cafeImagePath].toString()).toList();
  }

  Future<int> deleteCafe(int id) async {
    final db = await database;
    return await db!.delete(cafeTable, where: '$cafeId = ?', whereArgs: [id]);
  }

  Future<Map<dynamic, dynamic>?> queryUserByEmail(String email) async {
    Database? db = await instance.database;
    List<Map> result = await db!.query(
      userTable,
      columns: [userId, userName, userEmail, userIsAdmin],
      where: '$userEmail = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> insertComment(int cafeId, int userId, String commentText) async {
    Database? db = await instance.database;
    return await db!.insert('comments', {
      idCafe: cafeId,
      idUser: userId,
      commentUserText: commentText,
      commentTimestamp: DateTime.now().toIso8601String(),
    });
  }

  Future<int> hideComment(int cid, int uid) async {
    Database? db = await instance.database;

    List<Map<String, dynamic>> result = await db!.query(
      userTable,
      where: '$userId = ?',
      whereArgs: [uid],
    );

    if (result.isEmpty) {
      throw Exception('You can only delete your own comments!');
    }

    return await db.update(
      commentTable,
      {commentIsHidden: 1},
      where: '$commentId = ?',
      whereArgs: [cid],
    );
  }

  Future<Map<String, dynamic>> getCommentById(int cid) async {
    final db = await database;
    final result = await db?.query(
      commentTable,
      where: '$commentId = ?',
      whereArgs: [cid],
    );

    return result!.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getCommentsByCafe(int cid) async {
    final db = await database;

    final result = await db!.rawQuery('''
    SELECT c.$commentUserText, u.$userName AS userName, c.$commentTimestamp, c.$idUser AS userId, c.$commentId AS commentId, c.$commentIsHidden
    FROM $commentTable c
    JOIN $userTable u ON c.$idUser = u.$userId
    WHERE c.$idCafe = ?
    ORDER BY c.$commentTimestamp DESC
  ''', [cid]);

    return result;
  }

  Future<void> updateCafeImage(int cid, String imagePath) async {
    final db = await database;
    await db?.update(
      cafeTable,
      {cafeImagePath: imagePath},
      where: '$cafeId = ?',
      whereArgs: [cid],
    );
  }

  Future<int> updateCafeDetails(int cid, String name, String address, String description) async {
    final db = await instance.database;

    return db!.update(
      cafeTable,
      {
        cafeName: name,
        cafeAddress: address,
        cafeDescription: description,
      },
      where: '$cafeId = ?',
      whereArgs: [cid],
    );
  }

  Future<int> updateComment(int cid, String newComment, int uid) async{
   final db = await instance.database;

   return db!.update(
     commentTable,
     {
       commentId: cid,
       commentUserText: newComment,
     },
     where: '$userId = ?',
     whereArgs: [uid],
   );
  }
}
