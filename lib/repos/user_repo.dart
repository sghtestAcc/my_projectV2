import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/medications.dart';

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

  Future<bool> createUser(GraceUser user, String uid) async {
    final String email = user.email!;
    final bool emailExists = await isEmailExists(email, user.loginType);
    if (emailExists) {
      Get.snackbar(
        "Error",
        "Email already exists.",
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.redAccent.withOpacity(0.1),
        // colorText: Colors.red,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      return true;
    }
    try {
      await firestore.collection("users").doc(uid).set(user.toJson());
      Get.snackbar(
        "Congrats",
        "A new account has been created.",
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.green.withOpacity(0.1),
        // colorText: Colors.green,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
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
  Future<List<String>> getQuestionsofPatient(String? email) async {
    // final doesUserExists = await isEmailExists(email, LoginType.patient);
    // if (!doesUserExists) throw Exception('User does not exists');
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
    // final doesUserExists = await isEmailExists(email, LoginType.caregiver);
    // if (!doesUserExists) throw Exception('User does not exists');
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

Future<bool> isPatientQuestionsEmailExists(String email, String question) async {
  final CollectionReference usersCollection = firestore.collection('questions');
  String lowerCaseQuestion = question.toLowerCase();

  print("Searching for: $lowerCaseQuestion");

  var snapshot = await usersCollection
      .where("Email", isEqualTo: email)
      .where("LowerCaseQuestion", isEqualTo: lowerCaseQuestion)
      .get();

  print("Snapshot documents: ${snapshot.docs}");

  var isEmailExists = snapshot.docs.isNotEmpty;
  return isEmailExists;
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







Future<bool> isPatientMedicationsExists(String uid) async {
    final CollectionReference usersCollection = firestore.collection('users')
    .doc(uid)
    .collection('medications');
    var snapshot = await usersCollection
    .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
}


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


// // Create patient medications
Future<void> createPatientMedications(
  String? labels,
  XFile? pills,
  String quantity,
  String schedule,
) async {
  // final doesUserExist = await isEmailExists(email, LoginType.patient);
  // if (!doesUserExist) {
  //   throw Exception('User does not exist');
  // }

  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final pathRoute = 'medicationPills/$fileName';
    String imageUrl = await uploadImageToStorage(pathRoute, pills!);
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid)
    .collection('medications')
    .add({
      // "Email": email,
      // "Name" : name,
      "Labels":labels,
      "Pills":imageUrl,
      "Quantity":quantity,
      "Schedule": schedule
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

Future<List<GraceUser>> getAllPatientsWithMedications() async {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
      await FirebaseFirestore.instance.collection("users")
      .where("LoginType", isEqualTo: LoginType.patient.name)
      .get();

  List<GraceUser> patientsWithMedications = [];

  for (var userDoc in usersSnapshot.docs) {
    String uid = userDoc.id;
    bool hasMedications = await isPatientMedicationsExists(uid);

    if (hasMedications && uid != currentUserUid) {
      var patientData = GraceUser.fromSnapshot(userDoc);
      patientsWithMedications.add(patientData);
    }
  }
  return patientsWithMedications;
}

Future<List<GraceUser>> getPatientsWithMedications() async {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  
  // Step 1: Fetch the current user's subcollection and retrieve patient emails
  final QuerySnapshot<Map<String, dynamic>> currentUserMedicationsSnapshot =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserUid)
          .collection('medications')
          .get();
  
  List<String> currentUserPatientEmails = currentUserMedicationsSnapshot.docs
      .map((doc) => doc['Email'] as String) // Replace 'patientEmail' with the field containing the patient's email in the medications subcollection
      .toList();

  // Step 2: Query the "users" collection for patients with matching emails
  final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
      await FirebaseFirestore.instance.collection("users")
      .where("LoginType", isEqualTo: LoginType.patient.name)
      .where("Email", whereIn: currentUserPatientEmails)
      .get();

  List<GraceUser> patientsWithMedications = [];

  for (var userDoc in usersSnapshot.docs) {
    String uid = userDoc.id;
    bool hasMedications = await isPatientMedicationsExists(uid);

    if (hasMedications && uid != currentUserUid) {
      var patientData = GraceUser.fromSnapshot(userDoc);
      patientsWithMedications.add(patientData);
    }
  }
  return patientsWithMedications;
}


Future<List<Medication>> displayAllPatientsMedications(String? uid) async {
  var patientDataMedications = await firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get();
      final patientData = patientDataMedications.docs
        .map(
          (e) => Medication.fromSnapshot(e),
        )
        .toList();
    return patientData;
}

//get single patinet Medications
Future<List<Medication>> getPatientMedications(String? uid) async {
    var patientDataMedications = await firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get();
      final patientData = patientDataMedications.docs
        .map(
          (e) => Medication.fromSnapshot(e),
        )
        .toList();
    return patientData;
}

Future<bool> isEmailExists2(String email) async {
    final CollectionReference usersCollection = firestore.collection('medications');
    var snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
  }

Future<List<Medication>> getAllPatientsMedications(String uid) async {
  // final doesUserExists = await isEmailExists(email, LoginType.patient);
  // if (!doesUserExists) throw Exception('User does not exists');
  var patientDataMedications = await firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get();
      final patientData = patientDataMedications.docs
        .map(
          (e) => Medication.fromSnapshot(e),
        )
        .toList();
    return patientData;
}


// //original patient medication -- do not delete---
//   Future<List<Medication>> getAllPatientsMedications(String email) async {
//   final doesUserExists = await isEmailExists(email, LoginType.patient);
//   // final doesUserExists = await isEmailExists2(email);
//   if (!doesUserExists) throw Exception('User does not exists');
//   final snapshot = await firestore
//       .collection("medications")
//       .where("Email", isEqualTo: email)
//       .get();
//   final patientDataMedications = snapshot.docs
//       .map(
//         (e) => Medication.fromSnapshot(e),
//       )
//       .toList();
//   return patientDataMedications;
// }


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

  getSingleUserQuestionPatient(String s) {}
}