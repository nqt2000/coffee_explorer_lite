import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../authentication/view/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final SessionManager sessionManager = SessionManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
