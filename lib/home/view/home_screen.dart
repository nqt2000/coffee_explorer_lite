import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../utils/session_manager.dart';
import '../../authentication/view/login_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'cafe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required userFullName, required bool isAdmin})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userFullName;
  bool? isAdmin;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final sessionManager = SessionManager();
    final userInfo = await sessionManager.getUserInfo();
    setState(() {
      userFullName = userInfo?['name'] ?? 'User';
      isAdmin = userInfo?['isAdmin'] == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchCafes()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${userFullName ?? 'User'}'),
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
                          direction: isAdmin == true
                              ? DismissDirection.horizontal
                              : DismissDirection.none,
                          background: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          secondaryBackground: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
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
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red),
                                        ),
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
                              _showAddImagesDialog(context, cafe['id']);
                              return false;
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CafeDetailScreen(cafe: cafe),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isAdmin == true) // Chỉ hiện nút thêm quán cho admin
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
    if (isAdmin == true) {
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
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return TextButton(
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only admins can add images!')),
      );
    }
  }

  Future<void> _showAddCafeDialog(BuildContext context) async {
    if (isAdmin == true) {
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Cafe Name'),
                          minLines: 1,
                          maxLines: 2,
                        ),
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(labelText: 'Address'),
                          minLines: 1,
                          maxLines: 2,
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          minLines: 5,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 10),
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
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain);
                                }).toList(),
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return TextButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final address = addressController.text.trim();

                        if (name.isEmpty || address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Name and address are required!')),
                          );
                          return;
                        }

                        final newCafe = {
                          'name': name,
                          'address': address,
                          'description': descriptionController.text,
                          'imagePath': state is ImagePicked &&
                                  state.imagePaths.isNotEmpty
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only admins can add cafes!')),
      );
    }
  }
}
