import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../utils/session_manager.dart';
import '../authentication/view/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail; // Truyền email user để kiểm tra quyền admin

  HomeScreen({required this.userEmail});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isAdmin = false; // Biến để lưu trạng thái quyền admin
  List<Map<String, dynamic>> cafes = [];

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _fetchCafes();
  }

  // Kiểm tra xem user có phải admin hay không
  Future<void> _checkIfAdmin() async {
    bool adminStatus = await DatabaseHelper.instance.isAdmin(widget.userEmail);
    setState(() {
      isAdmin = adminStatus;
    });
  }

  // Lấy danh sách các quán cà phê
  Future<void> _fetchCafes() async {
    List<Map<String, dynamic>> cafeList =
    await DatabaseHelper.instance.queryAllCafes();
    setState(() {
      cafes = cafeList;
    });
  }

  // Đăng xuất và quay lại màn hình login
  void _logout() async {
    await SessionManager().clearSession(); // Xóa session hiện tại
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Hiển thị hộp thoại để thêm quán cà phê
  Future<void> _showAddCafeDialog() async {
    final nameController = TextEditingController();
    final imagePathController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Cafe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Cafe Name'),
              ),
              TextField(
                controller: imagePathController,
                decoration: InputDecoration(labelText: 'Image Path'),
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
          actions: [
            ElevatedButton(
              onPressed: () async {
                final newCafe = {
                  'name': nameController.text,
                  'imagePath': imagePathController.text,
                  'address': addressController.text,
                  'description': descriptionController.text,
                };
                await DatabaseHelper.instance.insertCafe(newCafe);
                Navigator.of(context).pop();
                _fetchCafes(); // Cập nhật lại danh sách quán cà phê
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false, // Tắt nút back
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Thực hiện chức năng logout
          ),
        ],
      ),
      body: Column(
        children: [
          if (isAdmin)
            ElevatedButton(
              onPressed: _showAddCafeDialog,
              child: Text('Add Cafe'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: cafes.length,
              itemBuilder: (context, index) {
                final cafe = cafes[index];
                return ListTile(
                  title: Text(cafe['name']),
                  subtitle: Text(cafe['address']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
