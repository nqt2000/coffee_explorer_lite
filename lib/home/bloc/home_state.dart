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

  const HomeLoaded(this.cafes, this.filteredCafes);

  @override
  List<Object?> get props => [cafes, filteredCafes];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImagePicked extends HomeState {
  final List<String> imagePaths;

  const ImagePicked(this.imagePaths);

  @override
  List<Object?> get props => [imagePaths];
}

