import 'package:flutter/material.dart';

import '../../repos/authentication_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
   var formData = GlobalKey<FormState>();
  final emailformfield = TextEditingController();

   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'forget password',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        // iconTheme: const IconThemeData(color: const Color(0xFF0CE25C)),
        backgroundColor:  const Color(0xFF0CE25C) ,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
  body: Container(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
    child: Form(
      key: formData,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the column children vertically
        children: [
          Image.asset('assets/images/forgot-password.png', ),
          SizedBox(height: 20,),
        Text('Forget Password?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
      SizedBox(height: 20,),
      Text('Enter your email', style: TextStyle(fontSize: 20),),
       Text('A password reset link will be sent to you', style: TextStyle(fontSize: 20),),
          SizedBox(height: 20,),
          TextFormField(
            controller: emailformfield,
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
             validator: (value) {
                if (value == null || value.isEmpty) {
                scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                content: Text('please enter your email for password reset.')),
                );
                return 'please enter your email for password reset.';
                }
                return null;
                      },
            // ... Your other TextFormField properties and validation
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      // height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formData.currentState!.validate()) {
                            AuthenticationRepository.instance.forgetpassword(
                              emailformfield.text.trim(),
                            );
                            formData.currentState?.reset();
                          }
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    ),
  ),
);
  }
}