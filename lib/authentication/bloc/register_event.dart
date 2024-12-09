abstract class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String repassword;

  RegisterButtonPressed(this.name, this.email, this.password, this.repassword);
}
