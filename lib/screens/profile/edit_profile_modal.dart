 
 
 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';

 var formEditDetails = GlobalKey<FormState>();

 TextEditingController newFullNameText = TextEditingController();
  final authRepo = Get.put(AuthenticationRepository());
  String? email = FirebaseAuth.instance.currentUser!.email;
 
 void EditUserDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Form(
            key: formEditDetails,
            child: Container(
              height: MediaQuery.of(context).size.height/ 1.2,
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                        newFullNameText.clear();
                        Navigator.pop(context);
                        },
                        icon: Image.asset('assets/images/x-mark.png', height: 28, width: 28, fit: BoxFit.contain,),
                      ),
                    ],
                  ),
                  const Text(
                    'Change Full Name',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                      const SizedBox(
                        height: 10,
                      ),
                  const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'New Full Name',
                          style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                        Container(
                        decoration: BoxDecoration(
                          // Background color
                          borderRadius:
                          BorderRadius.circular(10.0), // Rounded border
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: TextFormField(
                          controller: newFullNameText,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ),
                      onPressed: () async {
                          if (newFullNameText.text == null || newFullNameText.text.isEmpty) {
                          Get.snackbar(
                          "Error",
                          "Please fill up Full Name.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                          colorText: Color(0xFFF6F3E7),
                          );
                          return;
                          } else if (!RegExp(r"^[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+$")
                            .hasMatch(newFullNameText.text.trim())) {
                           Get.snackbar(
                          "Error",
                          "All characters should have capital letters with capital letters.",
                          // "Full name should start with capital letters.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                          colorText: Color(0xFFF6F3E7),
                          );
                          return;
                          }
                          else {
                              await userRepo.editPatientDetails(newFullNameText.text.trim(), context);
                              newFullNameText.clear();
                          }
                        //    else if (!RegExp(r"^[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+$")
                        //     .hasMatch(value.trim())) {
                        //   scaffoldMessengerKey.currentState?.showSnackBar(
                        //     const SnackBar(
                        //         content: Text(
                        //             'Full name should start with capital letters.')),
                        //   );
                        //   return 'Full name should start with capital letters.';
                        // }
                        //   if (oldpasswordText.text == null || oldpasswordText.text.isEmpty) {
                        //   Get.snackbar(
                        //   "Error",
                        //   "Please fill up old password.",
                        //   snackPosition: SnackPosition.TOP,
                        //   backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                        //   colorText: Color(0xFFF6F3E7),
                        //   );
                        //   return;
                        //   } else if (newpasswordText.text == null || newpasswordText.text.isEmpty) {
                        //    Get.snackbar(
                        //   "Error",
                        //   "Please fill up mew password.",
                        //   snackPosition: SnackPosition.TOP,
                        //   backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                        //   colorText: Color(0xFFF6F3E7),
                        //   );
                        // return;
                        //   } else {
                        //   await authRepo.changepassword(email, oldpasswordText.text.trim(), newpasswordText.text.trim(),context);
                        //   oldpasswordText.clear();
                        //   newpasswordText.clear();
                        //   }
                      },
                      child: const Text(
                        'Change Full Name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ),
                      onPressed: () {
                         Navigator.pop(context);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }