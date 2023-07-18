import 'package:flutter/material.dart';
import 'package:my_project/screens/communications/communications_patient.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/patient_home.dart';
import 'package:my_project/screens/patients/select_patients.dart';

class NavigatorBar extends StatefulWidget {
  // const NavigatorBar({super.key});

  final LoginType loginType;
  const NavigatorBar({Key? key, required this.loginType}) : super(key: key);
  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  int selectedIndex = 0;

  final screens = [
     PatientHomeScreen(
      loginType: LoginType.patient),
     CommunicationsScreen(
      loginType: LoginType.patient,
    ),
    // RegisterScreen(registerType: LoginType2.caregiversRegister
  ];

  final screens2 = [
     PatientHomeScreen(
      loginType: LoginType.caregiver),
     CommunicationsScreen(
      loginType: LoginType.caregiver,
    ),
    SelectPatientScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return widget.loginType == LoginType.patient
        ? Scaffold(

            body: screens[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor:Color(0xff0CE25C),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.comment), label: 'Communications'),
                //  BottomNavigationBarItem(
                //     icon: Icon(Icons.comment), label: 'Communications'),
              ],
            ),
          )
        : Scaffold(
            body: screens2[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor:Color(0xff1CA77A),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.comment),
                  label: 'Communications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Patients',
                ),
              ],
            ),
          );
  }
}
