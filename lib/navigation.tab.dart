import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_project/communications_patient.dart';
import 'package:my_project/patient_home.dart';
import 'package:my_project/select_patients.dart';

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});
   
 

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  int selectedIndex = 0;

  final screens = [
    const PatientHomeScreen(),
    const CommunicationsScreen(),
    const SelectPatientScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.comment), label: 'Communications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Patients'),
        ],
      ),
    );
  }
}
