import 'package:flutter/material.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';

import '../../repos/authentication_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<LoginType> selectedLoginTypes = [];

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
      body: SingleChildScrollView(
        child: Form(
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
                    const Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                      child:
                          Text('Account Type', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: LoginType.values
                          .where((type) =>
                              type !=
                              LoginType.dualAccount) // 👈 Exclude dualAccount
                          .map((type) {
                        return CheckboxListTile(
                          title: Text(type.name[0].toUpperCase() +
                              type.name.substring(1)),
                          value: selectedLoginTypes.contains(type),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedLoginTypes.add(type);
                              } else {
                                selectedLoginTypes.remove(type);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
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
                        }
                        //changed to every first letter in the word to be full caps in the users Fullname
                        //-applies to Both Patients and Caregivers-
                        else if (!RegExp(
                                r"^[A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z]+)*$")
                            .hasMatch(value.trim())) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Full name should start with capital letters.'),
                            ),
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
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      selectedLoginTypes.contains(LoginType.caregiver)
                          ? 'assets/images/sgh-design-caregiver.png'
                          : 'assets/images/sghDesign.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedLoginTypes.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please select at least one account type.'),
                            ),
                          );
                          return;
                        }

                        if (formData.currentState!.validate()) {
// Determine the proper login type
                          LoginType loginType;
                          if (selectedLoginTypes.contains(LoginType.patient) &&
                              selectedLoginTypes
                                  .contains(LoginType.caregiver)) {
                            loginType = LoginType.dualAccount;
                          } else {
                            loginType = selectedLoginTypes.first;
                          }

// Register user
                          final user = GraceUser(
                            email: email.text.trim(),
                            name: fullName.text.trim(),
                            loginType: loginType,
                          );

                          await AuthenticationRepository.instance.registerUser(
                            email.text.trim(),
                            password.text.trim(),
                            loginType,
                            user,
                          );
                        }

                        email.clear();
                        password.clear();
                        fullName.clear();
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
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? Login',
                          style: TextStyle(
                              fontSize: 15,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
