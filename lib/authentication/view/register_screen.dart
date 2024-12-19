import 'package:coffee_explorer_lite/common/primary_button.dart';
import 'package:coffee_explorer_lite/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/session_manager.dart';
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
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _rePasswordVisible = false;
    nameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    rePasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    registerBloc.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          rePasswordController.text.isNotEmpty;
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
        home: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            appBar: AppBar(title: Text('Register')),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.02),
                            child: Text(
                              'Full Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Nguyen Van A',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please input your name';
                              } else if (!RegExp(
                                      "[a-zA-Z_ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễếệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]")
                                  .hasMatch(value.trim())) {
                                return 'Invalid name';
                              } else if (value.trim().length < 3) {
                                return 'Name should be at least 3 characters!';
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
                            child: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                              const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                              if (value == null || value.trim().isEmpty) {
                                return 'Please input email';
                              } else if (!RegExp(pattern)
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
                            child: Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: 'DemoPassword',
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.02),
                            child: Text(
                              'Re-password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: rePasswordController,
                            decoration: InputDecoration(
                              hintText: 'DemoPassword',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
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
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                title: Text(
                                  'BACK',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.grey,
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02),
                            Expanded(
                              child: PrimaryButton(
                                onPressed: _isButtonEnabled
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          registerBloc.event
                                              .add(RegisterButtonPressed(
                                            nameController.text.trim(),
                                            emailController.text.toLowerCase().trim(),
                                            passwordController.text,
                                            rePasswordController.text,
                                          ));
                                        }
                                      }
                                    : null,
                                title: Text(
                                  'REGISTER',
                                  style: _isButtonEnabled
                                      ? TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)
                                      : TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
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
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                final sessionManager = SessionManager();
                                Map<String, dynamic>? userInfo =
                                    await sessionManager.getUserInfo();

                                if (userInfo != null) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen(
                                              userFullName:
                                                  userInfo['name'] ?? '',
                                              isAdmin:
                                                  userInfo['isAdmin'] == 1)));
                                }
                              });
                            } else if (snapshot.data is RegisterFailure) {
                              return Text(
                                  (snapshot.data as RegisterFailure).error);
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
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
