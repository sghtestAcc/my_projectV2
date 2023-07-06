import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/patient_user.dart';

import 'caregiver_user.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final patientDB = FirebaseFirestore.instance;

  Future<bool> isCaregiversEmailExists(String email) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('caregivers_users');
    final QuerySnapshot snapshot =
        await usersCollection.where('Email', isEqualTo: email).get();
    return snapshot
        .docs.isNotEmpty; // If the snapshot has documents, email exists
  }

  Future<bool> isCaregiversEmailAndPasswordExists(
      String email, String password) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('caregivers_users');
    final QuerySnapshot snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .where('Password', isEqualTo: password)
        .get();

    return snapshot.docs
        .isNotEmpty; // If the snapshot has documents, email and password exist
  }

  Future<void> createCaregiverUser(CaregiverModel user) async {
    final String email = user.Email!;

    final bool emailExists = await isCaregiversEmailExists(email);
    if (emailExists) {
      Get.snackbar(
        "Error",
        "Email already exists.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }
    try {
      patientDB
          .collection("caregivers_users")
          .add(user.toJson())
          .whenComplete(() {
        Get.snackbar(
          "Congrats",
          "A new account has been created.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      });
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new account.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
    }
  }

  Future<bool> isEmailExists(String email) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('patient_users');
    final QuerySnapshot snapshot =
        await usersCollection.where('Email', isEqualTo: email).get();

    return snapshot
        .docs.isNotEmpty; // If the snapshot has documents, email exists
  }

  Future<bool> isPatientEmailAndPasswordExists(
      String email, String password) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('patient_users');
    final QuerySnapshot snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .where('Password', isEqualTo: password)
        .get();

    return snapshot.docs
        .isNotEmpty; // If the snapshot has documents, email and password exist
  }

  Future<void> createPatientUser(PatientModel user) async {
    final String email = user.Email!;

    final bool emailExists = await isEmailExists(email);
    if (emailExists) {
      Get.snackbar(
        "Error",
        "Email already exists.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }
    try {
      patientDB.collection("patient_users").add(user.toJson()).whenComplete(() {
        Get.snackbar(
          "Congrats",
          "A new account has been created.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      });
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new account.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
    }
  }

  Future<PatientModel> getPatientDetails(String Email) async {
    final snapshot = await patientDB
        .collection("patient_users")
        .where("Email", isEqualTo: Email)
        .get();
    final patientData =
        snapshot.docs.map((e) => PatientModel.fromSnapshot(e)).single;
    return patientData;
  }

  Future<List<PatientModel>> getAllPatients() async {
    final snapshot = await patientDB.collection("patient_users").get();
    final patientData =
        snapshot.docs.map((e) => PatientModel.fromSnapshot(e)).toList();
    return patientData;
  }

  Future<CaregiverModel> getCaregiverDetails(String Email) async {
    final snapshot = await patientDB
        .collection("caregivers_users")
        .where("Email", isEqualTo: Email)
        .get();
    final caregiverData =
        snapshot.docs.map((e) => CaregiverModel.fromSnapshot(e)).single;
    return caregiverData;
  }
}
