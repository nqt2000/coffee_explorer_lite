import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../cafe_detail/bloc/cafe_detail_state.dart';
import '../../utils/database_helper.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(HomeLoading()) {
    on<FetchCafes>(_onFetchCafes);
    on<FilterCafes>(_onFilterCafes);
    on<PickImages>(_onPickImages);
    on<PickSingleImage>(_onPickSingleImage);
    on<AddCafe>(_onAddCafe);
    on<FetchCafeDetail>(_onFetchCafeDetail);
    on<AddImagesToCafe>(_onAddImagesToCafe);
    on<DeleteCafe>(_onDeleteCafe);
    on<LoggedOut>(_onLoggedOut);

  }

  Future<void> _onFetchCafes(FetchCafes event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final cafes = await DatabaseHelper.instance.queryAllCafes();
      emit(HomeLoaded(cafes, cafes));
    } catch (e) {
      emit(HomeError("Error fetching cafes: ${e.toString()}"));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<HomeState> emit) async {
    emit(LoggedOutState());
  }

  void _onFilterCafes(FilterCafes event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredCafes = event.query.isEmpty
          ? currentState.cafes
          : currentState.cafes.where((cafe) {
        return cafe['name']
            .toLowerCase()
            .contains(event.query.toLowerCase()) ||
            cafe['address']
                .toLowerCase()
                .contains(event.query.toLowerCase());
      }).toList();
      emit(HomeLoaded(currentState.cafes, filteredCafes));
    }
  }

  Future<void> _onPickImages(PickImages event, Emitter<HomeState> emit) async {
    int maxImageCount = 6;

    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }

    try {
      final pickedFiles = await ImagePicker().pickMultiImage(limit: 6);

      if (pickedFiles.isEmpty) {
        return;
      }

      final currentState = state;
      List<String> existingImagePaths = [];
      if (currentState is ImagePicked) {
        existingImagePaths = currentState.imagePaths;
      }

      final totalImages = existingImagePaths.length + pickedFiles.length;
      if (totalImages > maxImageCount) {
        emit(HomeError('You can only select $maxImageCount images.'));
        return;
      }

      List<String> newImagePaths = [];
      for (var pickedFile in pickedFiles) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = basename(pickedFile.path);
        final savedImagePath = '${directory.path}/$imageName';
        final File localImage = await File(pickedFile.path).copy(savedImagePath);
        newImagePaths.add(localImage.path);
      }

      final updatedImagePaths = [...existingImagePaths, ...newImagePaths];
      emit(ImagePicked(updatedImagePaths));
    } catch (e) {
      emit(HomeError('Failed to pick images: ${e.toString()}'));
    }
  }

  Future<void> _onPickSingleImage(PickSingleImage event, Emitter<HomeState> emit) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = basename(pickedFile.path);
        final savedImagePath = '${directory.path}/$imageName';

        final File localImage = await File(pickedFile.path).copy(savedImagePath);

        emit(ImagePicked([localImage.path]));
      } else {
        emit(HomeError('No image selected'));
      }
    } catch (e) {
      emit(HomeError('Failed to pick image: ${e.toString()}'));
    }
  }


  Future<void> _onAddCafe(AddCafe event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      int cafeId = await DatabaseHelper.instance.insertCafe(event.newCafe);

      if (event.newCafe['images'] != null &&
          event.newCafe['images'].isNotEmpty) {
        await DatabaseHelper.instance
            .insertCafeImages(cafeId, event.newCafe['images']);
      }

      print("Adding cafe: ${event.newCafe}");
      add(FetchCafes());
    } catch (e) {
      print("Error while adding cafe: $e");
      emit(HomeError("Failed to add cafe"));
    }
  }

  Future<void> _onFetchCafeDetail(
      FetchCafeDetail event, Emitter<HomeState> emit) async {
    emit(CafeDetailLoading() as HomeState);
    try {
      final cafe = await DatabaseHelper.instance.queryCafeById(event.cafeId);
      emit(CafeDetailLoaded(cafe!) as HomeState);
    } catch (e) {
      emit(CafeDetailError('Failed to load cafe details: ${e.toString()}') as HomeState);
    }
  }

  Future<void> _onAddImagesToCafe(
      AddImagesToCafe event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      await DatabaseHelper.instance
          .insertCafeImages(event.cafeId, event.images);
      add(FetchCafes());
    } catch (e) {
      emit(HomeError("Failed to add images: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteCafe(DeleteCafe event, Emitter<HomeState> emit) async {
    try {
      await DatabaseHelper.instance.deleteCafe(event.cafeId);
      add(FetchCafes());
    } catch (e) {
      emit(HomeError("Failed to delete cafe: ${e.toString()}"));
    }
  }
}
