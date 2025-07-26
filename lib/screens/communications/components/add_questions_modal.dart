import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

  final questionsText = TextEditingController();
  final questionsText2 = TextEditingController();

  var formDataquestions = GlobalKey<FormState>();
  final currentEmail = FirebaseAuth.instance.currentUser!.email;
  final currentEmail2 = FirebaseAuth.instance.currentUser!.email;



  void addQuestionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
              return SingleChildScrollView(
                child: Container(
                   height: MediaQuery.of(context).size.height / 1.25,
                  child: Form(
                    key: formDataquestions,
                    child: Container(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  questionsText.clear();
                                  Navigator.pop(context);
                                },
                                icon: Image.asset('assets/images/x-mark.png', height: 28, width: 28, fit: BoxFit.contain,),
                              ),
                            ],
                          ),
                          Text(
                          AppLocalizations.of(context)!.addqn,
                          style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          ),),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background color
                              borderRadius: BorderRadius.circular(10.0), // Rounded border
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                            controller: questionsText,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.etryrquestionhere,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formDataquestions.currentState!.validate()) {
                                } 
                                //validation textfield of questions of questions if empty -applies to both Patients and Caregivers-
                                if(questionsText.text == null || questionsText.text.isEmpty) {
                                Get.snackbar(
                                AppLocalizations.of(context)!.snackbarInvalid,
                                AppLocalizations.of(context)!.qnEmpty,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                                colorText: Color(0xFFF6F3E7)
                                );
                                return;
                                  } 
                                  else {
                                    await UserRepository.instance.createPatientUserQuestions(
                                      context,
                                      currentEmail!,
                                      questionsText.text.trim(),
                                    );
                                    questionsText.clear();
                                  } 
                              },
                              style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ) ,
                              child: Text(
                                AppLocalizations.of(context)!.add,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),   
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                    questionsText.clear();
                                    Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ) ,
                              child: Text(
                                AppLocalizations.of(context)!.close,
                                style: const TextStyle(
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
                ),
              );
       
    },
  );
}
  void addQuestionsModal2(BuildContext context) {
   showModalBottomSheet(
    context: context,
    builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.25,
                  child: Form(
                    key: formDataquestions,
                    child: Container(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  questionsText.clear();
                                  Navigator.pop(context);
                                },
                                icon: Image.asset('assets/images/x-mark.png', height: 28, width: 28, fit: BoxFit.contain,),
                              ),
                            ],
                          ),
                          Text(
                          AppLocalizations.of(context)!.addqn,
                          style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background color
                              borderRadius: BorderRadius.circular(10.0), // Rounded border
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                            controller: questionsText2,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.etryrquestionhere,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                               
                                
                                if(questionsText2.text == null || questionsText2.text.isEmpty) {
                                Get.snackbar(
                                AppLocalizations.of(context)!.snackbarInvalid,
                                AppLocalizations.of(context)!.qnEmpty,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                                colorText: Color(0xFFF6F3E7)
                                );
                                return;
                                  } else {
                                    await UserRepository.instance.createCaregiverUserQuestions(
                                      context,
                                      currentEmail2!,
                                      questionsText2.text.trim(),
                                    );
                                    questionsText2.clear();
                                  }      
                              },
                              style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ) ,
                              child: Text(
                                AppLocalizations.of(context)!.add,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),   
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                    questionsText.clear();
                                    Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corner radius
                            ),
                          ) ,
                              child:  Text(
                                AppLocalizations.of(context)!.close,
                                style: const TextStyle(
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
                ),
              );
    },
  );
}