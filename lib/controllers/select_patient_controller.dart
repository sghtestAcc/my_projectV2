import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/repos/user_repo.dart';

import '../models/medications.dart';

class SelectPatientController extends GetxController {
  static SelectPatientController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  Future<GraceUser?> getPatientData() async {
    final email = _authRepo.firebaseUser.value?.email;
    if (email == null) {
      Get.snackbar("Error", "Could not show email.");
      return null;
    }
    return await _userRepo.getUser(email);
  }

  Future<List<GraceUser>> getPatients() async {
    return await _userRepo.getAllPatients();
  }

  // Future<List<Medication>> displayAllPatientsMedications2() async {
  //   return await _userRepo.displayAllPatientsMedications();
  // }
}
