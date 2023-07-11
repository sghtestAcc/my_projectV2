import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/grace_user.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final firestore = FirebaseFirestore.instance;
  final firebasestorage = FirebaseStorage.instance;

  Future<bool> isEmailExists(String email, LoginType loginType) async {
    final CollectionReference usersCollection = firestore.collection('users');
    var snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .where("LoginType", isEqualTo: loginType.name)
        .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
  }

  Future<bool> createUser(GraceUser user) async {
    final String email = user.email!;
    final bool emailExists = await isEmailExists(email, user.loginType);
    if (emailExists) {
      Get.snackbar(
        "Error",
        "Email already exists.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
    try {
      await firestore.collection("users").add(user.toJson());
      Get.snackbar(
        "Congrats",
        "A new account has been created.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new account.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
      return false;
    }
  }



//retrieve patient questions function(of single users)
  Future<List<String>> getQuestionsofPatient(String email) async {
    final doesUserExists = await isEmailExists(email, LoginType.patient);
    if (!doesUserExists) throw Exception('User does not exists');
    final snapshot = await firestore
        .collection("questions")
        .where("Email", isEqualTo: email)
        .get();
    return snapshot.docs
        .map(
          (e) => e.data()["Question"].toString(),
        )
        .toList();
}

//retrieve caregivers questions function(of single users)
  Future<List<String>> getQuestionsofCaregiver(String email) async {
    final doesUserExists = await isEmailExists(email, LoginType.caregiver);
    if (!doesUserExists) throw Exception('User does not exists');
    final snapshot = await firestore
        .collection("questions")
        .where("Email", isEqualTo: email)
        .get();
    return snapshot.docs
        .map(
          (e) => e.data()["Question"].toString(),
        )
        .toList();
}

   Future<bool> isPatientQuestionsEmailExists(String email,String question) async {
    final CollectionReference usersCollection = firestore.collection('questions');
    var snapshot = await usersCollection
        .where("Email", isEqualTo: email)
        .where("Question", isEqualTo: question)
        .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
  }




//create patients questions function
  Future<void> createPatientUserQuestions(
  String email,
  String question,
) async {
  final doesUserExists = await isEmailExists(email, LoginType.patient);
  final doesUserQuestionExists = await isPatientQuestionsEmailExists(email, question);

  if (!doesUserExists) return;

  if (doesUserQuestionExists) {
    Get.snackbar(
      "Error",
      "This question already exists for the given email.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
    return;
  }

  try {
    await firestore.collection("questions").add({
      "Email": email,
      "Question": question,
    });
    Get.snackbar(
      "Congrats",
      "A new question has been created.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to create a new question.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
    print(error.toString());
  }
}


// Future<bool> isPatientMedicationsExists(String email,String question) async {
//     final CollectionReference usersCollection = firestore.collection('questions');
//     var snapshot = await usersCollection
//         .where("Email", isEqualTo: email)
//         .where("Question", isEqualTo: question)
//         .get();
//     var isEmailExists = snapshot.docs.isNotEmpty;
//     return isEmailExists; // If the snapshot has documents, email exists
// }

Future<String> uploadImageToStorage(String childName, XFile file) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference fileReference = storage.ref().child(childName);
  try {
    UploadTask uploadTask = fileReference.putFile(File(file.path));
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  } catch (error) {
    print(error.toString()); // You may want to handle the error appropriately
    throw Exception('Image upload failed.'); // Throw an exception instead of returning null
  }
}

  //   Future<bool> createUser(GraceUser user) async {
  //   final String email = user.email!;
  //   final bool emailExists = await isEmailExists(email, user.loginType);
  //   if (emailExists) {
  //     Get.snackbar(
  //       "Error",
  //       "Email already exists.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.redAccent.withOpacity(0.1),
  //       colorText: Colors.red,
  //     );
  //     return false;
  //   }
  //   try {
  //     await firestore.collection("users").add(user.toJson());
  //     Get.snackbar(
  //       "Congrats",
  //       "A new account has been created.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.green.withOpacity(0.1),
  //       colorText: Colors.green,
  //     );
  //     return true;
  //   } catch (error) {
  //     Get.snackbar(
  //       "Error",
  //       "Failed to create a new account.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.redAccent.withOpacity(0.1),
  //       colorText: Colors.red,
  //     );
  //     print(error.toString());
  //     return false;
  //   }
  // }

// Future<bool> isPatientMedicationsExists(String email,String question) async {
//     final CollectionReference usersCollection = firestore.collection('questions');
//     var snapshot = await usersCollection
//         .where("Email", isEqualTo: email)
//         .where("Question", isEqualTo: question)
//         .get();
//     var isEmailExists = snapshot.docs.isNotEmpty;
//     return isEmailExists; // If the snapshot has documents, email exists
// }


Future<void> createPatientMedications(
  XFile? labels,
  XFile? pills,
  String quantity,
  String schedule,
  String email,
) async {
  final doesUserExists = await isEmailExists(email, LoginType.patient);
  if (!doesUserExists) return;
  try {
  final pathRoute = 'medicationLabels/${labels}';
  final pathRoute2 = 'medicationPills/${pills}';
  String imageUrl = await uploadImageToStorage(pathRoute, labels!);
  String imageUrl2 = await uploadImageToStorage(pathRoute2, pills!);
  
    await FirebaseFirestore.instance.collection("medications").add({
      "Labels": imageUrl,
      "Pills" : imageUrl2,
      "Quantity": quantity,
      "Schedule": schedule,
      "Email": email,
    });

    Get.snackbar(
      "Congrats",
      "A new medication has been added.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to add a medication",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
    print(error.toString());
  }
}

  //create caregivers questions function
  Future<void> createCaregiverUserQuestions(
    String email,
    String question,

  ) async {
    final doesUserExists = await isEmailExists(email, LoginType.caregiver);
    final doesUserQuestionExists = await isPatientQuestionsEmailExists(email, question);
    if (!doesUserExists) return;

     if (doesUserQuestionExists) {
    Get.snackbar(
      "Error",
      "This question already exists for the given email.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
    return;
  }
  
    try {
      await firestore.collection("questions").add({
        "Email": email,
        "Question": question,
      });
      Get.snackbar(
        "Congrats",
        "A new question has been created.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new question.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
    }
  }

  // Future<PatientModel> getPatientDetailsQuestions(String Questions) async {
  //   final snapshot = await patientDB
  //       .collection("patient_users")
  //       .where("Questions", isEqualTo: Questions)
  //       .get();
  //   final patientData =
  //       snapshot.docs.map((e) => PatientModel.fromSnapshot(e)).single;
  //   return patientData;
  // }

  Future<GraceUser?> getUser(String email) async {
    final snapshot = await firestore
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser?.fromSnapshot(e),
        )
        .single;
    return patientData;
  }

  Future<List<GraceUser>> getAllPatients() async {
    final snapshot = await firestore
        .collection("users")
        .where("LoginType", isEqualTo: LoginType.patient.name)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser.fromSnapshot(e),
        )
        .toList();
    return patientData;
  }
}
