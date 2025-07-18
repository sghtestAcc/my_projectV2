import 'package:flutter/material.dart';
import 'package:my_project/screens/communications/communications_page.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/home.dart';
import 'package:my_project/screens/patients/select_patients.dart';
import 'package:my_project/screens/profile/profile_page.dart';

class NavigatorBar extends StatefulWidget {
  final LoginType loginType; // Selected by user on login (e.g., caregiver)
  final LoginType actualAccountType; // From Firestore (can be dualAccount)
  int selectedIndex;

  NavigatorBar({
    Key? key,
    required this.loginType,
    required this.actualAccountType,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  late LoginType _currentLoginType;

  @override
  void initState() {
    super.initState();
    _currentLoginType = widget.loginType; // Start with user's selected role
  }

  List<BottomNavigationBarItem> get bottomNavItems {
    if (_currentLoginType == LoginType.caregiver) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.comment),
          label: 'Communications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
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
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = _currentLoginType == LoginType.caregiver
        ? [
            PatientHomeScreen(
  loginType: _currentLoginType,
  actualAccountType: widget.actualAccountType,
),

            CommunicationsScreen(loginType: _currentLoginType),
            SelectPatientScreen(),
            MyProfile(loginType: _currentLoginType),
          ]
        : [
            PatientHomeScreen(
  loginType: _currentLoginType,
  actualAccountType: widget.actualAccountType,
),

            CommunicationsScreen(loginType: _currentLoginType),
            MyProfile(loginType: _currentLoginType),
          ];

    return Scaffold(
      appBar: null, 
      body: screens[widget.selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: _currentLoginType == LoginType.caregiver
              ? const Color(0xff1CA77A)
              : const Color(0xff0CE25C),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: widget.selectedIndex,
          onTap: (index) {
            setState(() {
              widget.selectedIndex = index;
            });
          },
          items: bottomNavItems,
        ),
      ),
    );
  }
}
