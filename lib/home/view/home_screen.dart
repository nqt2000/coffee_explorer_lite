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

  const HomeScreen({super.key, required this.userEmail});

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
                        return Dismissible(
                          key: Key(cafe['id'].toString()),
                          direction: DismissDirection.horizontal,
                          // Cho phép trượt theo cả 2 hướng
                          background: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            color: Colors.green,
                            // Màu nền khi trượt sang phải để thêm ảnh
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: AlignmentDirectional.centerStart,
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          secondaryBackground: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            color: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: AlignmentDirectional.centerEnd,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // Hành động xóa cafe
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete this cafe?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              // Hành động thêm ảnh
                              _showAddImagesDialog(context, cafe['id']);
                              return false; // Ngăn không cho widget bị xóa khi trượt sang phải
                            }
                            return null;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              final cafeName = cafe['name'];
                              context
                                  .read<HomeBloc>()
                                  .add(DeleteCafe(cafe['id']));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("$cafeName deleted"),
                              ));
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.fromLTRB(
                                15.0, 10.0, 15.0, 10.0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: cafe['imagePath'] != null &&
                                            cafe['imagePath'].isNotEmpty
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(cafe['imagePath'])),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: cafe['imagePath'] == null ||
                                          cafe['imagePath'].isEmpty
                                      ? Icon(Icons.image,
                                          color: Colors.grey, size: 30)
                                      : null,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cafe['name'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      cafe['address'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      cafe['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Mở màn hình chi tiết cafe khi nhấn vào quán
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CafeDetailScreen(cafe: cafe),
                                    ),
                                  );
                                },
                                trailing: Icon(Icons
                                    .arrow_forward_ios), // Biểu tượng mở chi tiết
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
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

  Future<void> _showAddImagesDialog(BuildContext context, int cafeId) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<HomeBloc>(context),
          child: AlertDialog(
            title: Text('Add Images'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
            actions: [
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      if (state is ImagePicked) {
                        context
                            .read<HomeBloc>()
                            .add(AddImagesToCafe(cafeId, state.imagePaths));
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: Text('Add Images'),
                  );
                },
              ),
            ],
          ),
        );
      },
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
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();

                      if (name.isEmpty || address.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Name and address are required!')),
                        );
                        return;
                      }

                      final newCafe = {
                        'name': name,
                        'address': address,
                        'description': descriptionController.text,
                        'imagePath':
                            state is ImagePicked && state.imagePaths.isNotEmpty
                                ? state.imagePaths[0]
                                : '',
                      };
                      context.read<HomeBloc>().add(AddCafe(newCafe));
                      Navigator.of(dialogContext).pop();
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
