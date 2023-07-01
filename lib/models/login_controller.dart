import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();

  Future <void> login() async {
    String? error = await AuthenticationRepository.instance.loginPUser(
      email.text.trim(), password.text.trim());
    if(error != null) {
      Get.showSnackbar(GetSnackBar(message: error.toString(),));
    }
  }

}