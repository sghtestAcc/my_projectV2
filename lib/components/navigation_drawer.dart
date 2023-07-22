import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/communications/patient/patients_prescriptions.dart';
import 'package:my_project/screens/communications/patient/patients_vocalization.dart';

import '../repos/authentication_repository.dart';
import '../screens/communications/bothusers/usersCameraScreen.dart';
import '../screens/communications/caregiver/caregiver_prescription.dart';
import '../screens/communications/caregiver/caregiver_prescription_patient_view.dart';

class AppDrawerNavigation extends StatefulWidget {
  final LoginType loginType;

  // const AppDrawerNavigation({super.key});

  const AppDrawerNavigation({Key? key, required this.loginType}): super(key: key);

  @override
  State<AppDrawerNavigation> createState() => _AppDrawerNavigationState();
}

class _AppDrawerNavigationState extends State<AppDrawerNavigation> {
  
  XFile? imageFile;
  bool textScanning = false;
  String scannedText = "";

    Future<String> pickImage({ImageSource? source,}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage = await picker.pickImage(source: source!,imageQuality: 50);
      if (getImage != null) {
        path = '';
        textScanning = true;
        imageFile = getImage;
        path = getImage.path;
        setState(() {});
        // getRecognisedText(getImage);
      } else {
        path = '';
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
      log(e.toString());
    }
    return path;
  }

    Future<void> imageCropperView(String? path, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path!,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio16x9
      ] ,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'photoScanner cropped images',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'photoScanner cropped images',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      log('image cropped');
      imageFile = XFile(croppedFile.path);
      // return croppedFile.path;
      // ignore: use_build_context_synchronously
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) =>
      RecognizePageBothUsers(path: croppedFile.path)));
      // return XFile(croppedFile.path ?? );
      // getRecognisedText(imageFile!);
      // });
    } else if(scannedText == '') {
      log('do nothing');
      return;
      // ignore: use_build_context_synchronously
      // log('do nothing');
          // return '';
    } else {
      log('do nothing');
    }
  } 

  @override  
  Widget build(BuildContext context) {
    return widget.loginType == LoginType.patient
        ? Drawer(
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
                    // Navigator.of(context).pushReplacementNamed(WeatherScreen.routeName);
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/drugs.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Prescriptions'),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                    builder: (context) => PatientsPrescripScreen(),
                    ),
                    );
                  }
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/mic.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Vocalizations'),
                  onTap:
                      () {
                        Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                    builder: (context) => PatientsVocalScreen(),
                    ),
                    );
                      } 
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/photo-camera.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('PhotoScanner'),
                  onTap: () async {
                  await pickImage(source: ImageSource.gallery).then((value) {
                  if (value != '') {
                  imageCropperView(value, context);
                  }
                  });
                  }
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
               ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  iconColor: Colors.black,
                  onTap:
                      () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => NavigatorBar(loginType: widget.loginType, selectedIndex: 0,),
                      ),
                  );
                      }
                  ),
              ListTile(
                  leading: const Icon(Icons.comment),
                  iconColor: Colors.black,
                  title: const Text('Communications'),
                  onTap:
                      () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => NavigatorBar(loginType: widget.loginType, selectedIndex: 1,),
                      ),
                  );
                      }
                  ),
              //  Divider(height: 3, color: Colors.blueGrey),
              //  ListTile(
              //   leading: Icon(Icons.logout),
              //   title: Text('Patients'),
              //   onTap: () {

              //   } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
              // ),
            ]),
          )
        : Drawer(
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
                    // Navigator.of(context).pushReplacementNamed(WeatherScreen.routeName);
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/drugs.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Prescriptions'),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => CaregiverPrescription()
                      ),
                  );
                  }
                  // Navigator.of(context).pushReplacementNamed(GalleryScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/mic.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Vocalizations'),
                  onTap:
                      () {
                         Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => CaregiverPrescriptionViewPatient()
                      ),
                  );
                            
                      } 
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/photo-camera.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('PhotoScanner'),
                  onTap: () async {
                  await pickImage(source: ImageSource.gallery).then((value) {
                  if (value != '') {
                  imageCropperView(value, context);
                  }
                  });
                  }
                  ),
              ListTile(
                  leading: const Icon(Icons.home),
                  iconColor: Colors.black,
                  title: const Text('Home'),
                  onTap:
                      () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => NavigatorBar(loginType: widget.loginType, selectedIndex: 0,),
                      ),
                  );
                      }
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.comment),
                  iconColor: Colors.black,
                  title: const Text('Communications'),
                  onTap:
                      () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => NavigatorBar(loginType: widget.loginType, selectedIndex: 1,),
                      ),
                  );

                      } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.person),
                  iconColor: Colors.black,
                  title: const Text('Patients'),
                  onTap:
                      () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => NavigatorBar(loginType: widget.loginType, selectedIndex: 2,),
                      ),
                  );

                      } 
                  ),
            ]),
          );
  }
}
