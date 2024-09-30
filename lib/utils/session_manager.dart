import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String userEmailKey = 'USER_EMAIL';

  Future<void> saveUserSession(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, email);
  }

  Future<String?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
  }
}
