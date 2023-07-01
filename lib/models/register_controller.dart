import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/user_repo.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  final email = TextEditingController();
  final fullName = TextEditingController();
  final password = TextEditingController();

  final userRepo = Get.put(UserRepository());
  void registerUser(String email, String fullName, String password) {

  }

  Future<void> createUser(PatientModel user) async {
    await userRepo.createPatientUser(user);
  }


}