import 'package:coffee_explorer_lite/authentication/view/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/session_manager.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../home/view/home_screen.dart';

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
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    loginBloc.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
        appBar: AppBar(
          title: Text('Login'),
          // title: Image.asset('images/coffee-shop.jpg', width: 150),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(30),
                    //   child: Image.asset(
                    //     'images/coffee-shop.jpg',
                    //     width: MediaQuery.of(context).size.width * 0.6,
                    //     fit: BoxFit.fitWidth,
                    //   ),
                    // ),
                    // const SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please input email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.toLowerCase())) {
                            return 'Email invalid';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
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
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginBloc.event.add(LoginButtonPressed(
                            emailController.text.toLowerCase(),
                            passwordController.text,
                          ));
                        }
                      },
                      child: const Text('Login'),
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
                      child: const Text('Register'),
                    ),
                    StreamBuilder<LoginState>(
                      stream: loginBloc.state,
                      builder: (context, snapshot) {
                        if (snapshot.data is LoginLoading) {
                          return const CircularProgressIndicator();
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
    );
  }
}
