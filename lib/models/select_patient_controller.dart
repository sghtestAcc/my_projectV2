import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/user_repo.dart';

class SelectPatientController extends GetxController {
  static SelectPatientController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  getPatientData() {
    final Email = _authRepo.firebaseUser.value?.email;
    if (Email != null) {
      return _userRepo.getPatientDetails(Email);
    } else {
      Get.snackbar("Error", "Could not show email.");
    }
  }

  Future<List<PatientModel>> getPatients() async {
    return await _userRepo.getAllPatients();
  }
}
