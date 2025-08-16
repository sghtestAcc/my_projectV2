import 'package:get/get.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/models/login_type.dart'; // Import this if not already
import 'package:firebase_auth/firebase_auth.dart';

class SelectPatientController extends GetxController {
  static SelectPatientController get instance => Get.find();
  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  Future<GraceUser?> getPatientData() async {
    String? email = _authRepo.firebaseUser.value?.email;
    if (email == null) {
      Get.snackbar("Error", "Could not show email.");
      return null;
    }
    return await _userRepo.getUser(email);
  }

  Future<List<GraceUser>> getPatients() async {
    return await _userRepo.getAllPatients();
  }

  Future<List<GraceUser>> getPatientsOfCurrentCaregiver(String caregiverUid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverUid)
          .collection('patients')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GraceUser(
          id: data['id'],
          email: data['email'],
          name: data['name'],
          loginType: _parseLoginType(data['loginType']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching caregiver patients: $e');
      return [];
    }
  }

  LoginType _parseLoginType(String? type) {
    switch (type?.toLowerCase()) {
      case 'caregiver':
        return LoginType.caregiver;
      case 'dualaccount':
        return LoginType.dualAccount;
      case 'patient':
      default:
        return LoginType.patient;
    }
  }

  User? get currentUser => _authRepo.firebaseUser.value;
}

