import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/user_repo.dart';

class SelectPatientController extends GetxController {
  static SelectPatientController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  getPatientData() {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return _userRepo.getPatientDetails(email);
    } else {
      Get.snackbar("Error", "Could not show email.");
    }
  }

  Future<List<PatientModel>> getPatients() async {
    return await _userRepo.getAllPatients();
  }
}
