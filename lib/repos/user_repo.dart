import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
import 'package:my_project/models/notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../notification_service.dart';
import 'package:my_project/utils/medication_refill_calculator.dart';


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

  Future<bool> isEmailExistsWithValidLoginType(
      String email, LoginType attemptedLoginType) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;

    return user.loginType == attemptedLoginType ||
        user.loginType == LoginType.dualAccount;
  }

  Future<GraceUser?> getUserByEmail(String email) async {
    try {
      print('🔍 Searching for user with email: $email');
      
      // Convert to lowercase for consistent searching
      final emailLower = email.toLowerCase().trim();
      
      // Query the users collection for matching email
      final snapshot = await firestore
          .collection('users')
          .where('Email', isEqualTo: emailLower)  // Case-sensitive search first
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        print('✅ Found user with exact email match');
        return GraceUser.fromSnapshot(snapshot.docs.first);
      }
      
      // If no exact match, try case-insensitive search
      final allUsersSnapshot = await firestore.collection('users').get();
      
      for (var doc in allUsersSnapshot.docs) {
        final userData = doc.data();
        final userEmail = userData['Email']?.toString().toLowerCase().trim();
        
        if (userEmail == emailLower) {
          print('✅ Found user with case-insensitive email match');
          return GraceUser.fromSnapshot(doc);
        }
      }
      
      print('❌ No user found with email: $email');
      return null;
      
    } catch (e) {
      print('❌ Error searching for user by email: $e');
      return null;
    }
  }

  Future<GraceUser> getUserById(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();
    return GraceUser.fromSnapshot(snapshot);
  }

  Future<bool> createUser(
      GraceUser user, String uid, BuildContext context) async {
    final String email = user.email!;
    final bool emailExists = await isEmailExists(email, user.loginType);
    if (emailExists) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.errorEmailExists,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      return true;
    }
    try {
      await firestore.collection("users").doc(uid).set(user.toJson());
      print("✅ Firestore set completed");
      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.accountCreatedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      return true;
    } catch (error) {
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        AppLocalizations.of(context)!.accountCreationFailed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
      return false;
    }
  }

  //function to change fullname -applies to both Patients and Caregivers-
  Future<void> editPatientDetails(String name, BuildContext context) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "Name": name,
      });

      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.userFullNameUpdated,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      Navigator.pop(context);
    } catch (error) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.errorFullNameUpdateFailed,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      print(error.toString());
    }
  }

  Future<void> deleteMedication(String uid, String? medicationId) async {
    if (medicationId == null) return;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('medications')
        .doc(medicationId)
        .delete();
  }

  //adding image for profile page -applies to both patients and caregivers-
  Future<void> addImage(
    XFile? image,
    String uid,
    BuildContext context,
  ) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final pathRoute = 'profileImages/$fileName';
      String imageUrl = await uploadImageToStorage(pathRoute, image!);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection('profile')
          .doc(uid)
          .set({
        "images": imageUrl,
      });
      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.imageUploadSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
    } catch (error) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.imageUploadError,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      print(error.toString());
    }
  }

  //display user profile image -applies to both patients and caregivers-
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

  //retrieve caregivers questions function(of single users)
  Stream<List<String>> getQuestionsofPatient(String? email) {
    return firestore
        .collection("questions")
        .where("Email", isEqualTo: email)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => doc.data()["Question"].toString())
            .toList());
  }

  //retrieve caregivers questions function(of single users)
  Stream<List<String>> getQuestionsofCaregiver(String? email) {
    return firestore
        .collection("questions")
        .where("Email", isEqualTo: email)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => doc.data()["Question"].toString())
            .toList());
  }

  //check for identical questions within the same email
  Future<bool> isQuestionsEmailExists(String email, String question) async {
    final CollectionReference usersCollection =
        firestore.collection('questions');
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
    final doesUserQuestionExists =
        await isQuestionsEmailExists(email, question);
    if (!doesUserExists) return;
    //apply the function to check for identical questions, if it exist show the user an error message
    if (doesUserQuestionExists) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.questionExistsError,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      return;
    }
    try {
      await firestore.collection("questions").add({
        "Email": email,
        "Question": question,
      });
      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.questionCreatedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid,
          AppLocalizations.of(context)!.questionCreationFailed,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      print(error.toString());
    }
  }

  Future<bool> isPatientMedicationsExists(String uid) async {
    final CollectionReference usersCollection =
        firestore.collection('users').doc(uid).collection('medications');
    var snapshot = await usersCollection.get();
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
      throw Exception(
          'Image upload failed.'); // Throw an exception instead of returning null
    }
  }

  // Create a single patient medications with these information
  // Future<void> createPatientMedications(
  //   String? labels,
  //   List<XFile> pills,
  //   String quantity,
  //   String schedule,
  // ) async {
  //   try {
  //     final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //     final pathRoute = 'medicationPills/$fileName';
  //     String imageUrl = await uploadImageToStorage(pathRoute, pills!);
  //     String uid = FirebaseAuth.instance.currentUser!.uid;
  //     await FirebaseFirestore.instance.collection("users").doc(uid)
  //     .collection('medications')
  //     .add({
  //       "Labels":labels,
  //       "Pills":imageUrl,
  //       "Quantity":quantity,
  //       "Schedule": schedule
  //     });
  //     Get.snackbar(
  //       "Congrats",
  //       "A new medication has been added.",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Color(0xFF35365D).withOpacity(0.5),
  //       colorText: Color(0xFFF6F3E7)
  //     );
  //   } catch (error) {
  //     Get.snackbar(
  //       "Error",
  //       "Failed to add a medication",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Color(0xFF35365D).withOpacity(0.5),
  //       colorText: Color(0xFFF6F3E7)
  //     );
  //     print(error.toString());
  //   }
  // }

  Future<void> createPatientMedications(
      BuildContext context,
      String? labels,
      List<XFile> packagingImages,
      List<XFile> pills,
      String quantity,
      String dosage,
      String instructions,
      {String? details}) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      List<String> pillsUrls = [];
      List<String> packagingUrls = [];

      // Upload images (existing code)
      for (XFile pill in pills) {
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final pathRoute = 'medicationPills/$fileName';
        String imageUrl = await uploadImageToStorage(pathRoute, pill);
        pillsUrls.add(imageUrl);
      }

      for (XFile packaging in packagingImages) {
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final pathRoute = 'medications/$fileName';
        String imageUrl = await uploadImageToStorage(pathRoute, packaging);
        packagingUrls.add(imageUrl);
      }

      // Create medication document
      final medicationRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection('medications')
          .add({
        "Labels": labels,
        "Pills": pillsUrls,
        "Packaging": packagingUrls,
        "Quantity": quantity,
        "Dosage": dosage,
        "Email": FirebaseAuth.instance.currentUser!.email,
        "Name": FirebaseAuth.instance.currentUser!.displayName,
        "Instructions": instructions,
        "Details": details,
        "CreatedAt": FieldValue.serverTimestamp(),
        "RefillNotificationScheduled": true,
      });

      // ✅ Schedule automatic refill notification
      await _scheduleRefillNotificationForMedication(
        medicationId: medicationRef.id,
        medicationName: labels ?? 'Unknown Medication',
        uid: uid,
        quantity: quantity,
        instructions: instructions,
      );

      Get.snackbar(
        "Success ✅",
        "Medication added and refill notification scheduled!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7)
      );
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to add medication: ${error.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print(error.toString());
    }
  }

  // ✅ Add this helper method to UserRepository
  Future<void> _scheduleRefillNotificationForMedication({
    required String medicationId,
    required String medicationName,
    required String uid,
    required String quantity,
    required String instructions,
  }) async {
    try {
      // Get patient data
      final userDoc = await firestore.collection('users').doc(uid).get();
      final patientName = userDoc.data()?['FullName'] ?? 'Patient';

      // Schedule refill notification
      await NotificationService.scheduleRefillNotification(
        medicationId: medicationId,
        medicationName: medicationName,
        patientName: patientName,
        quantity: quantity,
        instructions: instructions,
        medicationStartDate: DateTime.now(),
      );

      // Log the calculation for debugging
      final description = MedicationRefillCalculator.getCalculationDescription(
        quantity: quantity,
        instructions: instructions,
      );
      print('📊 Refill calculation: $description');

    } catch (e) {
      print('❌ Error scheduling refill notification: $e');
    }
  }

  // ✅ NEW: Schedule refill notification when medication is added
Future<void> scheduleRefillNotification({
  required String medicationId,
  required String patientId,
  required String quantity,
  required String instructions,
  required String medicationName,
  required String caregiverUid,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final idToken = await user.getIdToken();
    
    final response = await http.post(
      Uri.parse('https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/scheduleRefillNotification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'medicationId': medicationId,
        'patientId': patientId,
        'quantity': quantity,
        'instructions': instructions,
        'medicationName': medicationName,
        'caregiverUid': caregiverUid,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Refill notification scheduled: ${result['result']['message']}');
    } else {
      throw Exception('Failed to schedule refill notification: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error scheduling refill notification: $e');
    rethrow;
  }
}

  Future<void> deleteBothUserQuestions(
    BuildContext context,
    String email,
    String question,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection("questions")
          .where("Email", isEqualTo: email)
          .where("Question", isEqualTo: question)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        Get.snackbar(
          AppLocalizations.of(context)!.snackbarCongrats,
          AppLocalizations.of(context)!.questionDeletedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (error) {
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        AppLocalizations.of(context)!.questionDeleteFailed,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7),
      );
      print(error.toString());
    }
  }

  //display All patient with medications only -applies caregivers pages-
  Stream<List<GraceUser>> getAllPatientsWithMedications2() async* {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where("LoginType", isEqualTo: LoginType.patient.name)
            .get();

    final List<Future<bool>> hasMedicationsFutures = [];
    List<GraceUser> patientsWithMedications = [];

    for (var userDoc in usersSnapshot.docs) {
      String uid = userDoc.id;
      hasMedicationsFutures.add(isPatientMedicationsExists(uid));
    }

    final List<bool> hasMedicationsResults =
        await Future.wait(hasMedicationsFutures);

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
        await FirebaseFirestore.instance
            .collection("users")
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

  Future<List<Medication>> displayPatientsMedications(String? uid) async {
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

  //display all patients with medication
  Stream<List<Medication>> getAllPatientMedications(String? uid) {
    return firestore
        .collection("users")
        .doc(uid)
        .collection('medications')
        .get()
        .then((querySnapshot) {
      final patientData =
          querySnapshot.docs.map((e) => Medication.fromSnapshot(e)).toList();
      return patientData;
    }).asStream(); // Convert the Future to a Stream
  }

  //create caregivers questions function
  Future<void> createCaregiverUserQuestions(
    BuildContext context,
    String email,
    String question,
  ) async {
    final doesUserExists = await isEmailExists(email, LoginType.caregiver);
    final doesUserQuestionExists =
        await isQuestionsEmailExists(email, question);
    if (!doesUserExists) return;
    if (doesUserQuestionExists) {
      Get.snackbar(
        AppLocalizations.of(context)!.snackbarInvalid,
        AppLocalizations.of(context)!.questionAlreadyExists,
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
      Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats, AppLocalizations.of(context)!.questionCreatedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      Get.snackbar(AppLocalizations.of(context)!.snackbarInvalid, AppLocalizations.of(context)!.questionCreationFailed,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF35365D).withOpacity(0.5),
          colorText: Color(0xFFF6F3E7));
      print(error.toString());
    }
  }

  //get a single user -applies to both patients and caregivers-
  Future<GraceUser?> getUser(String? email) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await firestore.collection("users").doc(uid).get();
    if (snapshot.exists) {
      final patientData = GraceUser.fromSnapshot(snapshot);
      return patientData;
    } else {
      return null; // Document doesn't exist
    }
  }

  Stream<GraceUser?> getUserStream(String? uid) {
    StreamController<GraceUser?> userStreamController =
        StreamController<GraceUser?>();
    firestore.collection("users").doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final patientData = GraceUser.fromSnapshot(snapshot);
        userStreamController.add(patientData);
      } else {
        userStreamController.add(null); // Document doesn't exist
      }
    });
    return userStreamController.stream;
  }

  //get all patients -applies to patients only-
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

  //function to get all notification
  Stream<List<Notifications>> getAllMedicationNotification(
      String medicationUid) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection("users")
        .doc(uid)
        .collection('medications')
        .doc(medicationUid)
        .collection('notification')
        .get()
        .then((querySnapshot) {
      final patientData =
          querySnapshot.docs.map((e) => Notifications.fromSnapshot(e)).toList();
      return patientData;
    }).asStream(); // Convert the Future to a Stream
  }

  //function to create notification
  // Add this method to your UserRepository class
Future<void> createMedicationNotification(
  String patientId,
  String title,
  String body,
  String dateTime,
) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('patient_notifications')
        .add({
          'patientId': patientId,
          'title': title,
          'body': body,
          'dateTime': dateTime,
          'createdAt': FieldValue.serverTimestamp(),
          'sent': false,
        });

    print('Notification saved to Firestore');
  } catch (error) {
    print('Error saving notification: $error');
    throw error;
  }
}

  // //function to delete notification
  // Future<void> deleteMedicationNotification(
  //     String medicationUid, String notificationUid) async {
  //   try {
  //     String uid = FirebaseAuth.instance.currentUser!.uid;
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(uid)
  //         .collection('medications')
  //         .doc(medicationUid)
  //         .collection('notification')
  //         .doc(notificationUid)
  //         .delete();
  //     Get.snackbar(
  //       "Success",
  //       "Notification deleted successfully",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
  //       colorText: const Color(0xFFF6F3E7),
  //     );
  //   } catch (error) {
  //     Get.snackbar(
  //       "Error",
  //       "Failed to delete notification",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.redAccent.withOpacity(0.1),
  //       colorText: Colors.red,
  //     );
  //     print(error.toString());
  //   }
  // }
  // //function to update notification
  // Future<void> updateMedicationNotification(
  //     String medicationUid, Notifications updatedNotification) async {
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   try {
  //     var notificationDocRef = FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(uid)
  //         .collection('medications')
  //         .doc(medicationUid)
  //         .collection('notification')
  //         .doc(updatedNotification.id);
  //     print(medicationUid);
  //     print(updatedNotification.id);
  //     // Check if the medication document exists
  //     var notificationDoc = await notificationDocRef.get();

  //     if (notificationDoc.exists) {
  //       // Document exists, proceed with update
  //       await notificationDocRef.update({
  //         "Title": updatedNotification.title,
  //         "Body": updatedNotification.body,
  //         "DateTime": updatedNotification.dateTime,
  //       });

  //       Get.snackbar(
  //         "Success",
  //         "Medication details updated successfully",
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
  //         colorText: const Color(0xFFF6F3E7),
  //       );
  //     } else {
  //       // Document doesn't exist, create a new document
  //       await notificationDocRef.set({
  //         "Title": updatedNotification.title,
  //         "Body": updatedNotification.body,
  //         "DateTime": updatedNotification.dateTime,
  //       });

  //       Get.snackbar(
  //         "Success",
  //         "Medication details created successfully",
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
  //         colorText: const Color(0xFFF6F3E7),
  //       );
  //     }
  //   } catch (error) {
  //     // Handle errors and show an error message
  //     Get.snackbar(
  //       "Error",
  //       "Failed to update medication details",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.redAccent.withOpacity(0.1),
  //       colorText: Colors.red,
  //     );

  //     // Print the error message and the document path for debugging
  //     print("Error updating medication: ${error.toString()}");
  //     print(
  //         "Document path: users/$uid/medications/$medicationUid/notification/${updatedNotification.id}");
  //   }
  // }
  // Stream<Notifications> getMedicationNotificationStream(
  //     String medicationUid, String notificationUid) {
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   return firestore
  //       .collection("users")
  //       .doc(uid)
  //       .collection('medications')
  //       .doc(medicationUid)
  //       .collection('notification')
  //       .doc(notificationUid)
  //       .snapshots()
  //       .map((documentSnapshot) {
  //     return Notifications.fromSnapshot(documentSnapshot);
  //   });
  // }
  // ✅ NEW: Test refill notification
Future<void> testRefillNotification() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final idToken = await user.getIdToken();
    
    final response = await http.post(
      Uri.parse('https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/testRefillNotification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Test refill notification result: ${result['result']['message']}');
      
      Get.snackbar(
        "🧪 Test Successful",
        result['result']['message'],
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
        duration: Duration(seconds: 3),
      );
    } else {
      throw Exception('Failed to test refill notification: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error testing refill notification: $e');
    Get.snackbar(
      "❌ Test Failed",
      "Error: ${e.toString()}",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
}