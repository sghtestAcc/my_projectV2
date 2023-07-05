import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/login_failure.dart';
import 'package:my_project/models/register_failure.dart';

import 'package:my_project/patients_upload.dart';
import 'package:my_project/register_page.dart';

import '../navigation.tab.dart';
import 'package:my_project/models/user_repo.dart';

void main() {
  Get.put(AuthenticationRepository());
}

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

    final  userRepofiles = Get.put(UserRepository());

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


Future<String?> registerPUser(String email, String password) async {
  try {
    final bool emailExists = await userRepofiles.isEmailExists(email);

    if (emailExists) {
      return null;
    }

    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    if (firebaseUser.value != null) {
      Get.offAll(() => HomeScreen());
    }
  } on FirebaseAuthException catch (e) {
    final ex = RegisterFailure.fromCode(e.code);
    return ex.message;
  } catch (ex) {
    const ex = RegisterFailure();
    return ex.message;
  }
  return null;
}

Future<String?> registerCUser(String email, String password) async {
  try {
    // Perform email validation
    // if (!userRepofiles.validateEmail(email)) {
    //   return 'Invalid email format.';
    // }

    // Check if the email already exists
    final bool emailExists = await userRepofiles.isCaregiversEmailExists(email);

    if (emailExists) {
      return null;
      
      
    }

    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    if (firebaseUser.value != null) {
      Get.offAll(() => HomeScreen());
    }
  } on FirebaseAuthException catch (e) {
    final ex = RegisterFailure.fromCode(e.code);
    return ex.message;
  } catch (ex) {
    const ex = RegisterFailure();
    return ex.message;
  }
  return null;
}



  Future<String?> loginPUser(String email, String password) async {
    try {

      final bool emailExists = await userRepofiles.isPatientEmailAndPasswordExists(email,password);

    if (!emailExists) {
      Get.snackbar(
       'Invalid',
      'Login information, please sign an account',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
      return null;
    }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.value != null) {
            Get.to(() => PatientUploadScreen());
      }
      // firebaseUser.value != null ? Get.offAll(() => PatientUploadScreen()) : Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = LogInFailure.fromCode(e.code);
      return ex.message;
    } catch (ex) {
      const ex = LogInFailure();
      return ex.message;
    }
    return null;
  }


  Future<String?> loginCUser(String email, String password) async {
    try {

      final bool emailExists = await userRepofiles.isCaregiversEmailAndPasswordExists(email,password);

    if (!emailExists) {
      Get.snackbar(
       'Invalid',
      'Login information, please sign an account',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
      return null;
    }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.value != null) {
            Get.to(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,));
      }
      // firebaseUser.value != null ? Get.offAll(() => PatientUploadScreen()) : Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = LogInFailure.fromCode(e.code);
      return ex.message;
    } catch (ex) {
      const ex = LogInFailure();
      return ex.message;
    }
    return null;
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
      Get.offAll(HomeScreen());
      Get.snackbar(
        'Logout',
        'You have been successfully logged out',
        duration: Duration(seconds: 2),
      );
    }
  } catch (e) {
    print('Logout error: $e');
    Get.snackbar(
      'Error',
      'An error occurred while logging out',
      duration: Duration(seconds: 2),
    );
  }
}

}