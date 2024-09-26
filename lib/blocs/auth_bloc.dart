import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_explorer_lite/events/auth_event.dart';
import 'package:coffee_explorer_lite/states/auth_state.dart';
import 'package:coffee_explorer_lite/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final isSuccess = await authRepository.login(event.email, event.password);
        if (isSuccess) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Login failed. Please check your credentials.'));
        }
      } catch (e) {
        emit(AuthFailure('An error occurred. Please try again.'));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final isSuccess = await authRepository.register(event.email, event.password);
        if (isSuccess) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Registration failed. Email already exists.'));
        }
      } catch (e) {
        emit(AuthFailure('An error occurred during registration.'));
      }
    });
  }
}
