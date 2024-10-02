import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../utils/database_helper.dart';
import '../utils/session_manager.dart';
import '../authentication/view/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  HomeScreen({required this.userEmail});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> cafes = [];
  List<Map<String, dynamic>> filteredCafes = [];
  final TextEditingController searchController = TextEditingController();
  String? selectedImagePath; // For the image picked by the user

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchCafes();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCafes() async {
    List<Map<String, dynamic>> cafeList = await DatabaseHelper.instance.queryAllCafes();
    setState(() {
      cafes = cafeList;
      filteredCafes = cafeList;
    });
  }

  void _filterCafes(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCafes = cafes;
      });
    } else {
      setState(() {
        filteredCafes = cafes
            .where((cafe) =>
        cafe['name'].toLowerCase().contains(query.toLowerCase()) ||
            cafe['address'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _showAddCafeDialog() async {
    final nameController = TextEditingController();
    final imagePathController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedImagePath;

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = basename(pickedFile.path);
        final savedImagePath = '${directory.path}/$imageName';

        final File localImage = await File(pickedFile.path).copy(savedImagePath);
        setState(() {
          selectedImagePath = localImage.path;
        });
      }
    }

    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Cafe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Cafe Name'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),
                if (selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Image selected: $selectedImagePath'),
                  ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newCafe = {
                    'name': nameController.text,
                    'imagePath': selectedImagePath ?? '',
                    'address': addressController.text,
                    'description': descriptionController.text,
                  };
                  await DatabaseHelper.instance.insertCafe(newCafe);
                  Navigator.of(context).pop();
                  await _fetchCafes();

                  // Reset lại tất cả các TextEditingController
                  nameController.clear();
                  imagePathController.clear();
                  addressController.clear();
                  descriptionController.clear();
                  setState(() {
                    selectedImagePath = null; // Xóa giá trị ảnh
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a cafe name')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await SessionManager().clearSession();
    Navigator.of(this.context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cafes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterCafes,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCafes.length,
              itemBuilder: (context, index) {
                final cafe = filteredCafes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: cafe['imagePath'] != null && cafe['imagePath'].isNotEmpty
                          ? Image.file(File(cafe['imagePath']), fit: BoxFit.cover)
                          : Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(cafe['name'] ?? 'Cafe Name'),
                    subtitle: Text(cafe['address'] ?? 'Address'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddCafeDialog,
              child: Text('Add Cafe'),
            ),
          ),
        ],
      ),
    );
  }
}
