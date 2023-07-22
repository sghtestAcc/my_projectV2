import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/communications/communications_patient.dart';

  final questionsText = TextEditingController();
  var formDataquestions = GlobalKey<FormState>();


  void addQuestionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return FutureBuilder(
        future: controller.getPatientData(),
        builder: (context, snapshot) {
              var patientsInfo = snapshot.data;
              return Form(
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
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                      'Add Questions',
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                      ),
                      const SizedBox(
                        height: 10,
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
                        decoration: const InputDecoration(
                        hintText: 'Enter your question here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
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
                            } if(questionsText.text == null || questionsText.text.isEmpty) {
                            Get.snackbar(
                            "Error",
                            "Please fill in, Question is required.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7)
                            );
                            return;
                              } else {
                                await UserRepository.instance.createPatientUserQuestions(
                                  context,
                                  currentEmail!,
                                  questionsText.text.trim(),
                                );
                                questionsText.clear();
                                // Navigator.pop(context);
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
                          child: const Text(
                            'Add',
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
                          child: const Text(
                            'Close',
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
              );
        }
      );
    },
  );
}

 String? currentEmail = FirebaseAuth.instance.currentUser!.email;

  void addQuestionsModal2(BuildContext context) {
   showModalBottomSheet(
    context: context,
    builder: (context) {
      // return FutureBuilder<GraceUser?>(
      //   future: controller.getPatientData(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //     if (snapshot.hasData) {
      //         var patientsInfo = snapshot.data;
              return Form(
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
                      Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                      'Add Questions',
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                      ),
                      const SizedBox(
                        height: 10,
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
                        decoration: const InputDecoration(
                        hintText: 'Enter your question here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
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
                            
                            if(questionsText.text == null || questionsText.text.isEmpty) {
                            Get.snackbar(
                            "Error",
                            "Please fill in, Question is required.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7)
                            );
                            return;
                              } else {
                                await UserRepository.instance.createCaregiverUserQuestions(
                                  context,
                                  currentEmail!,
                                  questionsText.text.trim(),
                                );
                                questionsText.clear();
                              }      
// value.trim().split(' ').length < 2
                          },
                          style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corner radius
                        ),
                      ) ,
                          child: const Text(
                            'Add',
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
                          child: const Text(
                            'Close',
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
              );
      //       } else if (snapshot.hasError) {
      //                     return Center(child: Text(snapshot.error.toString()));
      //       } else {
      //                     return const Center(
      //                         child: Text('Something went wrong'));
      //       }
      //       } else {
      //                   return const Center(child: CircularProgressIndicator());
      //       }

      //   }
      // );
    },
  );
}