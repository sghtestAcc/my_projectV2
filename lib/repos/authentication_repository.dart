import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/error/register_failure.dart';
import 'package:my_project/notification_service.dart';
import 'package:my_project/controllers/account_controller.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GraceUser user,
  BuildContext context,
) async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = FirebaseAuth.instance.currentUser!.uid;

    bool success = await UserRepository.instance.createUser(user, uid, context);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      String savedLocaleCode = prefs.getString('selectedLocale') ?? 'en';
      Get.updateLocale(Locale(savedLocaleCode));

      await Future.delayed(const Duration(milliseconds: 1500));

      Get.offAll(() => const HomeScreen());
    }

  } on FirebaseAuthException catch (e) {
    print('Firebase error: ${e.code}');
    Get.snackbar(
      AppLocalizations.of(context)!.snackbarInvalid,
      RegisterFailure.fromCode(e.code, context).message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
      colorText: const Color(0xFFF6F3E7),
    );
  } catch (ex) {
    Get.snackbar(
      AppLocalizations.of(context)!.snackbarInvalid,
      AppLocalizations.of(context)!.errorUnknown,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
  }
}


//forgetpassword function with backend validation -applies to both patients and caregivers-
  Future<void> forgetpassword(email, BuildContext context) async {
    try {
// if function is successful, an congrat massage will be sent to user -applies to both patients and caregivers-
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarCongrats,
        AppLocalizations.of(context)!.passwordResetSent,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
      );
    } catch (ex) {
// if email is not matching firebase authemtication, error massage will be sent to user -applies to both patients and caregivers-
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.errorEmailNotExist,
          snackPosition: SnackPosition.TOP,
          // backgroundColor: Colors.redAccent.withOpacity(0.1),
          // colorText: Colors.red,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
    }
  }

//function to change password -applies to both Patients and Caregivers-
  Future<void> changepassword(String? email, String oldpassword,
      String newpassword, BuildContext context) async {
    try {
      var cred = EmailAuthProvider.credential(
          email: email ?? '', password: oldpassword);
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(cred)
          .then((value) =>
              FirebaseAuth.instance.currentUser!.updatePassword(newpassword));
      // if function is successful, show an change password message
      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.passwordChangedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
    // if function is not working, it means that password is not matching
    catch (e) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.errorOldPasswordMismatch,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
    }
  }

  Future<void> MedicationChecksDoubleLayer(
      String uid, BuildContext context) async {
    final user = await userRepo.getUserById(uid);

    var patientMedicationExists =
        await userRepo.isPatientMedicationsExists(uid);

    if (!patientMedicationExists) {
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        AppLocalizations.of(context)!.errorMedicationMissing,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      return;
    }

    Get.to(() => NavigatorBar(
          loginType: LoginType.patient,
          actualAccountType: user.loginType, // ← this is now required
        ));
  }

//login function with backend validation - applies to both patients and caregivers -
  Future<void> loginUser(String email, String password, LoginType loginType,
      BuildContext context) async {
    try {
      // 🔍 Fetch user (regardless of login type)
      final user = await userRepo.getUserByEmail(email);

      if (user == null) {
        Get.snackbar(
          AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.errorLogin,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
          colorText: const Color(0xFFF6F3E7),
        );
        return;
      }

      if (user.loginType != loginType &&
          user.loginType != LoginType.dualAccount) {
        Get.snackbar(
          AppLocalizations.of(context)!.invalidAccountType,
          AppLocalizations.of(context)!.notRegisteredAs(loginType.name),
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
          colorText: const Color(0xFFF6F3E7),
        );
        return;
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = FirebaseAuth.instance.currentUser!.uid;

      final accountController = Get.find<AccountController>();
      accountController.loginType = loginType; // selected by user
      accountController.actualAccountType = user.loginType; // from DB

      final hasMedications = await userRepo.isPatientMedicationsExists(uid);

      if (loginType == LoginType.patient && !hasMedications) {
        Get.to(() => const PatientUploadMedsScreen());
      } else {
        Get.snackbar(
          AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.loginSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
          colorText: const Color(0xFFF6F3E7),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.to(() => NavigatorBar(
              loginType: loginType,
              actualAccountType: user.loginType,
            ));
      }
    } on FirebaseAuthException catch (e) {
      print("ERROR: $e");
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        RegisterFailure.fromCode(e.code, context).message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
      );
    }
  }

//logout function
  Future<void> logout(BuildContext context) async {
    try {
      if (firebaseUser.value != null) {
        await _auth.signOut();
        Get.offAll(const HomeScreen());
        Get.snackbar(AppLocalizations.of(context)!.snackbarLogoutTitle,
            AppLocalizations.of(context)!.snackbarLogoutSuccess,
            duration: const Duration(seconds: 2),
            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
            colorText: Color(0xFFF6F3E7));
      }
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        AppLocalizations.of(context)!.errorLogout,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
