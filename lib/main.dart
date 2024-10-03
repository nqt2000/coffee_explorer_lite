import 'package:flutter/material.dart';
import 'authentication/view/login_screen.dart';
import 'home/view/home_screen.dart';
import 'utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SessionManager sessionManager = SessionManager();
  String? email = await sessionManager.getUserSession();

  runApp(MyApp(isLoggedIn: email != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? HomeScreen(userEmail: '',) : LoginScreen(),
    );
  }
}
