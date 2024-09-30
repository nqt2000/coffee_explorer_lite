import 'package:flutter/material.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RegisterBloc registerBloc = RegisterBloc();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    registerBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // Ensure that the Form key is used
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250, // Đặt độ rộng cố định cho ô nhập liệu
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please input your name';
                        }
                        if (!RegExp(r"^[a-zA-Z ,.'-]+$").hasMatch(value)) {
                          return 'Invalid name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20), // Thêm khoảng cách giữa các ô nhập
                  SizedBox(
                    width: 250, // Đặt độ rộng cố định cho ô nhập liệu
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please input email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 250, // Đặt độ rộng cố định cho ô nhập liệu
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please input password';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Password must contain at least one uppercase character';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Trigger register event when form is valid
                        registerBloc.event.add(RegisterButtonPressed(
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        ));
                      }
                    },
                    child: Text('Register'),
                  ),
                  StreamBuilder<RegisterState>(
                    stream: registerBloc.state,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Loading state
                      } else if (snapshot.data is RegisterLoading) {
                        return CircularProgressIndicator(); // Show loading indicator
                      } else if (snapshot.data is RegisterSuccess) {
                        // Navigate to LoginScreen after successful registration
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        });
                      } else if (snapshot.data is RegisterFailure) {
                        // Show error message
                        return Text((snapshot.data as RegisterFailure).error);
                      }
                      return Container(); // Default fallback
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
