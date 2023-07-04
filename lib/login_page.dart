import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';
import 'package:my_project/models/login_controller.dart';
import 'package:my_project/patient_home.dart';
import 'package:my_project/register_page.dart';
// import 'package:my_project/patient_home.dart';

import 'camera_home_patient.dart';

void main() {
  // Add this line here
  runApp(
    MaterialApp(
      title: "App",
      home: LoginScreen(
        loginType: LoginType.patientsLogin,
      ),
    ),
  );
}

enum LoginType { patientsLogin, caregiversLogin }

class LoginScreen extends StatefulWidget {
  final LoginType loginType;
  const LoginScreen({Key? key, required this.loginType}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // String? email;
  // String? password;

  var formData = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formData,
        child: Column(
          children: [
            Container(
                child: Column(
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
                SizedBox(
                  height: 10,
                ),
                Text(
                    widget.loginType == LoginType.patientsLogin
                        ? 'Patient Login'
                        : 'Caregiver Login',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            )),
            Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.loginType == LoginType.patientsLogin
                      ? TextFormField(
                          controller: controller.email,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(content: Text('Email is required.')),
                              );
                              return 'Email is required.';
                            } else if (!value.contains('@')) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
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
                        )
                      : TextFormField(
                          controller: controller.email,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(content: Text('Email is required.')),
                              );
                              return 'Email is required.';
                            } else if (!value.contains('@')) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
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
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.loginType == LoginType.patientsLogin
                      ? TextFormField(
                          controller: controller.password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text('Password is required.')),
                              );
                              return 'Password is required.';
                            } else if (value.length < 6) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
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
                          )),
                        )
                      : TextFormField(
                          controller: controller.password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text('Password is required.')),
                              );
                              return 'Password is required.';
                            } else if (value.length < 6) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
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
                          )),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.loginType == LoginType.patientsLogin
                      ? Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formData.currentState!.validate()) {
                                AuthenticationRepository.instance.loginPUser(
                                    controller.email.text.trim(),
                                    controller.password.text.trim());
                              }
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF0CE25C), // NEW
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corner radius
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formData.currentState!.validate()) {
                                AuthenticationRepository.instance.loginCUser(
                                    controller.email.text.trim(),
                                    controller.password.text.trim());
                              }
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF0CE25C), // NEW
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corner radius
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),

                  widget.loginType == LoginType.patientsLogin
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                    registerType: LoginType2.patientsRegister),
                              ),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Sign up',
                            style: TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                    registerType:
                                        LoginType2.caregiversRegister),
                              ),
                            );
                          },
                          child: Text(
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
                  //       // Text(widget.loginType == LoginType.patientsLogin
                  //       // ? 'Patient Login'
                  //       // : 'Caregiver Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))

                  //          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(registerType: LoginType2.caregiversRegister)));
                  //     },
                  //     child: Text('Dont have an account? Sign up', style: TextStyle(
                  //   fontSize: 20,
                  //   decoration: TextDecoration.underline),),
                  //  ),
                ])),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/images/sghDesign.png'),
            )),
          ],
        ),
      ),
    );
  }
}
