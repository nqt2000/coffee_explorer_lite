abstract class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  RegisterButtonPressed(this.name, this.email, this.password);
}

class CheckEmailExistence extends RegisterEvent {
  final String email;

  CheckEmailExistence(this.email);
}

