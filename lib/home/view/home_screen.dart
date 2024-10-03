import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../utils/session_manager.dart';
import '../../authentication/view/login_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'cafe_detail_screen.dart'; // Import CafeDetailScreen

class HomeScreen extends StatelessWidget {
  final String userEmail;

  HomeScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchCafes()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cafes'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                SessionManager().clearSession();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (query) {
                        context.read<HomeBloc>().add(FilterCafes(query));
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.filteredCafes.length,
                      itemBuilder: (context, index) {
                        final cafe = state.filteredCafes[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: cafe['imagePath'] != null &&
                                  cafe['imagePath'].isNotEmpty
                                  ? Image.file(File(cafe['imagePath']),
                                  fit: BoxFit.contain)
                                  : Icon(Icons.image, color: Colors.grey),
                            ),
                            title: Text(cafe['name']),
                            subtitle: Text(cafe['address']),
                            onTap: () {
                              // Chuyển sang màn hình chi tiết quán cafe
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CafeDetailScreen(cafe: cafe),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => _showAddCafeDialog(context),
                      child: Text('Add Cafe'),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("Something went wrong!"));
            }
          },
        ),
      ),
    );
  }

  Future<void> _showAddCafeDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<HomeBloc>(context),
          child: AlertDialog(
            title: Text('Add Cafe'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Cafe Name'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(PickImages());
                    },
                    child: Text('Upload Images'),
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is ImagePicked) {
                        return Wrap(
                          spacing: 8.0,
                          children: state.imagePaths.map((path) {
                            return Image.file(File(path),
                                width: 100, height: 100, fit: BoxFit.contain);
                          }).toList(),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      final newCafe = {
                        'name': nameController.text,
                        'address': addressController.text,
                        'description': descriptionController.text,
                        'imagePath': state is ImagePicked &&
                            state.imagePaths.isNotEmpty
                            ? state.imagePaths[0]
                            : '', // Giá trị rỗng nếu không có ảnh
                      };
                      context.read<HomeBloc>().add(AddCafe(newCafe));
                      Navigator.of(dialogContext).pop(); // Đóng dialog
                    },
                    child: Text('Add'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
