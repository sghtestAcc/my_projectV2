import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Map<String, bool> _isTimeDropdownOpen = {}; // Track dropdown state for each patient
  Map<String, TimeOfDay?> _selectedTimes = {}; // Track selected times for each patient
  
  String lol = '';

  @override
  Widget build(BuildContext context) {
    bool isDropdownOpen = false;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Patients',
            style: TextStyle(color: Colors.black),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height / 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                color: const Color(0xFF9EE8BF),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 30, 0, 30),
                child: const Text(
                  'Select Patient',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
                       Container(
                        height: 200,
                         child: 
                         StreamBuilder<List<GraceUser>>(
                          stream: userRepo.getAllPatientsWithMedications2(),
                          builder: (context, snapshot) {
                             if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }  else if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()));
                          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Center(
                        child: Column(
                        children: [
                        const SizedBox(height: 10,),
                        Image.asset('assets/images/to-do-list.png'), // Adjust the image path accordingly
                        const SizedBox(height: 10,),
                        Text('No questions added yet'),
                      ],
                    ),
                  );
                    } else if (snapshot.hasData) {
                                      return ListView.builder(
                                    shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                  GraceUser patient = snapshot.data![index];
                                      String uid = patient.id ?? '';
                                      String email = patient.email ?? '';
                                      String name = patient.name ?? '';
                                      bool isChecked = _isCheckedMap[uid] ?? false;
                                  return Container(
                                  decoration: BoxDecoration(
                         border: Border.all(
                           color: Colors.black,
                           width: 1.0,
                         ),
                                   ),
                                   child: CheckboxListTile(
                         title: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               name,
                               style: const TextStyle(fontSize: 15),
                             ),
                             Text(email,
                                 style: const TextStyle(fontSize: 12)),
                           ],
                         ),
                         value:  isChecked,
                         onChanged: (newValue) {
                           setState(() {
                             _isCheckedMap[uid] = newValue ?? false;
                           });
                         },
                         activeColor: const Color(0xFF0CE25C),
                                   ),
                                 );
                               },
                             );
                    } else {
                    return const Center(child: Text('Something went wrong'));
                    }
                          })
                       ),
                          Container(
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: ElevatedButton(
                  onPressed: () {
                    addPatientsToCurrentUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0CE25C), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corner radius
                    ),
                    minimumSize: const Size(double.infinity,
                        40), // Adjust the width by modifying the minimumSize property
                  ),
                  child: const Text(
                    'Select Patient',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                stream:  fetchSelectedPatients(),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Image.asset('assets/images/to-do-list.png'), // Adjust the image path accordingly
                  const SizedBox(height: 10,),
                  Text('No patients added yet'),
                ],
              ),
            );
                } else if (snapshot.hasData) {
            return Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(10.0),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (context, i) {
                  String patientName = snapshot.data![i]['name'];
                  String patientEmail = snapshot.data![i]['email'];
                  String patientid = snapshot.data![i]['id'];
                  bool isTimeDropdownOpen = _isTimeDropdownOpen[patientid] ?? false;
                  TimeOfDay? selectedTime = _selectedTimes[patientid];
                  
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                      color: Color(0xDDF6F6F6),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(patientEmail, style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        
                        // Add Alert Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0CE25C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () {
                            setState(() {
                              _isTimeDropdownOpen[patientid] = !isTimeDropdownOpen;
                            });
                          },
                          child: Text(
                            isTimeDropdownOpen ? 'Cancel Alert' : 'Add Alert',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        
                        // Time Selector Dropdown
                        if (isTimeDropdownOpen) ...[
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set Notification Time:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                
                                // Time Display and Picker
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          selectedTime != null
                                              ? selectedTime!.format(context)
                                              : 'Select time',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.access_time),
                                      onPressed: () async {
                                        final TimeOfDay? picked = await showTimePicker(
                                          context: context,
                                          initialTime: selectedTime ?? TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _selectedTimes[patientid] = picked;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 10),
                                
                                // Save and Cancel buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isTimeDropdownOpen[patientid] = false;
                                          _selectedTimes[patientid] = null;
                                        });
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF0CE25C),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: selectedTime != null
                                          ? () async {
                                              await _scheduleNotification(
                                                patientid,
                                                patientName,
                                                selectedTime!,
                                              );
                                              setState(() {
                                                _isTimeDropdownOpen[patientid] = false;
                                                _selectedTimes[patientid] = null;
                                              });
                                            }
                                          : null,
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        // // Existing medication info dropdown
                        // Row(
                        //   children: [
                        //     // const Text(
                        //     //   'View more for medication info',
                        //     //   style: TextStyle(fontSize: 10),
                        //     // ),
                        //     IconButton(
                        //       onPressed: () {
                        //         setState(() {
                        //           isDropdownOpen = !isDropdownOpen;
                        //         });
                        //       },
                        //       icon: Icon(isDropdownOpen
                        //           ? Icons.expand_less
                        //           : Icons.expand_more),
                        //     ),
                        //   ],
                        // ),
                        caregiverPatientCardView(i, patientid),
                      ],
                    ),
                  );
                },
              ),
            );
                } else {
            return const Center(child: Text('Something went wrong'));
                }
                },
              ),
              ],
            ),
          ),
        ),
        endDrawer: const AppDrawerNavigation(),
      ),
      onWillPop: () async {
        return false;
      },
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

            // Create a map representation of the patient to be added to the user's collection
            Map<String, dynamic> patientData = {
              'id': selectedPatient.id,
              'email': selectedPatient.email,
              'name': selectedPatient.name,
            };
            await userCollection.add(patientData);
            _isCheckedMap[uid] = false; // Set to false after adding the patient
          }
        }
        Get.snackbar("Congrats", "A new user has been added to your list.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
            colorText: Color(0xFFF6F3E7));
        setState(() {
          // No need to modify _allPatients, as we only modify _selectedPatients now
        });
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
}

  // Method to schedule notification
  Future<void> _scheduleNotification(
    String patientId,
    String patientName,
    TimeOfDay selectedTime,
  ) async {
    try {
      // Create notification time for today at selected time
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      
      // If time has already passed today, schedule for tomorrow
      final finalScheduledTime = scheduledDateTime.isBefore(now)
          ? scheduledDateTime.add(Duration(days: 1))
          : scheduledDateTime;

      // Schedule local notification
      await NotificationService.scheduleNotification(
        DateTime.now().millisecondsSinceEpoch, // unique notification ID
        "Medication Reminder",
        "It's time for $patientName to take their medication!",
        finalScheduledTime,
      );

      // Optionally save to Firestore for tracking
      await userRepo.createMedicationNotification(
        patientId,
        "Medication Reminder",
        "It's time for $patientName to take their medication!",
        finalScheduledTime.toIso8601String(),
      );

      Get.snackbar(
        "Success",
        "Medication reminder set for ${selectedTime.format(context)}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to schedule notification: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
