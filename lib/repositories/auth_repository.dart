import '../data/db_helper.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    return await _dbHelper.loginUser(email, password);
  }

  // Hàm đăng ký người dùng
  Future<bool> register(String email, String password) async {
    try {
      await _dbHelper.insertUser(email, password);
      return true;
    } catch (e) {
      // Xử lý trường hợp email đã tồn tại
      return false;
    }
  }
}
