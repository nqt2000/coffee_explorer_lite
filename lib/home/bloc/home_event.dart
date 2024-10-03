import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchCafes extends HomeEvent {}

class FilterCafes extends HomeEvent {
  final String query;

  FilterCafes(this.query);

  @override
  List<Object?> get props => [query];
}

class PickImages extends HomeEvent {}

class AddCafe extends HomeEvent {
  final Map<String, dynamic> newCafe;

  AddCafe(this.newCafe);

  @override
  List<Object?> get props => [newCafe];
}

class FetchCafeDetail extends HomeEvent {
  final int cafeId;

  FetchCafeDetail(this.cafeId);
}