import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/models/login_type.dart';

import '../../components/navigation_drawer.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _selectedPatients = [];
  List<Map<String, dynamic>> _successfullyAddedPatients = [];
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      await Firebase.initializeApp();
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('LoginType', isEqualTo: 'patient')
          .get();
      List<Map<String, dynamic>> patients =
          snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _allPatients = patients;
      });
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  Widget buildCard(Map<String, dynamic> patientData) {
    String patientName = patientData['Name'];
    String patientEmail = patientData['Email'];

    bool isPatientSelected = _selectedPatients.contains(patientData);

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
              patientName,
              style: const TextStyle(fontSize: 15),
            ),
            Text(
              patientEmail,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        value: isPatientSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value!) {
              _selectedPatients.add(patientData);
            } else {
              _selectedPatients.remove(patientData);
            }
          });
        },
        activeColor: const Color(0xFF0CE25C),
      ),
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

        List<Map<String, dynamic>> selectedPatientsCopy =
            List.from(_selectedPatients);

        for (Map<String, dynamic> patient in selectedPatientsCopy) {
          await userCollection.add(patient);
          _selectedPatients.remove(patient);
        }

        setState(() {
          // No need to modify _allPatients, as we only modify _selectedPatients now
        });
      }
    } catch (e) {
      print('Error adding patients: $e');
    }
  }

  Future<bool> addPatientToSecondList(Map<String, dynamic> patientData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUserId = user.uid;
        CollectionReference<Map<String, dynamic>> userCollection =
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('patients');

        await userCollection.add(patientData);
        return true;
      }
    } catch (e) {
      print('Error adding patient to the second list: $e');
    }
    return false;
  }

  void removePatientFromList(Map<String, dynamic> patientData) {
    setState(() {
      _allPatients.remove(patientData);
    });
  }

  Future<List<Map<String, dynamic>>> fetchSecondListData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUserId = user.uid;
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(currentUserId)
            .collection('patients')
            .get();

        return snapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print('Error fetching second list data: $e');
    }

    return [];
  }

  Widget buildSecondListCard(Map<String, dynamic> data) {
    String patientName = data['Name'];
    String patientEmail = data['Email'];

    return ListTile(
      title: Text(patientName),
      subtitle: Text(patientEmail),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: _allPatients.length,
              itemBuilder: (context, index) {
                final patientData = _allPatients[index];
                if (_successfullyAddedPatients.contains(patientData)) {
                  return SizedBox.shrink();
                } else {
                  return buildCard(patientData);
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: ElevatedButton(
              onPressed: () async {
                for (var patientData in _selectedPatients) {
                  bool added = await addPatientToSecondList(patientData);
                  if (added) {
                    // If the patient was successfully added to the second list,
                    // remove the patient from the first list (_allPatients).
                    removePatientFromList(patientData);
                    _successfullyAddedPatients.add(patientData);
                  }
                }
                _selectedPatients
                    .clear(); // Clear the selected patients list after adding them
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0CE25C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 40),
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchSecondListData().asStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<Map<String, dynamic>> secondListData = snapshot.data ?? [];

              if (secondListData.isEmpty) {
                return Center(child: Text('Patient List is Empty.'));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: secondListData.length,
                  itemBuilder: (context, index) {
                    return buildSecondListCard(secondListData[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
      endDrawer: const AppDrawerNavigation(
        loginType: LoginType.caregiver,
      ),
    );
  }
}