import 'package:sqflite/sqflite.dart';

Future _createDB(Database db, int version) async {
  const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  const textType = 'TEXT NOT NULL';

  await db.execute('''
  CREATE TABLE users (
    id $idType,
    email $textType,
    password $textType
  )
  ''');

  await db.execute('''
  CREATE TABLE coffee_shops ( 
    id $idType, 
    name $textType,
    location $textType,
    description $textType
  )
  ''');
}

class User {
  final int? id;
  final String email;
  final String password;

  User({
    this.id,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }
}
