import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/communications/caregiver/caregiver_prescription.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/screens/communications/patient/patients_prescriptions.dart';
import 'package:my_project/screens/communications/patient/patients_vocalization.dart';
import 'package:my_project/screens/home/patient_card.dart';
import '../communications/bothusers/usersCameraScreen.dart';
import '../communications/caregiver/caregiver_vocalization_patient_view.dart';

class PatientHomeScreen extends StatefulWidget {
  final LoginType loginType;
  const PatientHomeScreen({Key? key, required this.loginType})
      : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

final _authRepo = Get.put(AuthenticationRepository());
final userRepo = Get.put(UserRepository());

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final currentEmail = _authRepo.firebaseUser.value?.email;
  String currentUid = FirebaseAuth.instance.currentUser!.uid;
  String specificPatients = '';
  TextEditingController searchController = TextEditingController();
  final controller = Get.put(SelectPatientController());

  bool isDropdownOpen = false;
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
      // ignore: use_build_context_synchronously
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) =>
      RecognizePageBothUsers(path: croppedFile.path)));
    } else if(scannedText == '') {
      log('do nothing');
      return;
    } else {
      log('do nothing');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height/ 0.8,
            child: Column(
              children: [
                widget.loginType == LoginType.patient
                    ? FutureBuilder(
                        future: controller.getPatientData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              var patientsInfo = snapshot.data;
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Image.asset('assets/images/new-sgh-design.png'),
                                  Image.asset(
                                    'assets/images/final-grace-background.png',
                                    height: 125,
                                    width: 125,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Hi welcome ${patientsInfo?.name}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              'How can I help you today?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Center(child: Text(snapshot.error.toString()));
                            } else {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    :  Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Image.asset(
                            'assets/images/new-sgh-design.png',
                          ),
                          Image.asset(
                            'assets/images/final-grace-background.png',
                            height: 125,
                            width: 125,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(0,
                                  40), // Adjust the vertical offset to move the TextField downward
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .end, // Align the content to the end (bottom)
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                        future: controller.getPatientData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                "Hi Welcome ${snapshot.data?.name}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              print("Error: ${snapshot.error}");
                                              return Center(
                                                  child: Text(snapshot.error
                                                      .toString()));
                                            } else {
                                              return const Center(
                                                  child: Text(
                                                      'Something went wrong'));
                                            }
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        }),
                                    Text(
                                      'How can I help you today?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18)),
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.search),
                                          hintText:
                                              'Quick search a patient here',
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            specificPatients = val;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                widget.loginType == LoginType.patient
                    ?  Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PatientsPrescripScreen()));
                                },
                                child: Image.asset(
                                  'assets/images/drugs.png',
                                  height: 75,
                                  width: 75,
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PatientsVocalScreen()));
                                  },
                                  child: Image.asset(
                                    'assets/images/mic.png',
                                    height: 75,
                                    width: 75,
                                  )),
                
                              GestureDetector(
                                onTap: () async {
                               await pickImage(source: ImageSource.camera).then((value) {
                                if (value != '') {
                                imageCropperView(value, context);
                               }
                               });
                               },
                                child:  Image.asset(
                                'assets/images/photo-camera.png',
                                height: 75,
                                width: 75,
                              ),
                              )
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.fromLTRB(0, 35, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CaregiverPrescription()));
                                },
                                child: Image.asset(
                                  'assets/images/drugs.png',
                                  height: 75,
                                  width: 75,
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CaregiverPrescriptionViewPatient()));
                                  },
                                  child: Image.asset(
                                    'assets/images/mic.png',
                                    height: 75,
                                    width: 75,
                                  )),
                              GestureDetector(
                                onTap: () async {
                               await pickImage(source: ImageSource.camera).then((value) {
                                if (value != '') {
                                imageCropperView(value, context);
                               }
                               });
                               } ,
                                child:  Image.asset(
                                'assets/images/photo-camera.png',
                                height: 75,
                                width: 75,
                              ),
                              )
                            ],
                          ),
                        ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Prescriptions',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Vocalization',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'PhotoScanner',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Medication Status',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
                widget.loginType == LoginType.patient
                    ?
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6), // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded border
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          child: Column(children: [
                            FutureBuilder(
                              future: controller.getPatientData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    var patientsInfo = snapshot.data;
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${patientsInfo?.name}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const Text(
                                              'Quantity',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            const Text(
                                              'Schedule',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${patientsInfo?.email}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(snapshot.error.toString()));
                                  } else {
                                    return const Center(
                                        child: Text('Something went wrong'));
                                  }
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            FutureBuilder<List<Medication>>(
                                future: userRepo.displayPatientsMedications(currentUid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      var patientsInfoMedication = snapshot.data;
                                      final children = <Widget>[];
                                      for (var i = 0;
                                          i < patientsInfoMedication!.length;
                                          i++) {
                                        children.add(
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(
                                                        12), // Adjust the value as needed for the desired roundness
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width:
                                                            1), // Set the border color and width
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(
                                                        12), // Same value as the BoxDecoration for rounded corners
                                                    child: Image.network(
                                                      patientsInfoMedication[i].pills,
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  patientsInfoMedication[i].labels,
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  patientsInfoMedication[i].quantity,
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  patientsInfoMedication[i].schedule,
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ]),
                                        );
                                        children.add(SizedBox(
                                          height: 10,
                                        ));
                                      }
                                      return Column(
                                        children: children,
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text(snapshot.error.toString()));
                                    } else {
                                      return const Center(
                                          child: Text('Something went wrong'));
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ]),
                        ),
                      )
                    :
                    FutureBuilder<List<GraceUser>>(
                        future: controller.getPatients(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {

                              List<GraceUser> patients = snapshot.data!;
                              // Apply search filter of patients with meds/no meds
                              List<GraceUser> filteredPatients = patients.where((patient) {
                                String email = patient.email ?? '';
                                String name = patient.name ?? '';
                                return email
                                        .toLowerCase()
                                        .contains(specificPatients.toLowerCase()) ||
                                    name.toLowerCase().contains(specificPatients.toLowerCase());
                              }).toList();
                              return Expanded(
                                  child: ListView.separated(
                                      padding: const EdgeInsets.all(10.0),
                                      shrinkWrap: true,
                                      itemCount: filteredPatients.length,
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(
                                          height: 10,
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        GraceUser patient = filteredPatients[index];
                                        String uid = patient.id ?? '';
                                        String email = patient.email ?? '';
                                        String name = patient.name ?? '';
                                        return 
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          decoration: const BoxDecoration(
                                            borderRadius:
                                                BorderRadius.all(Radius.circular(22)),
                                            color: Color(0xDDF6F6F6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                                offset: Offset(0, 1),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                email,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              Text(name),
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
                                                        isDropdownOpen =
                                                            !isDropdownOpen;
                                                      });
                                                    },
                                                    icon: Icon(isDropdownOpen
                                                        ? Icons.expand_less
                                                        : Icons.expand_more),
                                                  ),
                                                ],
                                              ),
                                               caregiverPatientCardView(index,uid),
                                            ],
                                          ),
                                        );
                                      }));
                            } else if (snapshot.hasError) {
                              return Center(child: Text(snapshot.error.toString()));
                            } else {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }
                          } else {
                            // return const Center(child: Text(''));
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      )
              ],
            ),
          ),
        ),
        endDrawer: AppDrawerNavigation(loginType: widget.loginType),
      ),
        onWillPop: () async {
        return false;
      },
    );
  }
}
