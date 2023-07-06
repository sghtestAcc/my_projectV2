import 'package:get/get.dart';
import 'package:my_project/models/authentication_repository.dart';
import 'package:my_project/models/user_repo.dart';

class CaregiverDataController extends GetxController {
  static CaregiverDataController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  getCaregiverData() {
    final Email = _authRepo.firebaseUser.value?.email;
    if (Email != null) {
      return _userRepo.getCaregiverDetails(Email);
    } else {
      Get.snackbar("Error", "Could not show email.");
    }
  }
}