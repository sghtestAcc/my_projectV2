import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/auth/login_page.dart';
import 'package:my_project/models/login_type.dart';
import '../models/grace_user.dart';

class AccountController extends GetxController {
  LoginType loginType = LoginType.patient;
  LoginType actualAccountType = LoginType.patient;
}
