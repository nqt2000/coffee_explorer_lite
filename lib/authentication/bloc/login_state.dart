abstract class LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String email;

  LoginSuccess(this.email);
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}
