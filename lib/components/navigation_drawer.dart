import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/communications/patient/patients_prescriptions.dart';
import 'package:my_project/screens/communications/patient/patients_vocalization.dart';

import '../repos/authentication_repository.dart';
import '../screens/communications/bothusers/usersCameraScreen.dart';
import '../screens/communications/caregiver/caregiver_prescription.dart';
import '../screens/communications/caregiver/caregiver_vocalization_patient_view.dart';
import 'package:my_project/controllers/account_controller.dart';

class AppDrawerNavigation extends StatefulWidget {
  const AppDrawerNavigation({Key? key}) : super(key: key);

  @override
  State<AppDrawerNavigation> createState() => _AppDrawerNavigationState();
}

class _AppDrawerNavigationState extends State<AppDrawerNavigation> {
  late LoginType _currentLoginType;
  final accountController = Get.find<AccountController>();

  @override
  void initState() {
    super.initState();

    final accountController = Get.find<AccountController>();
    debugPrint(
        '🔥 Current loginType from controller: ${accountController.loginType}');

    _currentLoginType = accountController.loginType == LoginType.dualAccount
        ? LoginType.patient
        : accountController.loginType;

    debugPrint('🟢 Initial view mode: $_currentLoginType');
  }

  XFile? imageFile;
  bool textScanning = false;
  String scannedText = "";

  Future<String> pickImage({
    ImageSource? source,
  }) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage =
          await picker.pickImage(source: source!, imageQuality: 50);
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
      ],
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
    } else if (scannedText == '') {
      log('do nothing');
      return;
      // ignore: use_build_context_synchronously
      // log('do nothing');
      // return '';
    } else {
      log('do nothing');
    }
  }

  ListTile buildSwitchViewTile() {
    final newLoginType = accountController.loginType == LoginType.patient
        ? LoginType.caregiver
        : LoginType.patient;

    return ListTile(
      leading: const Icon(Icons.swap_horiz),
      iconColor: Colors.black,
      title: Text(
        'Switch to ${newLoginType == LoginType.patient ? 'Patient' : 'Caregiver'} View',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        accountController.loginType = newLoginType;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavigatorBar(
              loginType: newLoginType,
              actualAccountType: accountController.actualAccountType,
              selectedIndex: 0,
            ),
          ),
        );
      },
    );
  }

  String sourceLang = 'English';

  final languagePicker = TranslateLanguage.values
      .map(
        (e) => e.name.capitalize!,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return _currentLoginType == LoginType.patient
        ? Drawer(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppBar(
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(
                  color: Colors.black, // Set the desired color here
                ),
              ),
              if (accountController.actualAccountType == LoginType.dualAccount)
                buildSwitchViewTile(),
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
                          title: Text('Select Language'),
                          content: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButton(
                              hint: Text('English'),
                              value: sourceLang,
                              onChanged: (newValue) {
                                setState(() {
                                  sourceLang = newValue ?? '';
                                  // translateTextFunction(typedText);
                                });
                                Navigator.pop(context); // Close the dialog
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
                        builder: (context) => const PatientsPrescripScreen(),
                      ),
                    );
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/mic.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Vocalizations'),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PatientsVocalScreen(),
                      ),
                    );
                  }),
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
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  iconColor: Colors.black,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 0,
                        ),
                      ),
                    );
                  }),
              ListTile(
                  leading: const Icon(Icons.comment),
                  iconColor: Colors.black,
                  title: const Text('Communications'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 1,
                        ),
                      ),
                    );
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.person),
                  iconColor: Colors.black,
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 2,
                        ),
                      ),
                    );
                  }),
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
              if (accountController.actualAccountType == LoginType.dualAccount)
                buildSwitchViewTile(),
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
                          builder: (context) => const CaregiverPrescription()),
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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CaregiverPrescriptionViewPatient()),
                    );
                  }),
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
                  }),
              ListTile(
                  leading: const Icon(Icons.home),
                  iconColor: Colors.black,
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 0,
                        ),
                      ),
                    );
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.comment),
                  iconColor: Colors.black,
                  title: const Text('Communications'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 1,
                        ),
                      ),
                    );
                  } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.list),
                  iconColor: Colors.black,
                  title: const Text('Patients'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 2,
                        ),
                      ),
                    );
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.person),
                  iconColor: Colors.black,
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorBar(
                          loginType: _currentLoginType,
                          actualAccountType:
                              LoginType.dualAccount, // or widget.loginType
                          selectedIndex: 3,
                        ),
                      ),
                    );
                  }),
            ]),
          );
  }
}
