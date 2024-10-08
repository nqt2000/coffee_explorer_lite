import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class SessionManager {
  static const String userEmailKey = 'USER_EMAIL';
  static const String isLoggedInKey = 'IS_LOGGED_IN';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveUserSession(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, email);
    await prefs.setBool(isLoggedInKey, true);
  }

  Future<String?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
    await prefs.remove(isLoggedInKey);
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(userEmailKey);
    if (email != null) {
      Map<dynamic, dynamic>? userInfo = await _dbHelper.queryUserByEmail(email);
      if (userInfo != null) {
        return Map<String, dynamic>.from(userInfo);
      }
    }
    return null;
  }
}
