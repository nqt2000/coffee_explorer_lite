import 'package:coffee_explorer_lite/authentication/view/register_screen.dart';
import 'package:coffee_explorer_lite/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../home/view/home_screen.dart';
import '../../utils/session_manager.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginBloc loginBloc = LoginBloc();
  DateTime timeBackPressed = DateTime.now();
  bool _passwordVisible = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    loginBloc.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
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
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.blue,
            inputDecorationTheme: InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ))),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'COFFEE EXPLORER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Times New Roman",
              ),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/coffee-shop.jpg',
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.height * 1,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Divider(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'example@mail.com',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,5}$';
                            if (value == null || value.trim().isEmpty) {
                              return 'Please input email';
                            }
                            if (!RegExp(pattern)
                                .hasMatch(value.trim().toLowerCase())) {
                              return 'Email invalid';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                            if (value.length < 8) {
                              return 'Password must contain at least 8 character';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      PrimaryButton(
                        title: Text(
                          'LOGIN',
                          style: _isButtonEnabled
                              ? TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45),
                        ),
                        onPressed: _isButtonEnabled
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  loginBloc.event.add(LoginButtonPressed(
                                    emailController.text.toLowerCase(),
                                    passwordController.text,
                                  ));
                                }
                              }
                            : null,
                      ),

                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          "Don't have account?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                        ),
                      ]),
                      StreamBuilder<LoginState>(
                        stream: loginBloc.state,
                        builder: (context, snapshot) {
                          if (snapshot.data is LoginLoading) {
                            return CircularProgressIndicator();
                          } else if (snapshot.data is LoginSuccess) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              final sessionManager = SessionManager();
                              String? email =
                                  (snapshot.data as LoginSuccess).email;

                              await sessionManager.saveUserSession(email);

                              Map<String, dynamic>? userInfo =
                                  await sessionManager.getUserInfo();

                              if (userInfo != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      userFullName: userInfo['name'] ?? '',
                                      isAdmin: userInfo['isAdmin'] == 1,
                                    ),
                                  ),
                                );
                              }
                            });
                          } else if (snapshot.data is LoginFailure) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text((snapshot.data as LoginFailure).error),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
