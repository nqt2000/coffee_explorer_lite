import 'package:equatable/equatable.dart';

abstract class CafeDetailEvent extends Equatable {
  const CafeDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchCafeDetail extends CafeDetailEvent {
  final int cafeId;

  FetchCafeDetail(this.cafeId);

  @override
  List<Object> get props => [cafeId];
}

class UpdateCafeDetail extends CafeDetailEvent {
  final Map<String, dynamic> updatedCafe;

  UpdateCafeDetail(this.updatedCafe);

  @override
  List<Object> get props => [updatedCafe];
}
