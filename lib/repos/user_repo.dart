import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/models/images_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/medications.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final firestore = FirebaseFirestore.instance;
  final firebasestorage = FirebaseStorage.instance;

  Future<bool> isEmailExists(String email, LoginType loginType) async {
    final CollectionReference usersCollection = firestore.collection('users');
    var snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .where("LoginType", isEqualTo: loginType.name)
        .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
  }

  Future<bool> createUser(GraceUser user, String uid) async {
    final String email = user.email!;
    final bool emailExists = await isEmailExists(email, user.loginType);
    if (emailExists) {
      Get.snackbar(
        "Error",
        "Email already exists.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      return true;
    }
    try {
      await firestore.collection("users").doc(uid).set(user.toJson());
      Get.snackbar(
        "Congrats",
        "A new account has been created.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      return true;
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new account.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
      return false;
    }
  }

  Future<void> addImage(
  XFile? image,
  String uid,
) async {
  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final pathRoute = 'profileImages/$fileName';
    String imageUrl = await uploadImageToStorage(pathRoute, image!);
    await FirebaseFirestore.instance.collection("users")
    .doc(uid)
    .collection('profile')
    .doc(uid)
    .set({
      "images": imageUrl,
    });
    Get.snackbar(
      "Congrats",
      "A new image has been added",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to edit image",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
    print(error.toString());
  }
}

Stream<ImagesUser?> getUserimages(String? uid) {
  return firestore
      .collection("users")
      .doc(uid)
      .collection('profile')
      .snapshots()
      .map((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return ImagesUser.fromSnapshot(querySnapshot.docs.first);
        } else {
          return null; // Or return some default value if you prefer
        }
      });
}

// Future<ImagesUser?> getUserImages2(String? uid) async {
//   final snapshot = await firestore
//       .collection("users")
//       .doc(uid)
//       .collection('profile')
//       .get();
//   final imagesList = snapshot.docs
//       .map((docSnapshot) => ImagesUser.fromSnapshot(docSnapshot))
//       .single;
//   return imagesList;
// }

// //retrieve caregivers questions function(of single users)
Stream<List<String>> getQuestionsofPatient(String? email) {
  return firestore
      .collection("questions")
      .where("Email", isEqualTo: email)
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc.data()["Question"].toString()).toList());
}

//retrieve caregivers questions function(of single users)
  Stream<List<String>> getQuestionsofCaregiver(String? email)  {
     return firestore
      .collection("questions")
      .where("Email", isEqualTo: email)
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc.data()["Question"].toString()).toList());
}


Future<bool> isQuestionsEmailExists(String email, String question) async {
  final CollectionReference usersCollection = firestore.collection('questions');
  String lowerCaseQuestion = question.toLowerCase();
  var snapshot = await usersCollection
      .where("Email", isEqualTo: email)
      .where("Question", isEqualTo: lowerCaseQuestion)
      .get();
  var isEmailExists = snapshot.docs.isNotEmpty;
  return isEmailExists;
}

//create patients questions function
  Future<void> createPatientUserQuestions(
  BuildContext context, 
  String email,
  String question,
) async {
  final doesUserExists = await isEmailExists(email, LoginType.patient);
  final doesUserQuestionExists = await isQuestionsEmailExists(email, question);
  if (!doesUserExists) return;
  if (doesUserQuestionExists) {
    Get.snackbar(
      "Error",
      "This question already exists for the given email.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
    return;
  }
  try {
    await firestore.collection("questions").add({
      "Email": email,
      "Question": question,
    });
    Get.snackbar(
      "Congrats",
      "A new question has been created.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to create a new question.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
    print(error.toString());
  }
}

Future<bool> isPatientMedicationsExists(String uid) async {
    final CollectionReference usersCollection = firestore.collection('users')
    .doc(uid)
    .collection('medications');
    var snapshot = await usersCollection
    .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
}


Future<String> uploadImageToStorage(String childName, XFile file) async {
  FirebaseStorage storage = FirebaseStorage.instance; 
  Reference fileReference = storage.ref().child(childName);
  try {
    UploadTask uploadTask = fileReference.putFile(File(file.path));
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  } catch (error) {
    print(error.toString()); // You may want to handle the error appropriately
    throw Exception('Image upload failed.'); // Throw an exception instead of returning null
  }
}

// Create patient medications
Future<void> createPatientMedications(
  String? labels,
  XFile? pills,
  String quantity,
  String schedule,
) async {
  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final pathRoute = 'medicationPills/$fileName';
    String imageUrl = await uploadImageToStorage(pathRoute, pills!);
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid)
    .collection('medications')
    .add({
      "Labels":labels,
      "Pills":imageUrl,
      "Quantity":quantity,
      "Schedule": schedule
    });

    Get.snackbar(
      "Congrats",
      "A new medication has been added.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to add a medication",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7)
    );
    print(error.toString());
  }
}

Future<void> deleteBothUserQuestions(
  BuildContext context,
  String email,
  String question,
) async {
  try {
    final querySnapshot = await firestore.collection("questions")
        .where("Email", isEqualTo: email)
        .where("Question", isEqualTo: question)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    Get.snackbar(
      "Success",
      "The question has been deleted.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  } catch (error) {
    Get.snackbar(
      "Error",
      "Failed to delete the question.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
      colorText: Color(0xFFF6F3E7),
    );
    print(error.toString());
  }
}


Stream<List<GraceUser>> getAllPatientsWithMedications2() async* {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
      await FirebaseFirestore.instance.collection("users")
      .where("LoginType", isEqualTo: LoginType.patient.name)
      .get();

  final List<Future<bool>> hasMedicationsFutures = [];
  List<GraceUser> patientsWithMedications = [];

  for (var userDoc in usersSnapshot.docs) {
    String uid = userDoc.id;
    hasMedicationsFutures.add(isPatientMedicationsExists(uid));
  }

  final List<bool> hasMedicationsResults = await Future.wait(hasMedicationsFutures);

  for (int i = 0; i < usersSnapshot.docs.length; i++) {
    var userDoc = usersSnapshot.docs[i];
    String uid = userDoc.id;

    if (hasMedicationsResults[i] && uid != currentUserUid) {
      var patientData = GraceUser.fromSnapshot(userDoc);
      patientsWithMedications.add(patientData);
    }
  }
  yield patientsWithMedications;
}


Future<List<GraceUser>> getAllPatientsWithMedications() async {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
      await FirebaseFirestore.instance.collection("users")
      .where("LoginType", isEqualTo: LoginType.patient.name)
      .get();

  List<GraceUser> patientsWithMedications = [];
  for (var userDoc in usersSnapshot.docs) {
    String uid = userDoc.id;
    bool hasMedications = await isPatientMedicationsExists(uid);

    if (hasMedications && uid != currentUserUid) {
      var patientData = GraceUser.fromSnapshot(userDoc);
      patientsWithMedications.add(patientData);
    }
  }
  return patientsWithMedications;
}

Future<List<Medication>> displayAllPatientsMedications(String? uid) async {
  var patientDataMedications = await firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get();
      final patientData = patientDataMedications.docs
        .map(
          (e) => Medication.fromSnapshot(e),
        )
        .toList();
    return patientData;
}

Stream<List<Medication>> getPatientMedications(String? uid) {
  // Fetch the data using Firestore's future method
  return firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get()
      .then((querySnapshot) {
    final patientData = querySnapshot.docs
        .map((e) => Medication.fromSnapshot(e))
        .toList();
    return patientData;
  }).asStream(); // Convert the Future to a Stream
}

Future<bool> isEmailExists2(String email) async {
    final CollectionReference usersCollection = firestore.collection('medications');
    var snapshot = await usersCollection
        .where('Email', isEqualTo: email)
        .get();
    var isEmailExists = snapshot.docs.isNotEmpty;
    return isEmailExists; // If the snapshot has documents, email exists
  }

Future<List<Medication>> getAllPatientsMedications(String uid) async {
  // final doesUserExists = await isEmailExists(email, LoginType.patient);
  // if (!doesUserExists) throw Exception('User does not exists');
  var patientDataMedications = await firestore
      .collection("users")
      .doc(uid)
      .collection('medications')
      .get();
      final patientData = patientDataMedications.docs
        .map(
          (e) => Medication.fromSnapshot(e),
        )
        .toList();
    return patientData;
}


  //create caregivers questions function
  Future<void> createCaregiverUserQuestions(
    BuildContext context, 
    String email,
    String question,
  ) async {
    final doesUserExists = await isEmailExists(email, LoginType.caregiver);
    final doesUserQuestionExists = await isQuestionsEmailExists(email, question);
    if (!doesUserExists) return;
     if (doesUserQuestionExists) {
    Get.snackbar(
      "Error",
      "This question already exists for the given email.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
      colorText: Colors.red,
    );
    return;
  }
    try {
      await firestore.collection("questions").add({
        "Email": email,
        "Question": question,
      });
      Get.snackbar(
        "Congrats",
        "A new question has been created.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to create a new question.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
      print(error.toString());
    }
  }


  Future<GraceUser?> getUser(String email) async {
    final snapshot = await firestore
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser?.fromSnapshot(e),
        )
        .single;
    return patientData;
  }


   Future<List<GraceUser>> getMultipleUser(String email) async {
    final snapshot = await firestore
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser.fromSnapshot(e),
        )
        .toList();
    return patientData;
  }

  

  Future<List<GraceUser>> getAllPatients() async {
    final snapshot = await firestore
        .collection("users")
        .where("LoginType", isEqualTo: LoginType.patient.name)
        .get();
    final patientData = snapshot.docs
        .map(
          (e) => GraceUser.fromSnapshot(e),
        )
        .toList();
    return patientData;
  }

  getSingleUserQuestionPatient(String s) {}
}