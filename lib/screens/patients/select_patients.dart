import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/repos/user_repo.dart';
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
  Map<String, bool> _isCheckedMap = {};
  Map<String, bool> _isTimeDropdownOpen =
      {}; // Track dropdown state for each patient
  Map<String, TimeOfDay?> _selectedTimes =
      {}; // Track selected times for each patient

  String lol = '';

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
            Container(
              color: const Color(0xFF9EE8BF),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 0, 30),
              child: Text(
                AppLocalizations.of(context)!.selectPatient,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: StreamBuilder<List<GraceUser>>(
                stream: userRepo.getAllPatientsWithMedications2(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return _emptyListView(AppLocalizations.of(context)!.noqnyet);
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        GraceUser patient = snapshot.data![index];
                        String uid = patient.id ?? '';
                        bool isChecked = _isCheckedMap[uid] ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                          child: CheckboxListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patient.name ?? '', style: const TextStyle(fontSize: 15)),
                                Text(patient.email ?? '', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            value: isChecked,
                            onChanged: (newValue) {
                              setState(() => _isCheckedMap[uid] = newValue ?? false);
                            },
                            activeColor: const Color(0xFF0CE25C),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text(AppLocalizations.of(context)!.smtwentwrong));
                  }
                },
              ),
            ),
            _buildSelectButton(),
            _buildTestNotificationButton(),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchSelectedPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return _emptyListView(AppLocalizations.of(context)!.noPatientYet);
                } else if (snapshot.hasData) {
                  return ListView.separated(
                    shrinkWrap: true,
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

Widget _emptyListView(String message) => Center(
  child: Column(
    children: [
      const SizedBox(height: 10),
      Image.asset('assets/images/to-do-list.png'),
      const SizedBox(height: 10),
      Text(message),
    ],
  ),
);

Widget _buildSelectButton() => Padding(
  padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
  child: ElevatedButton(
    onPressed: addPatientsToCurrentUser,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0CE25C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 40),
    ),
    child: const Text('Select Patient', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
  ),
);

Widget _buildTestNotificationButton() => Padding(
  padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
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
    child: const Text('🧪 Test Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
  ),
);

Widget _buildPatientCard(String id, String name, String email, bool isDropdownOpen, TimeOfDay? time) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xDDF6F6F6),
      border: Border.all(color: Colors.black.withOpacity(0.5)),
      boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 1), blurRadius: 4)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(email, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final picked = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
            if (picked != null) setState(() => _selectedTimes[id] = picked);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0CE25C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Select Time'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _isTimeDropdownOpen[id] = false;
                _selectedTimes[id] = null;
              }),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            if (isDropdownOpen && time != null)
              ElevatedButton(
                onPressed: () async {
                  await _scheduleNotificationForPatient(id, name, time);
                  setState(() {
                    _isTimeDropdownOpen[id] = false;
                    _selectedTimes[id] = null;
                  });
                },
                child: const Text('Save'),
              )
          ],
        ),
        caregiverPatientCardView(id.hashCode, id),
      ],
    ),
  );
}


//add selected Patients that has medications
  Future<void> addPatientsToCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUserId = user.uid;
        CollectionReference<Map<String, dynamic>> userCollection =
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('patients');

        List<GraceUser> patients =
            await userRepo.getAllPatientsWithMedications();

        for (String uid in _isCheckedMap.keys) {
          if (_isCheckedMap[uid] == true) {
            // Find the selected patient from the list of filtered patients
            GraceUser selectedPatient =
                patients.firstWhere((patient) => patient.id == uid);

            Map<String, dynamic> patientData = {
              'id': selectedPatient.id,
              'email': selectedPatient.email,
              'name': selectedPatient.name,
            };
            await userCollection.add(patientData);
            _isCheckedMap[uid] = false; // Set to false after adding the patient
          }
        }
        Get.snackbar(AppLocalizations.of(context)!.snackbarCongrats,
            AppLocalizations.of(context)!.newUserList,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
            colorText: Color(0xFFF6F3E7));
        setState(() {});
      }
    } catch (e) {
      print('Error adding patients: $e');
    }
  }

  //fetch selected patients with medications of a single caregiver user 
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
      print('Error fetching second list data: $e');
    }
    return Stream.value([]); // Return an empty stream if there's an error
  }

  
  // Add this method to your _SelectPatientScreenState class
  Future<void> _scheduleNotificationForPatient(
    String patientId,
    String patientName,
    TimeOfDay selectedTime,
  ) async {
    try {
      print('🔔 Scheduling notification for patient: $patientName');
      
      // Generate unique notification ID
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Schedule the notification
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

      // Save notification info to Firestore for tracking
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
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7),
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
