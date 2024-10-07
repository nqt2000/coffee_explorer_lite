import 'home_state.dart';

class CafeDetailLoading extends HomeState {}

class CafeDetailLoaded extends HomeState {
  final Map<String, dynamic> cafe;

  const CafeDetailLoaded(this.cafe);
}

class CafeDetailError extends HomeState {
  final String message;

  const CafeDetailError(this.message);
}
