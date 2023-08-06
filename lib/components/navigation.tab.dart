import 'package:flutter/material.dart';
import 'package:my_project/screens/communications/communications_screen.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/patient_home.dart';
import 'package:my_project/screens/patients/select_patients.dart';
import 'package:my_project/screens/profile/profile_page.dart';

class NavigatorBar extends StatefulWidget {

  final LoginType loginType;
  int selectedIndex = 0;
  NavigatorBar({Key? key, required this.loginType,  this.selectedIndex = 0}) : super(key: key);
  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  // int selectedIndex = 0;
  final screens = [
     PatientHomeScreen(
      loginType: LoginType.patient),
     CommunicationsScreen(
      loginType: LoginType.patient,
    ),
    MyProfile()
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
            body: screens[widget.selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor:Color(0xff0CE25C),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              currentIndex: widget.selectedIndex,
              onTap: (index) {
                setState(() {
                  widget.selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', ),
                BottomNavigationBarItem(
                icon: Icon(Icons.comment), label: 'Communications'),
                BottomNavigationBarItem(icon: Icon(Icons.person_2_sharp), label: 'Profile', ),
              ],
            ),
          )
        : Scaffold(
            body: screens2[widget.selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor:Color(0xff1CA77A),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              currentIndex: widget.selectedIndex,
              onTap: (index) {
                setState(() {
                  widget.selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.comment),
                  // assets/images/chat-box.png
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