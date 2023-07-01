import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/login_failure.dart';
import 'package:my_project/patient_home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => HomeScreen())
        : Get.offAll(() => NavigatorBar());
  }
  Future<String?> loginPUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e){
      final ex = LogInFailure.fromCode(e.code);
      return ex.message;
    } catch (ex) {
      const ex = LogInFailure();
      return ex.message;
    }
    return null;
  }

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
  


  Future<void> logout() async => await _auth.signOut();
}