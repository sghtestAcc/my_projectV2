import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/grace_user.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final firestore = FirebaseFirestore.instance;

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
//  Future<bool> isEmailExists2(String email) async {
//     final CollectionReference usersCollection =
//         patientDB.collection('patient_users');
//     final QuerySnapshot snapshot =
//         await usersCollection.where('Email', isEqualTo: email).get();

//     return snapshot.docs.isNotEmpty; // If the snapshot has documents, email exists
//   }

//   Future<void> addUserEmailToCollection(String email) async {
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   String? currentEmail = currentUser?.email;

//   CollectionReference patientUsersCollection =
//       patientDB.collection('patient_users');
//   CollectionReference questionsUsersCollection =
//       patientDB.collection('questions_users');

//   if (email == currentEmail) {
//     await patientUsersCollection.add({'email': email});
//   } else {
//     await questionsUsersCollection.add({'email': email});
//   }
// }

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

//create patients questions function
  Future<void> createPatientUserQuestions(
    String email,
    String question,
  ) async {
    final doesUserExists = await isEmailExists(email, LoginType.patient);
    if (!doesUserExists) return;
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

  Future<GraceUser> getUser(String email) async {
    final snapshot = await firestore
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser.fromSnapshot(e),
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
