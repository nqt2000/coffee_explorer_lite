import 'package:flutter/material.dart';
import 'authentication/view/login_screen.dart';
import 'home/view/home_screen.dart';
import 'utils/session_manager.dart';
import 'utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SessionManager sessionManager = SessionManager();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  String? email = await sessionManager.getUserSession();

  if (email != null) {
    Map<String, dynamic>? userInfo = (await dbHelper.queryUserByEmail(email))?.cast<String, dynamic>();
    if (userInfo != null) {
      runApp(MyApp(
        isLoggedIn: true,
        userFullName: userInfo['name'],
        isAdmin: userInfo['isAdmin'] == 1,
      ));
    } else {
      runApp(MyApp(isLoggedIn: false));
    }
  } else {
    runApp(MyApp(isLoggedIn: false));
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userFullName;
  final bool? isAdmin;

  const MyApp({super.key, required this.isLoggedIn, this.userFullName, this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn
          ? HomeScreen(
        userFullName: userFullName ?? '',
        isAdmin: isAdmin ?? false,
      )
          : LoginScreen(),
    );
  }
}
