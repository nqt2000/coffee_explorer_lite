import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> cafes;
  final List<Map<String, dynamic>> filteredCafes;

  HomeLoaded(this.cafes, this.filteredCafes);

  @override
  List<Object?> get props => [cafes, filteredCafes];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImagePicked extends HomeState {
  final List<String> imagePaths;

  ImagePicked(this.imagePaths);

  @override
  List<Object?> get props => [imagePaths];
}

class CafeDetailLoading extends HomeState {}

class CafeDetailLoaded extends HomeState {
  final Map<String, dynamic> cafe;

  CafeDetailLoaded(this.cafe);
}

class CafeDetailError extends HomeState {
  final String message;

  CafeDetailError(this.message);
}
