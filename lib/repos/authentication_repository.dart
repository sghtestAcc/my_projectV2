import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/error/register_failure.dart';

import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  final userRepo = Get.put(UserRepository());

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    // ever(firebaseUser, _setInitialScreen);
  }

  // _setInitialScreen(User? user) {
  //   user == null
  //       ? Get.offAll(() => HomeScreen())
  //       : Get.offAll(() => NavigatorBar());
  // }

  Future<void> registerUser(
    String email,
    String password,
    LoginType loginType,
  ) async {
    try {
      var emailExists = await userRepo.isEmailExists(email, loginType);
      if (!emailExists) throw Exception("");
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Invalid',
        RegisterFailure.fromCode(e.code).message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (ex) {
      Get.snackbar(
        'Invalid',
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> loginUser(
    String email,
    String password,
    LoginType loginType,
  ) async {
    try {
      var emailExists = await userRepo.isEmailExists(email, loginType);
      if (!emailExists) {
        Get.snackbar(
          'Invalid',
          'Login information, please sign an account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.to(
        () => loginType == LoginType.patient
            ? const PatientUploadMedsScreen()
            : const NavigatorBar(
                loginType: LoginType.caregiver,
              ),
      );
    } on FirebaseAuthException catch (e) {
      print("ERROR: $e");
      Get.snackbar(
        'Invalid',
        RegisterFailure.fromCode(e.code).message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (ex) {
      Get.snackbar(
        'Invalid',
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // isCaregiversEmailAndPasswordExists

  // Future<String?> loginCUser(String email, String password) async {
  //   try {
  //     await _auth.signInWithEmailAndPassword(email: email, password: password);
  //      firebaseUser.value != null ? Get.offAll(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,)) : Get.to(() => HomeScreen());
  //   } on FirebaseAuthException catch (e) {
  //     final ex = LogInFailure.fromCode(e.code);
  //     return ex.message;
  //   } catch (ex) {
  //     const ex = LogInFailure();
  //     return ex.message;
  //   }
  //   return null;
  // }

  Future<void> logout() async {
    try {
      if (firebaseUser.value != null) {
        await _auth.signOut();
        Get.offAll(const HomeScreen());
        Get.snackbar(
          'Logout',
          'You have been successfully logged out',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while logging out',
        duration: const Duration(seconds: 2),
      );
    }
  }
}
