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
import '../../chatbot.dart';
import '../communications/bothusers/usersCameraScreen.dart';
import '../communications/caregiver/caregiver_vocalization_patient_view.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';
import '../communications/patient/edit_medications.dart';
import 'translated_image_dialog.dart';
import 'package:my_project/utils/gpt_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientHomeScreen extends StatefulWidget {
  final LoginType loginType;
  final LoginType actualAccountType;
  const PatientHomeScreen({
    Key? key,
    required this.loginType,
    required this.actualAccountType,
  }) : super(key: key);

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
  Map<String, bool> isExpandedMap = {};
  late LoginType _currentView;
  bool isDropdownOpen = false;
  XFile? imageFile;
  bool textScanning = false;
  String scannedText = "";
  @override
  void initState() {
    super.initState();
    _currentView = widget.loginType;
  }

  get totalQuantityController => null;

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
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RecognizePageBothUsers(path: croppedFile.path)));
    } else if (scannedText == '') {
      log('do nothing');
      return;
    } else {
      log('do nothing');
    }
  }

  @override
  void didUpdateWidget(PatientHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the view when loginType changes from parent
    if (oldWidget.loginType != widget.loginType) {
      setState(() {
        _currentView = widget.loginType;
      });
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
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _currentView == LoginType.patient
                    ? FutureBuilder(
                        future: controller.getPatientData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              var patientsInfo = snapshot.data;
                              final localizations =
                                  AppLocalizations.of(context);

                              Widget greetingSection;

                              if (localizations == null) {
                                greetingSection = Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .loadingTranslation),
                                );
                              } else {
                                greetingSection = Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.welcomeMessage(
                                          patientsInfo?.name ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      localizations.helpPrompt,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Image.asset(
                                      'assets/images/new-sgh-design.png'),
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
                                        child: greetingSection,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            } else {
                              return Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .smtwentwrong));
                            }
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      )
                    : Stack(
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
                              offset: Offset(0, 40),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                        future: controller.getPatientData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                AppLocalizations.of(context)!
                                                    .hiWelcomeUser(
                                                        snapshot.data?.name ??
                                                            ''),
                                                style: const TextStyle(
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
                                              return Center(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .smtwentwrong));
                                            }
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        }),
                                    Text(
                                      AppLocalizations.of(context)!.helpPrompt,
                                      style: const TextStyle(
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
                                              AppLocalizations.of(context)!
                                                  .searchPatient,
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
                _currentView == LoginType.patient
                    ? Container(
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
                                await pickImage(source: ImageSource.camera)
                                    .then((value) {
                                  if (value != '') {
                                    imageCropperView(value, context);
                                  }
                                });
                              },
                              child: Image.asset(
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
                                await pickImage(source: ImageSource.camera)
                                    .then((value) {
                                  if (value != '') {
                                    imageCropperView(value, context);
                                  }
                                });
                              },
                              child: Image.asset(
                                'assets/images/photo-camera.png',
                                height: 75,
                                width: 75,
                              ),
                            )
                          ],
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.prescriptions,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.of(context)!.vocalization,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.of(context)!.photoScanner,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0CE25C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientUploadMedsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.addMedications,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.medicationStatus,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
                _currentView == LoginType.patient
                    ? Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(10.0),
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
                                    return Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .smtwentwrong));
                                  }
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            FutureBuilder<List<Medication>>(
                                future: userRepo
                                    .displayPatientsMedications(currentUid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      var patientsInfoMedication =
                                          snapshot.data!;
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            patientsInfoMedication.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 16),
                                        itemBuilder: (context, i) {
                                          final med = patientsInfoMedication[i];
                                          final allImages = [
                                            ...med.packaging,
                                            ...med.pills
                                          ];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.green,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (allImages.isNotEmpty)
                                                  SizedBox(
                                                    height: 60,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          allImages.length,
                                                      itemBuilder:
                                                          (context, imgIdx) =>
                                                              Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  TranslatedImageDialog(
                                                                      imageUrl:
                                                                          allImages[
                                                                              imgIdx]),
                                                            );
                                                          },
                                                          child: Image.network(
                                                            allImages[imgIdx],
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Container(
                                                              height: 50,
                                                              width: 50,
                                                              color: Colors
                                                                  .grey[300],
                                                              child: Icon(Icons
                                                                  .image_not_supported),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(height: 8),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .medicationNameLabel(
                                                          med.labels),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                if (med.details != null &&
                                                    med.details!.isNotEmpty)
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style
                                                              .copyWith(
                                                                  fontSize: 16),
                                                      children: [
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .details,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        TextSpan(
                                                          text: med.details,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (med.quantity != null &&
                                                    med.quantity!.isNotEmpty)
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style
                                                              .copyWith(
                                                                  fontSize: 16),
                                                      children: [
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .quantity,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        TextSpan(
                                                          text: med.quantity,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (med.dosage != null &&
                                                    med.dosage!.isNotEmpty)
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style
                                                              .copyWith(
                                                                  fontSize: 16),
                                                      children: [
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .dosage,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        TextSpan(
                                                          text: med.dosage,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (med.instructions != null &&
                                                    med.instructions!
                                                        .isNotEmpty)
                                                  RichText(
                                                    text: TextSpan(
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style
                                                              .copyWith(
                                                                  fontSize: 16),
                                                      children: [
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .instructions,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              med.instructions,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.green),
                                                      tooltip:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .edit,
                                                      onPressed: () async {
                                                        final updated =
                                                            await Navigator
                                                                .push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditMedicationsPage(
                                                              medication: med,
                                                              uid: currentUid,
                                                            ),
                                                          ),
                                                        );
                                                        if (updated == true)
                                                          setState(() {});
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      tooltip:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .delete,
                                                      onPressed: () async {
                                                        final confirm =
                                                            await showDialog<
                                                                bool>(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .deleteMedication),
                                                            content: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .cmndeleteMed),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        false),
                                                                child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .cancel),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        true),
                                                                child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .delete,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (confirm == true) {
                                                          await userRepo
                                                              .deleteMedication(
                                                                  currentUid,
                                                                  med.id);
                                                          setState(
                                                              () {}); // Refresh the list
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text(snapshot.error.toString()));
                                    } else {
                                      return Center(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .smtwentwrong));
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ]),
                        ),
                      )
                    : FutureBuilder<List<GraceUser>>(
                        future: controller.getPatientsOfCurrentCaregiver(
                          controller.currentUser!.uid,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              List<GraceUser> patients = snapshot.data!;
                              debugPrint(
                                  "Fetched ${patients.length} patients under caregiver");

                              List<GraceUser> filteredPatients =
                                  patients.where((patient) {
                                String email = patient.email ?? '';
                                String name = patient.name ?? '';
                                return email.toLowerCase().contains(
                                        specificPatients.toLowerCase()) ||
                                    name.toLowerCase().contains(
                                        specificPatients.toLowerCase());
                              }).toList();

                              if (filteredPatients.isEmpty) {
                                return Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .noMatchingPatient));
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.all(10.0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPatients.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final patient = filteredPatients[index];
                                  final uid = patient.id ?? '';
                                  final email = patient.email ?? '';
                                  final name = patient.name ?? '';
                                  final isExpanded =
                                      isExpandedMap[uid] ?? false;

                                  debugPrint("Showing: $name <$email>");

                                  return Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(22)),
                                      color: const Color(0xDDF6F6F6),
                                      border: Border.all(
                                          color: Colors.green,
                                          width: 2), // Green border
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        FutureBuilder<List<Medication>>(
                                          future: userRepo
                                              .displayPatientsMedications(uid),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Text(
                                                  AppLocalizations.of(context)!
                                                      .noMedFound);
                                            }

                                            final meds = snapshot.data!;
                                            final summaryText =
                                                generateMedicationSummary(
                                                    name, meds);

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  summaryText,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .viewMeds,
                                                        style: const TextStyle(
                                                            fontSize: 10)),
                                                    IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isExpandedMap[uid] =
                                                              !isExpanded;
                                                        });
                                                      },
                                                      icon: Icon(isExpanded
                                                          ? Icons.expand_less
                                                          : Icons.expand_more),
                                                    ),
                                                  ],
                                                ),
                                                if (isExpanded)
                                                  Column(
                                                    children: meds.map((med) {
                                                      final allImages = [
                                                        ...med.packaging,
                                                        ...med.pills
                                                      ];
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black12,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (allImages
                                                                .isNotEmpty)
                                                              SizedBox(
                                                                height: 60,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount:
                                                                      allImages
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              imgIdx) =>
                                                                          Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (_) =>
                                                                              TranslatedImageDialog(
                                                                            imageUrl:
                                                                                allImages[imgIdx],
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Image
                                                                          .network(
                                                                        allImages[
                                                                            imgIdx],
                                                                        height:
                                                                            50,
                                                                        width:
                                                                            50,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) =>
                                                                            Container(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              50,
                                                                          color:
                                                                              Colors.grey[300],
                                                                          child:
                                                                              const Icon(Icons.image_not_supported),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .medicationNameLabel(
                                                                      med.labels),
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            if (med.details
                                                                    ?.isNotEmpty ==
                                                                true)
                                                              Text(AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .medicationDetailsLabel(
                                                                      med.details!)),
                                                            if (med.quantity
                                                                    ?.isNotEmpty ==
                                                                true)
                                                              Text(AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .medicationQuantityLabel(
                                                                      med.quantity!)),
                                                            if (med.dosage
                                                                    ?.isNotEmpty ==
                                                                true)
                                                              Text(AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .medicationDosageLabel(
                                                                      med.dosage!)),
                                                            if (med.instructions
                                                                    ?.isNotEmpty ==
                                                                true)
                                                              Text(AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .medicationInstructionsLabel(
                                                                      med.instructions!)),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              debugPrint("Error: ${snapshot.error}");
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .errorMessage(snapshot.error.toString()),
                                ),
                              );
                            } else {
                              return Center(
                                child: Text(AppLocalizations.of(context)!
                                    .somethingWentWrong),
                              );
                            }
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await userRepo.testRefillNotification();
                  },
                  child: Text(
                    "Test Refill Notification",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        endDrawer: const AppDrawerNavigation(),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()));
          },
          backgroundColor: const Color(0xFF0CE25C),
          child: const Icon(Icons.chat, color: Colors.white),
          shape: const CircleBorder(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
