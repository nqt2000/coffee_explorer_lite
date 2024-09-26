class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email không được để trống';
    }
    String emailPattern =
        r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất một ký tự viết hoa';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
}
