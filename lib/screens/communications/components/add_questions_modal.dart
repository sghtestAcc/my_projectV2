import 'package:flutter/material.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/communications/communications_patient.dart';


    var formDataquestions = GlobalKey<FormState>();
    final questionsText = TextEditingController();

  void addQuestionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return FutureBuilder<GraceUser?>(
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
                              // Handle the close button action here
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const Text(
                        'Add Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please enter a question';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formDataquestions.currentState!.validate()) {
                            if (questionsText.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a question'),
                                ),
                              );
                            } else {
                              UserRepository.instance.createPatientUserQuestions(
                                patientsInfo?.email ?? '',
                                questionsText.text.trim(),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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

  void addQuestionsModal2(BuildContext context) {
   showModalBottomSheet(
  context: context,
  builder: (context) {
    return FutureBuilder<GraceUser?>(
      future: controller.getPatientData(),
      builder: (context, snapshot) {
        var patientsInfo = snapshot.data;
        //  GraceUser userData = snapshot.data as GraceUser;
        return SingleChildScrollView(
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
                          // Handle the close button action here
                          //   Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          // NavigatorBar()));
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Text(
                    'Add Questions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          
                        }
                          return null;
                        },
                      maxLines: 6,
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
                  ElevatedButton(
                    onPressed: () {
                      if (formDataquestions.currentState!.validate()) {
                        UserRepository.instance.createCaregiverUserQuestions(
                          patientsInfo?.email ?? '',
                          questionsText.text.trim(),
                        );
                        formDataquestions.currentState?.reset();
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  },
);
}