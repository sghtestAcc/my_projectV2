import 'package:flutter/material.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/screens/auth/register_page.dart';

import '../../models/login_type.dart';

class LoginScreen extends StatefulWidget {
  final LoginType loginType;
  const LoginScreen({Key? key, required this.loginType}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // String? email;
  // String? password;

  final email = TextEditingController();
  final password = TextEditingController();

  var formData = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formData,
        child: Column(
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/Grace-bg-new-edited.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/sgh.png',
                  height: 100,
                  width: 180,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.loginType == LoginType.patient
                      ? 'Patient Login'
                      : 'Caregiver Login',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: email,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text('Email is required.')),
                        );
                        return 'Email is required.';
                      } else if (!value.contains('@')) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text('Invalid email format.')),
                        );
                        return 'Invalid email format.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text('Password is required.')),
                        );
                        return 'Password is required.';
                      } else if (value.length < 6) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Password must be at least 6 characters long.')),
                        );
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formData.currentState!.validate()) {
                          AuthenticationRepository.instance.loginUser(
                            email.text.trim(),
                            password.text.trim(),
                            widget.loginType,
                          );
                          formData.currentState?.reset();
                        }
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corner radius
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            registerType: widget.loginType,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  //  GestureDetector(
                  //     onTap: () {
                  //       // Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
                  //       // Text(widget.loginType == LoginType.patient
                  //       // ? 'Patient Login'
                  //       // : 'Caregiver Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))

                  //          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(registerType: LoginType2.caregiversRegister)));
                  //     },
                  //     child: Text('Dont have an account? Sign up', style: TextStyle(
                  //   fontSize: 20,
                  //   decoration: TextDecoration.underline),),
                  //  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset('assets/images/sghDesign.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
