import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_project/models/caregiver_user.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/register_controller.dart';
import 'package:my_project/models/user_repo.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: RegisterScreen(registerType: LoginType2.patientsRegister),
    ));

enum LoginType2 { patientsRegister, caregiversRegister }

class RegisterScreen extends StatefulWidget {
  final LoginType2 registerType;
  const RegisterScreen({Key? key, required this.registerType})
      : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final controller = Get.put(RegisterController());
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
              child: Center(
                  child: Column(
                children: [
                  Image.asset(
                    'assets/images/Grace-bg-new-edited.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  Image.asset('assets/images/sgh.png'),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      widget.registerType == LoginType2.patientsRegister
                          ? 'Patient Register'
                          : 'Caregiver Register',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  // Text('Caregiver Register', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              )),
            ),
            Container(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.registerType == LoginType2.patientsRegister
                      ? TextFormField(
                          controller: controller.email,
                          obscureText: false,
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
                          )),
                        )
                      : TextFormField(
                          controller: controller.email,
                          obscureText: false,
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
                          )),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Full name', style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.registerType == LoginType2.patientsRegister
                      ? TextFormField(
                          controller: controller.fullName,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text('Full name is required.')),
                              );
                              return 'Full name is required.';
                            } else if (value.trim().split(' ').length < 2) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Full name should contain at least two words.')),
                              );
                              return 'Full name should contain at least two words.';
                            } else if (!RegExp(
                                    r"^[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+$")
                                .hasMatch(value.trim())) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Full name should start with capital letters.')),
                              );
                              return 'Full name should start with capital letters.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          )),
                        )
                      : TextFormField(
                          controller: controller.fullName,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text('Full name is required.')),
                              );
                              return 'Full name is required.';
                            } else if (value.trim().split(' ').length < 2) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Full name should contain at least two words.')),
                              );
                              return 'Full name should contain at least two words.';
                            } else if (!RegExp(
                                    r"^[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+$")
                                .hasMatch(value.trim())) {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Full name should start with capital letters.')),
                              );
                              return 'Full name should start with capital letters.';
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: TextStyle(fontSize: 20)),
                  ),
                  widget.registerType == LoginType2.patientsRegister
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
                        )
                ])),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/sghDesign.png',
                    ),
                  ),
                  widget.registerType == LoginType2.patientsRegister
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: ElevatedButton(
                            onPressed: () {
                              if (formData.currentState!.validate()) {
                                final user = PatientModel(
                                    Email: controller.email.text.trim(),
                                    Name: controller.fullName.text.trim(),
                                    Password: controller.password.text.trim());
                                UserRepository.instance.createPatientUser(user);
                                RegisterController.instance.registerP();
                              }
                            },
                            child: Text(
                              'Register',
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
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: ElevatedButton(
                            onPressed: () {
                              if (formData.currentState!.validate()) {
                                final user2 = CaregiverModel(
                                    Email: controller.email.text.trim(),
                                    Name: controller.fullName.text.trim(),
                                    Password: controller.password.text.trim());
                                UserRepository.instance
                                    .createCaregiverUser(user2);
                                RegisterController.instance.registerC();
                              }
                            },
                            child: Text(
                              'Register',
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
                  const Positioned.fill(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? Login',
                            style: TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.underline),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
