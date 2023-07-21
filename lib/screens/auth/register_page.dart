import 'package:flutter/material.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';

import '../../repos/authentication_repository.dart';

class RegisterScreen extends StatefulWidget {
  final LoginType registerType;
  const RegisterScreen({Key? key, required this.registerType})
      : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  var formData = GlobalKey<FormState>();

  final email = TextEditingController();
  final fullName = TextEditingController();
  final password = TextEditingController();

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
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/final-grace-background.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  Image.asset('assets/images/sgh.png'),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      widget.registerType == LoginType.patient
                          ? 'Patient Register'
                          : 'Caregiver Register',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                  // Text('Caregiver Register', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
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
                    child: Text('Full name', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: fullName,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text('Full name is required.')),
                        );
                        return 'Full name is required.';
                      } else if (value.trim().split(' ').length < 2) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Full name should contain at least two words.')),
                        );
                        return 'Full name should contain at least two words.';
                      } else if (!RegExp(r"^[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+$")
                          .hasMatch(value.trim())) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
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
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  widget.registerType == LoginType.patient
                ?
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/sghDesign.png',
                    ),
                  ): Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/sgh-design-caregiver.png',
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formData.currentState!.validate()) {
                          final user = GraceUser(
                            email: email.text.trim(),
                            name: fullName.text.trim(),
                            loginType: widget.registerType,
                          );
                          // if (await UserRepository.instance.createUser(user)) {
                            await AuthenticationRepository.instance
                                .registerUser(
                              email.text.trim(),
                              password.text.trim(),
                              widget.registerType,
                              user
                            );
                          // }
                          formData.currentState?.reset();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Rounded corner radius
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                      ],
                    ),
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
