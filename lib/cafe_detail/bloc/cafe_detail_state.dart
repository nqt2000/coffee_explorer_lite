import 'package:equatable/equatable.dart';

abstract class CafeDetailState extends Equatable {
  const CafeDetailState();

  @override
  List<Object> get props => [];
}

class CafeDetailInitial extends CafeDetailState {}

class CafeDetailLoading extends CafeDetailState {}

class CafeDetailLoaded extends CafeDetailState {
  final Map<String, dynamic> cafe;

  const CafeDetailLoaded(this.cafe);

  @override
  List<Object> get props => [cafe];
}

class CafeDetailUpdated extends CafeDetailState {
  final Map<String, dynamic> updatedCafe;

  const CafeDetailUpdated(this.updatedCafe);

  @override
  List<Object> get props => [updatedCafe];
}

class CafeDetailError extends CafeDetailState {
  final String message;

  const CafeDetailError(this.message);

  @override
  List<Object> get props => [message];
}
