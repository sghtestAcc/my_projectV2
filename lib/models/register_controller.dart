import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/user_repo.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  final email = TextEditingController();
  final fullName = TextEditingController();
  final password = TextEditingController();

  final userRepo = Get.put(UserRepository());
  // void registerUser(String email, String fullName, String password) {

  //   String? error = AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password) as String?;
  //   if(error != null) {
  //     Get.showSnackbar(GetSnackBar(message: error.toString(),));
  //   }

  // }
  Future <void> registerP() async {
    String? error = await AuthenticationRepository.instance.registerPUser(
      email.text.trim(), password.text.trim());
    if(error != null) {
      Get.showSnackbar(GetSnackBar(message: error.toString(),));
    }
  }

  Future <void> registerC() async {
    String? error = await AuthenticationRepository.instance.registerCUser(
      email.text.trim(), password.text.trim());
    if(error != null) {
      Get.showSnackbar(GetSnackBar(message: error.toString(),));
    }
  }

  // Future<void> createUser(PatientModel user) async {
  //   await userRepo.createPatientUser(user);
  // }


}