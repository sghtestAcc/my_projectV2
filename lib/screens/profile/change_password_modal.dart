 
 
 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

 var formChangepassword = GlobalKey<FormState>();

 TextEditingController oldpasswordText = TextEditingController();
  TextEditingController newpasswordText =  TextEditingController();
  final authRepo = Get.put(AuthenticationRepository());
  String? email = FirebaseAuth.instance.currentUser!.email;
 
 void ChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: SingleChildScrollView(
            child: Form(
              key: formChangepassword,
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
                          oldpasswordText.clear();
                          newpasswordText.clear();
                          Navigator.pop(context);
                          },
                          icon: Image.asset('assets/images/x-mark.png', height: 28, width: 28, fit: BoxFit.contain,),
                        ),
                      ],
                    ),
                    Text(
                      AppLocalizations.of(context)!.changePassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.oldPassword,
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
                            controller: oldpasswordText,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                    Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.newPassword,
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
                            obscureText: true,
                            controller: newpasswordText,
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
                          //front end validation if oldpassword textfield is empty 
                          //-applies to both Patients and Caregivers-
                            if (oldpasswordText.text == null || oldpasswordText.text.isEmpty) {
                            Get.snackbar(
                            AppLocalizations.of(context)!.snackbarInvalid,
                            AppLocalizations.of(context)!.errNoOldPW,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7),
                            );
                            return;
                            } 
                            //front end validation if newpassword textfield is empty 
                          //-applies to both Patients and Caregivers-
                            else if (newpasswordText.text == null || newpasswordText.text.isEmpty) {
                             Get.snackbar(
                            AppLocalizations.of(context)!.snackbarInvalid,
                            AppLocalizations.of(context)!.errNoNewPW,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                            colorText: Color(0xFFF6F3E7),
                            );
                          return;
                            } else {
                            await authRepo.changepassword(email, oldpasswordText.text.trim(), newpasswordText.text.trim(),context);
                            oldpasswordText.clear();
                            newpasswordText.clear();
                            }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.changePassword,
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
                        child: Text(
                          AppLocalizations.of(context)!.close,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }