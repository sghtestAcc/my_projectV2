import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_project/camera_home_patient.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/login_failure.dart';
import 'package:my_project/models/register_failure.dart';
import 'package:my_project/patient_home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/patients_upload.dart';
import 'package:my_project/register_page.dart';

import '../navigation.tab.dart';

void main() {
  Get.put(AuthenticationRepository());
}

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

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
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
          firebaseUser.value != null ? Get.offAll(() => HomeScreen()) : Get.to(() => RegisterScreen(registerType: LoginType2.patientsRegister));
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
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
          firebaseUser.value != null ? Get.offAll(() => HomeScreen()) : Get.to(() => RegisterScreen(registerType: LoginType2.caregiversRegister));
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      firebaseUser.value != null ? Get.offAll(() => PatientUploadScreen()) : Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = LogInFailure.fromCode(e.code);
      return ex.message;
    } catch (ex) {
      const ex = LogInFailure();
      return ex.message;
    }
    return null;

    // Future<String?> loginPUser(String email, String password) async {
    //   try {
    //     await auth.signInWithEmailAndPassword(email: email, password: password);
    //   } on FirebaseAuthException catch (e){
    //     final ex = LogInFailure.fromCode(e.code);
    //     return ex.message;
    //   } catch () {
    //     const ex = LogInFailure();
    //     return ex.message;
    //   }
    //   return null;
    // }
  }

  Future<String?> loginCUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
       firebaseUser.value != null ? Get.offAll(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,)) : Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = LogInFailure.fromCode(e.code);
      return ex.message;
    } catch (ex) {
      const ex = LogInFailure();
      return ex.message;
    }
    return null;
  }


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

  // createUserWithEmailAndPassword(String email, String password) {}
}