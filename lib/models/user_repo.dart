import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/patient_user.dart';


class UserRepository extends GetxController {

  static UserRepository get instance => Get.find();

  final patientDB = FirebaseFirestore.instance;

  createPatientUser(PatientModel user) async {
    await patientDB.collection("patient_users").add(user.toJson()).whenComplete(() => 
      Get.snackbar("Congrats", "A new Account has been created.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green),
    )
    .catchError((error, StackTrace){
      Get.snackbar("Congrats", "A new Account has been created.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red);
      print(error.toString());
    });

  }
}