import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';

import '../models/grace_user.dart';

class CaregiverDataController extends GetxController {
  static CaregiverDataController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  Future<GraceUser?> getCaregiverData() async {
    final email = _authRepo.firebaseUser.value?.email;
    if (email == null) {
      Get.snackbar("Error", "Could not show email.");
      return null;
    }
    return await _userRepo.getUser(email);
  }
}
