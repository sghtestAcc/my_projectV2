import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/utils/email_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/medications.dart';
import '../../notification_service.dart';
import '../home/patient_card.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({Key? key}) : super(key: key);

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final userRepo = Get.put(UserRepository());
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Map<String, bool> _isTimeDropdownOpen = {};
  Map<String, TimeOfDay?> _selectedTimes = {};

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.patients,
            style: const TextStyle(color: Colors.black),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                color: const Color(0xFF9EE8BF),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Patient by Email",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter patient's email to send verification email",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              // Email Input Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Patient Email Address",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter patient's email address",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0CE25C), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendVerificationEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CE25C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                                  'Send Verification Email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Test Notification Button
              _buildTestNotificationButton(),

              // Current Patients Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "My Patients",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Display current patients
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchSelectedPatients(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return _emptyListView("No patients added yet");
                  } else if (snapshot.hasData) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final data = snapshot.data![i];
                        final patientid = data['id'];
                        final patientName = data['name'];
                        final patientEmail = data['email'];
                        final isTimeDropdownOpen = _isTimeDropdownOpen[patientid] ?? false;
                        final selectedTime = _selectedTimes[patientid];

                        return _buildPatientCard(
                          patientid, patientName, patientEmail, isTimeDropdownOpen, selectedTime);
                      },
                    );
                  } else {
                    return Center(child: Text(AppLocalizations.of(context)!.smtwentwrong));
                  }
                },
              ),
            ],
          ),
        ),
        endDrawer: const AppDrawerNavigation(),
      ),
    );
  }

  // ✅ Updated method to send email instead of in-app notification
  Future<void> _sendVerificationEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Check if patient exists with this email
      final patient = await userRepo.getUserByEmail(email);
      
      if (patient == null) {
        Get.snackbar(
          "Error",
          "No patient found with this email address. Ask the patient to register first.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      if (patient.loginType != LoginType.patient && patient.loginType != LoginType.dualAccount) {
        Get.snackbar(
          "Error",
          "This email is not registered as a patient account.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Check if patient is already added
      final isAlreadyAdded = await _isPatientAlreadyAdded(patient.id!);
      if (isAlreadyAdded) {
        Get.snackbar(
          "Info",
          "This patient is already under your care.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get caregiver info
      final caregiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      
      final caregiverData = caregiverDoc.data();
      final caregiverName = caregiverData?['FullName'] ?? 'Unknown Caregiver';
      final caregiverEmail = caregiverData?['Email'] ?? 'Unknown Email';

      // Create verification request in Firestore
      final verificationDoc = await FirebaseFirestore.instance
          .collection('verification_requests')
          .add({
        'caregiverUid': currentUserUid,
        'caregiverName': caregiverName,
        'caregiverEmail': caregiverEmail,
        'patientUid': patient.id,
        'patientName': patient.name,
        'patientEmail': patient.email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(days: 1))), // 24 hour expiry
      });

      // ✅ Send email to patient (ONLY email, no in-app notification)
      final emailSent = await EmailService.sendPatientVerificationEmail(
        patientEmail: patient.email!,
        patientName: patient.name ?? 'Patient',
        caregiverName: caregiverName,
        caregiverEmail: caregiverEmail,
        verificationRequestId: verificationDoc.id,
      );

      if (emailSent) {
        Get.snackbar(
          "Email Sent ✅",
          "Verification email sent to ${patient.email}. The patient will receive an email with verification instructions.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
          colorText: const Color(0xFFF6F3E7),
          duration: const Duration(seconds: 5),
        );

        _emailController.clear();
      } else {
        Get.snackbar(
          "Email Failed",
          "Failed to send verification email. Please check email service configuration and try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print('Error sending verification: $e');
      Get.snackbar(
        "Error",
        "Failed to send verification email: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _isPatientAlreadyAdded(String patientId) async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('patients')
          .where('id', isEqualTo: patientId)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking patient: $e');
      return false;
    }
  }

  Widget _emptyListView(String message) => Center(
    child: Column(
      children: [
        const SizedBox(height: 20),
        Image.asset('assets/images/to-do-list.png', height: 100),
        const SizedBox(height: 10),
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
      ],
    ),
  );

  Widget _buildTestNotificationButton() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    child: ElevatedButton(
      onPressed: () async {
        await NotificationService.showTestNotification();
        await NotificationService.scheduleNotification(
          id: 998,
          title: '⏰ Test Scheduled Notification',
          body: 'This notification was scheduled 5 seconds ago!',
          scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
          data: {'type': 'test_scheduled'},
        );
        Get.snackbar(
          "Test Notifications Sent",
          "Check for immediate and scheduled notifications",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withOpacity(0.7),
          colorText: Colors.white,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 40),
      ),
      child: const Text(
        '🧪 Test Notifications',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );

  Widget _buildPatientCard(String id, String name, String email, bool isDropdownOpen, TimeOfDay? time) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF6F6F6),
        border: Border.all(color: Colors.black.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0CE25C),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'P',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removePatient(id, name),
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                tooltip: "Remove Patient",
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedTimes[id] = picked);
                    }
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: Text(
                    time != null 
                        ? 'Time: ${time.format(context)}'
                        : 'Set Reminder Time',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (time != null)
                ElevatedButton(
                  onPressed: () async {
                    await _scheduleNotificationForPatient(id, name, time);
                    setState(() => _selectedTimes[id] = null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          caregiverPatientCardView(id.hashCode, id),
        ],
      ),
    );
  }

  // Remove patient from caregiver's list
  Future<void> _removePatient(String patientId, String patientName) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Patient'),
          content: Text('Are you sure you want to remove $patientName from your patient list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('patients')
            .where('id', isEqualTo: patientId)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        Get.snackbar(
          "Success",
          "$patientName has been removed from your patient list.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error removing patient: $e');
      Get.snackbar(
        "Error",
        "Failed to remove patient: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Fetch selected patients (unchanged)
  Stream<List<Map<String, dynamic>>> fetchSelectedPatients() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUserId = user.uid;
        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('patients');
        return collectionRef.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
    return Stream.value([]);
  }

  // Schedule notification for patient (unchanged)
  Future<void> _scheduleNotificationForPatient(
    String patientId,
    String patientName,
    TimeOfDay selectedTime,
  ) async {
    try {
      print('🔔 Scheduling notification for patient: $patientName');
      
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await NotificationService.scheduleDailyNotification(
        id: notificationId,
        title: 'Medication Reminder for $patientName',
        body: 'Time to remind $patientName to take their medication!',
        time: selectedTime,
        data: {
          'type': 'medication_reminder',
          'patientId': patientId,
          'patientName': patientName,
          'notificationId': notificationId,
        },
      );

      await userRepo.createMedicationNotification(
        patientId,
        'Medication Reminder',
        'Daily reminder for $patientName at ${selectedTime.format(context)}',
        DateTime.now().toIso8601String(),
      );

      Get.snackbar(
        "Success ✅",
        "Daily medication reminder set for $patientName at ${selectedTime.format(context)}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
      );
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      Get.snackbar(
        "Error",
        "Failed to schedule notification: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
