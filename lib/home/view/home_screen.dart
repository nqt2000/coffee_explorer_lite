import 'package:coffee_explorer_lite/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../../utils/session_manager.dart';
import '../../authentication/view/login_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../cafe_detail/view/cafe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required userFullName, required bool isAdmin})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userFullName;
  bool isAdmin = false;
  DateTime timeBackPressed = DateTime.now();
  final HomeBloc homeBloc = HomeBloc();

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic) {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= Duration(seconds: 2);
        timeBackPressed = DateTime.now();

        if (isExitWarning) {
          Fluttertoast.showToast(msg: 'Press back again to exit');
        } else {
          Fluttertoast.cancel();
          SystemNavigator.pop();
        }
      },
      child: BlocProvider(
        create: (context) => HomeBloc()..add(FetchCafes()),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Welcome, ${userFullName ?? 'User'}'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    // Hiển thị AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm logut"),
                          content: Text("Are you sure you want to log out?"),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: PrimaryButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    title: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.02),
                                Expanded(
                                  child: PrimaryButton(
                                    onPressed: () {
                                      SessionManager().clearSession();
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginScreen()),
                                      );
                                    },
                                    title: Text(
                                      "Logout",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
              leading: null,
              automaticallyImplyLeading: false,
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
                            hintText: "Search",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                                            'Are you sure you want to delete this coffee shop?'),
                                        actions: <Widget>[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: PrimaryButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  title: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02),
                                              Expanded(
                                                child: PrimaryButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  title: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            ],
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
                                                fit: BoxFit.contain,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      ],
                                    ),
                                    onTap: () async {
                                      final updatedImagePath =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CafeDetailScreen(cafe: cafe),
                                        ),
                                      );

                                      if (updatedImagePath != null) {
                                        switch (updatedImagePath) {
                                          case "refresh":
                                            {
                                              context
                                                  .read<HomeBloc>()
                                                  .add(FetchCafes());
                                            }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isAdmin == true)
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: PrimaryButton(
                              onPressed: () => _showAddCafeDialog(context),
                              title: Text(
                                "Add New Coffee Shop",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                    ],
                  );
                } else {
                  return Center(child: Text("Something went wrong!"));
                }
              },
            ),
          ),
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

                  BlocListener<HomeBloc, HomeState>(
                    listener: (context, state) {
                      if (state is HomeError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                        context.read<HomeBloc>().add(FetchCafes());
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: BlocBuilder<HomeBloc, HomeState>(
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
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  PrimaryButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(PickImages());
                    },
                    title: Text(
                      'Upload Images',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  // Text(
                  //   '*** 6 IMAGES ONLY! ***',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.red,
                  //       decoration: TextDecoration.underline,
                  //       decorationColor: Colors.red),
                  // ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                        return PrimaryButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(FetchCafes());
                            Navigator.of(dialogContext).pop();
                          },
                          title: Text(
                            'Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        );
                      }),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            onPressed: () {
                              if (state is ImagePicked) {
                                context.read<HomeBloc>().add(
                                    AddImagesToCafe(cafeId, state.imagePaths));
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            title: Text(
                              'Add Images',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          );
                        },
                      ),
                    )
                  ],
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
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: AlertDialog(
                title: Text('Add New Coffee Shop'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: ListView(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.02),
                              child: Text('Coffee Shop Name'),
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                            ),
                            maxLines: 1,
                            maxLength: 25,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.02),
                              child: Text('Address'),
                            ),
                          ),
                          TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            maxLength: 150,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.02),
                              child: Text('Description'),
                            ),
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                            ),
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 300,
                            keyboardType: TextInputType.multiline,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01),
                          PrimaryButton(
                            onPressed: () {
                              context.read<HomeBloc>().add(PickSingleImage());
                            },
                            title: Text(
                              'Upload Logo Shop',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              if (state is ImagePicked) {
                                return Center(
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: state.imagePaths.map((path) {
                                      return Image.file(File(path),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain);
                                    }).toList(),
                                  ),
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
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(FetchCafes());
                            Navigator.of(dialogContext).pop();
                          },
                          title: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Expanded(
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                final address = addressController.text.trim();

                                if (name.isEmpty || address.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Name and address are required!')),
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
                              title: Text(
                                'Add',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only admins can add new coffee shop!')),
      );
    }
  }
}
