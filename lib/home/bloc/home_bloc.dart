import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../utils/database_helper.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoading()) {
    on<FetchCafes>(_onFetchCafes);
    on<FilterCafes>(_onFilterCafes);
    on<PickImages>(_onPickImages);
    on<AddCafe>(_onAddCafe);
  }

  Future<void> _onFetchCafes(FetchCafes event, Emitter<HomeState> emit) async {
    emit(HomeLoading()); // Hiển thị loading khi bắt đầu
    try {
      final cafes = await DatabaseHelper.instance.queryAllCafes();
      emit(HomeLoaded(cafes, cafes));
    } catch (e) {
      emit(HomeError("Error fetching cafes: ${e.toString()}"));
    }
  }

  void _onFilterCafes(FilterCafes event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredCafes = event.query.isEmpty
          ? currentState.cafes
          : currentState.cafes.where((cafe) {
        return cafe['name'].toLowerCase().contains(event.query.toLowerCase()) ||
            cafe['address'].toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      emit(HomeLoaded(currentState.cafes, filteredCafes));
    }
  }

  Future<void> _onPickImages(PickImages event, Emitter<HomeState> emit) async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();

      List<String> imagePaths = [];
      for (var pickedFile in pickedFiles) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = basename(pickedFile.path);
        final savedImagePath = '${directory.path}/$imageName';
        final File localImage = await File(pickedFile.path).copy(savedImagePath);
        imagePaths.add(localImage.path);
      }
      emit(ImagePicked(imagePaths));
    } catch (e) {
      emit(HomeError('Failed to pick images: ${e.toString()}'));
    }
  }

  Future<void> _onAddCafe(AddCafe event, Emitter<HomeState> emit) async {
    emit(HomeLoading()); // Hiển thị loading khi bắt đầu
    try {
      print(
          "Adding cafe: ${event.newCafe}"); // Thêm log để kiểm tra dữ liệu cafe
      await DatabaseHelper.instance.insertCafe(event.newCafe);
      add(FetchCafes()); // Fetch lại dữ liệu sau khi thêm
    } catch (e) {
      print("Error while adding cafe: $e");
      emit(HomeError("Failed to add cafe"));
    }
  }
}
