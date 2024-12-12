import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final RegisterBloc registerBloc = RegisterBloc();
  DateTime timeBackPressed = DateTime.now();
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    registerBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _rePasswordVisible = false;
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
      child: Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please input your name';
                          } else if (!RegExp(
                                  "[a-zA-Z_ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễếệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]")
                              .hasMatch(value)) {
                            return 'Invalid name';
                          } else if (value.length < 3) {
                            return 'Name should be at least 3 characters!';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please input email';
                          } else if (!RegExp('[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.toLowerCase())) {
                            return 'Email invalid';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              size: 20,
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please input password';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least one uppercase character';
                          }
                          if(value.length < 8){
                            return 'Password must contain at least 8 character';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: rePasswordController,
                        decoration: InputDecoration(
                          labelText: 'Re-password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              size: 20,
                              _rePasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _rePasswordVisible = !_rePasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_rePasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please input re-password';
                          }
                          if (value != passwordController.text) {
                            return 'Re-password does not match';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerBloc.event.add(RegisterButtonPressed(
                            nameController.text,
                            emailController.text.toLowerCase(),
                            passwordController.text,
                            rePasswordController.text,
                          ));
                        }
                      },
                      child: Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Back Login'),
                    ),
                    StreamBuilder<RegisterState>(
                      stream: registerBloc.state,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.data is RegisterLoading) {
                          return CircularProgressIndicator();
                        } else if (snapshot.data is RegisterSuccess) {
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
      ),
    );
  }
}
