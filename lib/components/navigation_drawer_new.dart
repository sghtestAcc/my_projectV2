import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:my_project/screens/camera/camera_patient_pills_page.dart';

import '../repos/authentication_repository.dart';
import '../screens/camera/camera_patient_meds_page.dart';

class AppDrawerNavigationNew extends StatefulWidget {
  int selectedScreen = 0;
  AppDrawerNavigationNew({Key? key, this.selectedScreen = 0}) : super(key: key);

  @override
  State<AppDrawerNavigationNew> createState() => _AppDrawerNavigationNewState();
}

class _AppDrawerNavigationNewState extends State<AppDrawerNavigationNew> {

  String changedText = '';
  String sourceLang = 'English';
  final languagePicker = TranslateLanguage.values
  .map(
  (e) => e.name.capitalize!,
  )
  .toList(); 


   final Selectedscreens = [
    CameraHomePatientScreen(),
    CameraHomePatientPillScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Drawer(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppBar(
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(
                  color: Colors.black, // Set the desired color here
                ),
              ),
              ListTile(
                  leading: Image.asset(
                    'assets/images/logout.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    AuthenticationRepository.instance.logout();
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/world.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Change Language',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onTap: () {
                      showDialog(
                      context: context,
                  builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Container(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButton(
              hint: const Text('English'),
              value: sourceLang,
              onChanged: (newValue) {
                setState(() {
                  sourceLang = newValue!;
                  // translateTextFunction(typedText);
                });
                //  Navigator.pop(context); // Close the dialog
              },
              items: languagePicker.map((valueItem) {
                return DropdownMenuItem(
                  value: valueItem,
                  child: Text(valueItem),
                );
              }).toList(),
              
            ),
          ),
        );
      },
    );            
                  }),
            ]),
          );
  }
}