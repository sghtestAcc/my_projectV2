
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/patient_card.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({Key? key}) : super(key: key);

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final userRepo = Get.put(UserRepository());
  Map<String, bool> _isCheckedMap = {}; // Initialize with empty map
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
             height: MediaQuery.of(context).size.height/ 1,
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
                    'Add Patients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                stream:  fetchSecondListData(),
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
            return ListView.separated(
              padding: const EdgeInsets.all(10.0),
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 15);
              },
              itemBuilder: (context, i) {
                String patientName = snapshot.data![i]['name'];
                String patientEmail = snapshot.data![i]['email'];
                String patientid = snapshot.data![i]['id'];
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
                              patientEmail,
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(patientName),
                             if(isDropdownOpen)
                            Row(
                              children: [
                                const Text(
                                  'View more for medication info',
                                  style: TextStyle(fontSize: 10),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isDropdownOpen = !isDropdownOpen;
                                    });
                                  },
                                  icon: Icon(isDropdownOpen
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                                ),
                              ],
                            ),
                             patientcard(i, patientid),
                          ],
                        ),
                      );
              },
            );
                } else {
            return const Center(child: Text('Something went wrong'));
                }
                },
              )
                  ),
                // Include the PatientsWithMedicationsWidget here
              ],
            ),
          ),
        ),
        endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
      ),
        onWillPop: () async {
        return false;
      },
    );
  }

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

      List<GraceUser> patients = await userRepo.getAllPatientsWithMedications();

      for (String uid in _isCheckedMap.keys) {
        if (_isCheckedMap[uid] == true) {
          // Find the selected patient from the list of filtered patients
          GraceUser selectedPatient = patients.firstWhere((patient) => patient.id == uid);

          // Create a map representation of the patient to be added to the user's collection
          Map<String, dynamic> patientData = {
            'id': selectedPatient.id,
            'email': selectedPatient.email,
            'name': selectedPatient.name,
            // Add other patient data you want to store
          };

          await userCollection.add(patientData);
          _isCheckedMap[uid] = false; // Set to false after adding the patient
        }
      }
      setState(() {
        // No need to modify _allPatients, as we only modify _selectedPatients now
      });
    }
  } catch (e) {
    print('Error adding patients: $e');
  }
}

 Stream<List<Map<String, dynamic>>> fetchSecondListData() {
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