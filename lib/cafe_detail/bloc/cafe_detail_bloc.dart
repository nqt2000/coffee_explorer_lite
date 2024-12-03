import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'cafe_detail_event.dart';
import 'cafe_detail_state.dart';
import '../../utils/database_helper.dart';

class CafeDetailBloc extends Bloc<CafeDetailEvent, CafeDetailState> {
  final DatabaseHelper databaseHelper;

  CafeDetailBloc(this.databaseHelper) : super(CafeDetailInitial());

  Stream<CafeDetailState> mapEventToState(CafeDetailEvent event) async* {
    if (event is FetchCafeDetail) {
      yield CafeDetailLoading();
      try {
        final cafe = await databaseHelper.queryCafeById(event.cafeId);
        if (cafe != null) {
          yield CafeDetailLoaded(cafe);
        } else {
          yield CafeDetailError("Cafe not found");
        }
      } catch (e) {
        yield CafeDetailError("Failed to load cafe details");
      }
    } else if (event is UpdateCafeDetail) {
      yield CafeDetailLoading();
      try {
        await databaseHelper.updateCafeDetails(
          event.updatedCafe['id'],
          event.updatedCafe['name'],
          event.updatedCafe['address'],
          event.updatedCafe['description'],
        );
        yield CafeDetailUpdated(event.updatedCafe);
      } catch (e) {
        yield CafeDetailError("Failed to update cafe");
      }
    }
  }
}
