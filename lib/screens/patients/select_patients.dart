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
import 'package:my_project/notification_service.dart';
import 'package:http/http.dart' as http; // ✅ Add this import
import 'dart:convert'; // ✅ Add this import
import '../../models/medications.dart';
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

  // ✅ NEW: Add frequency and day selection state
  Map<String, ReminderFrequency> _selectedFrequency = {};
  Map<String, int> _selectedDayOfWeek = {}; // For weekly reminders

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

  // ✅ FIXED: Add currentUserUid definition
  Future<void> _sendVerificationEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ ADD THIS: Get current user UID
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid == null) {
        throw Exception('User not authenticated');
      }

      final email = _emailController.text.trim().toLowerCase();
      print('🔍 Searching for patient with email: $email');
      
      // ✅ Add manual Firestore query for debugging
      final debugSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      print('📊 Total users in database: ${debugSnapshot.docs.length}');
      
      // Print all emails for debugging
      for (var doc in debugSnapshot.docs) {
        final userData = doc.data();
        final userEmail = userData['Email'];
        final loginType = userData['LoginType'];
        print('👤 User: $userEmail, Type: $loginType');
      }
      
      // Check if patient exists with this email
      final patient = await userRepo.getUserByEmail(email);
      
      if (patient == null) {
        print('❌ Patient not found with email: $email');
        
        Get.snackbar(
          "Patient Not Found",
          "No patient found with email: $email. Please check the email address and try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }
      
      print('✅ Found patient: ${patient.name} (${patient.email})');
      print('🔍 Patient login type: ${patient.loginType}');

      if (patient.loginType != LoginType.patient && patient.loginType != LoginType.dualAccount) {
        Get.snackbar(
          "Error",
          "This user is not registered as a patient.",
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
          "Error",
          "This patient is already in your patient list.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get caregiver info
      final caregiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid) // ✅ Now this is defined
          .get();
      
      final caregiverData = caregiverDoc.data();
      final caregiverName = caregiverData?['FullName'] ?? 'Unknown Caregiver';
      final caregiverEmail = caregiverData?['Email'] ?? 'Unknown Email';

      // ✅ Create verification request in Firestore
      // This will automatically trigger the Firebase Function to send email
      final verificationDoc = await FirebaseFirestore.instance
          .collection('verification_requests')
          .add({
        'caregiverUid': currentUserUid, // ✅ Now this is defined
        'caregiverName': caregiverName,
        'caregiverEmail': caregiverEmail,
        'patientUid': patient.id,
        'patientName': patient.name,
        'patientEmail': patient.email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(days: 1))), // 24 hour expiry
      });

      print('Verification request created: ${verificationDoc.id}');
      print('Firebase Function will automatically send email to: ${patient.email}');

      // ✅ Show success message
      Get.snackbar(
        "Email Sent!",
        "Verification email sent to ${patient.name} (${patient.email}). They need to check their email and click the verification link.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
        duration: Duration(seconds: 5),
      );

      _emailController.clear();

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

  // ✅ UPDATE: Enhanced patient card with frequency options
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
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          
          // ✅ NEW: Frequency Selection
          Text(
            "Reminder Frequency:",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<ReminderFrequency>(
                  title: const Text('Daily', style: TextStyle(fontSize: 12)),
                  value: ReminderFrequency.daily,
                  groupValue: _selectedFrequency[id] ?? ReminderFrequency.daily,
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency[id] = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<ReminderFrequency>(
                  title: const Text('Weekly', style: TextStyle(fontSize: 12)),
                  value: ReminderFrequency.weekly,
                  groupValue: _selectedFrequency[id] ?? ReminderFrequency.daily,
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency[id] = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // ✅ NEW: Day of Week Selection (only for weekly)
          if (_selectedFrequency[id] == ReminderFrequency.weekly) ...[
            const SizedBox(height: 10),
            Text(
              "Day of Week:",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedDayOfWeek[id],
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Select Day'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monday')),
                DropdownMenuItem(value: 2, child: Text('Tuesday')),
                DropdownMenuItem(value: 3, child: Text('Wednesday')),
                DropdownMenuItem(value: 4, child: Text('Thursday')),
                DropdownMenuItem(value: 5, child: Text('Friday')),
                DropdownMenuItem(value: 6, child: Text('Saturday')),
                DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDayOfWeek[id] = value!;
                });
              },
            ),
          ],

          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: time ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _selectedTimes[id] = selectedTime;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    time != null 
                        ? 'Time: ${time.format(context)}' 
                        : 'Set Time',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (time != null)
                ElevatedButton(
                  onPressed: () => _scheduleEnhancedNotificationForPatient(id, name, time),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Set Reminder',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          caregiverPatientCardView(id.hashCode, id),
        ],
      ),
    );
  }

  // ✅ NEW: Schedule push notification to patient
  Future<void> _schedulePatientPushNotification(
    String patientId,
    String patientName,
    TimeOfDay selectedTime,
    ReminderFrequency frequency,
    {int? dayOfWeek, String? medicationName}
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final idToken = await user.getIdToken();
      
      // Call Firebase Function to schedule push notification
      final response = await http.post(
        Uri.parse('https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/schedulePatientNotification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'patientId': patientId,
            'patientName': patientName,
            'medicationName': medicationName ?? 'medication',
            'scheduledTime': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
            'frequency': frequency.name,
            'dayOfWeek': dayOfWeek,
            'title': '💊 Medication Reminder',
            'message': 'Time to take your ${medicationName ?? 'medication'}!',
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result']['success'] == true) {
          final nextExecution = result['result']['nextExecution'];
          
          Get.snackbar(
            "Push Notification Scheduled ✅",
            "Patient will receive push notifications ${frequency.name} at ${selectedTime.format(context)}",
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
            colorText: const Color(0xFFF6F3E7),
            duration: const Duration(seconds: 4),
          );
        } else {
          throw Exception(result['result']['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to schedule notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error scheduling push notification: $e');
      Get.snackbar(
        "Error",
        "Failed to schedule push notification: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // ✅ UPDATE: Enhanced scheduling method that includes both local AND push notifications
  Future<void> _scheduleEnhancedNotificationForPatient(
    String patientId,
    String patientName,
    TimeOfDay selectedTime,
  ) async {
    try {
      final frequency = _selectedFrequency[patientId] ?? ReminderFrequency.daily;
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      print('🔔 Scheduling ${frequency.name} notifications for patient: $patientName');
      
      // 1. Schedule LOCAL notification for CAREGIVER
      if (frequency == ReminderFrequency.daily) {
        await NotificationService.scheduleDailyNotification(
          id: notificationId,
          title: 'Daily Medication Reminder for $patientName',
          body: 'Time to remind $patientName to take their medication!',
          time: selectedTime,
          data: {
            'type': 'medication_reminder',
            'patientId': patientId,
            'patientName': patientName,
            'frequency': 'daily',
            'notificationId': notificationId,
          },
        );
      } else if (frequency == ReminderFrequency.weekly) {
        final dayOfWeek = _selectedDayOfWeek[patientId];
        if (dayOfWeek == null) {
          Get.snackbar(
            "Error",
            "Please select a day of the week for weekly reminders",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.7),
            colorText: Colors.white,
          );
          return;
        }

        await NotificationService.scheduleWeeklyNotification(
          id: notificationId,
          title: 'Weekly Medication Reminder for $patientName',
          body: 'Time to remind $patientName to take their medication!',
          time: selectedTime,
          dayOfWeek: dayOfWeek,
          data: {
            'type': 'medication_reminder',
            'patientId': patientId,
            'patientName': patientName,
            'frequency': 'weekly',
            'dayOfWeek': dayOfWeek,
            'notificationId': notificationId,
          },
        );
      }

      // 2. Schedule PUSH notification for PATIENT
      await _schedulePatientPushNotification(
        patientId,
        patientName,
        selectedTime,
        frequency,
        dayOfWeek: frequency == ReminderFrequency.weekly ? _selectedDayOfWeek[patientId] : null,
        medicationName: 'medication', // You can make this dynamic
      );

      // 3. Save to database
      await userRepo.createMedicationNotification(
        patientId,
        'Medication Reminder',
        '${frequency.name.toUpperCase()} reminder for $patientName at ${selectedTime.format(context)}',
        DateTime.now().toIso8601String(),
      );

      // 4. Show success message
      final dayText = frequency == ReminderFrequency.weekly 
          ? ' on ${_getDayName(_selectedDayOfWeek[patientId]!)}'
          : '';
          
      Get.snackbar(
        "Success ✅",
        "Both caregiver and patient notifications scheduled ${frequency.name}$dayText at ${selectedTime.format(context)}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
        colorText: const Color(0xFFF6F3E7),
      );

    } catch (e) {
      print('❌ Error scheduling enhanced notifications: $e');
      Get.snackbar(
        "Error",
        "Failed to schedule notifications: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Helper method for day names
  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
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

  // ✅ UPDATED: Send push notification to patient using HTTP
  Future<void> _sendPushNotificationToPatient(
    String patientId,
    String patientName,
    String medicationName,
  ) async {
    try {
      // Get the current user's ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final idToken = await user.getIdToken();
      
      // Call your Firebase Function directly via HTTP
      final response = await http.post(
        Uri.parse('https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/sendMedicationReminderToPatient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'patientId': patientId,
            'patientName': patientName,
            'medicationName': medicationName,
            'message': 'Time to take your medication!',
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result']['success'] == true) {
          Get.snackbar(
            "Success ✅",
            "Push notification sent to $patientName",
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF35365D).withOpacity(0.5),
            colorText: const Color(0xFFF6F3E7),
          );
        } else {
          throw Exception(result['result']['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending push notification: $e');
      Get.snackbar(
        "Error",
        "Failed to send notification to patient: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }
}