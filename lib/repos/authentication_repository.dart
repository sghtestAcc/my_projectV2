import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/error/register_failure.dart';

import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';

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
//register function with backend validation -applies to both patients and caregivers-  
  Future<void> registerUser(
    String email,
    String password,
    LoginType loginType,
    GraceUser user
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = FirebaseAuth.instance.currentUser!.uid;
      UserRepository.instance.createUser(user, uid);
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Invalid',
        RegisterFailure.fromCode(e.code).message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
    } catch (ex) {
      Get.snackbar(
        'Invalid',
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

//forgetpassword function with backend validation -applies to both patients and caregivers-  
  Future<void> forgetpassword(email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
       Get.snackbar(
        'Congrats',
        'Your password reset link will be send to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
    } catch (ex) {
      Get.snackbar(
        'Invalid',
        "This email does not exist.",
        snackPosition: SnackPosition.TOP,
        // backgroundColor: Colors.redAccent.withOpacity(0.1),
        // colorText: Colors.red,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
    }
  }


Future<void> changepassword(String? email, String oldpassword, String newpassword,BuildContext context) async {
  try {
    var cred = EmailAuthProvider.credential(email: email ?? '', password: oldpassword);
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(cred).then
    ((value) => FirebaseAuth.instance.currentUser!.updatePassword(newpassword));
     Get.snackbar(
        'Congrats',
        'Your password has been successfully changed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  } catch (e) {
     Get.snackbar(
        'Invalid',
        'Your old password is not matching',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
  }
}


Future<void> MedicationChecksDoubleLayer(
  String uid, BuildContext context
) async {
    // String uid = FirebaseAuth.instance.currentUser!.uid;
    var patientMedicationExists = await userRepo.isPatientMedicationsExists(uid);
  if(!patientMedicationExists) {
     Get.snackbar(
        'Invalid',
        'You have not entered any medication yet!',
        snackPosition: SnackPosition.TOP,
        // backgroundColor: Colors.redAccent.withOpacity(0.1),
        // colorText: Colors.red,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      return;
  } else {
     Get.to(
        () => NavigatorBar(
              loginType: LoginType.patient,
            ),
      );
  }
}

//login function with backend validation - applies to both patients and caregivers - 
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
        'Login information, please sign up for an account',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      return;
    }
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var patientMedicationExists = await userRepo.isPatientMedicationsExists(uid);
    if (loginType == LoginType.patient && !patientMedicationExists) {
        Get.to(
          () => const PatientUploadMedsScreen(),
        );
    } else {
      if (loginType == LoginType.patient && patientMedicationExists) {
        Get.to(
        () => NavigatorBar(
              loginType: LoginType.patient,
            ),
      );
      } else {
        Get.to(
          () => NavigatorBar(
                loginType: LoginType.caregiver,
              ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    print("ERROR: $e");
    Get.snackbar(
      'Invalid',
      RegisterFailure.fromCode(e.code).message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
  } 
}


//logout function
  Future<void> logout() async {
    try {
      if (firebaseUser.value != null) {
        await _auth.signOut();
        Get.offAll(const HomeScreen());
        Get.snackbar(
          'Logout',
          'You have been successfully logged out',
          duration: const Duration(seconds: 2),
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7)
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
