import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/camera/camera_patient_meds_page.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../components/navigation_drawer_new.dart';
import 'package:my_project/utils/tutorial_manager.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class PatientUploadMedsScreen extends StatefulWidget {
  final TextEditingController? imagetakenText;
  final List<XFile> imageFiles;
  final List<XFile> imageFilePills;
  final String? quantity;
  final String? dosage;
  final String? instructions;
  final String? details;
  // final XFile? image;
  const PatientUploadMedsScreen({
    Key? key,
    this.imagetakenText,
    this.imageFiles = const [],
    this.imageFilePills = const [],
    this.quantity,
    this.dosage,
    this.instructions,
    this.details,
  }) : super(key: key);

  @override
  State<PatientUploadMedsScreen> createState() =>
      _PatientUploadMedsScreenState();
}

XFile? imageFile2;

final _authRepo = Get.put(AuthenticationRepository());
final userRepo = Get.put(UserRepository());

class _PatientUploadMedsScreenState extends State<PatientUploadMedsScreen> {
  final currentEmail = _authRepo.firebaseUser.value?.email;
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController medsLabel = TextEditingController();
  final controller = Get.put(SelectPatientController());
  final GlobalKey keyUploadImageButton = GlobalKey();
  TextEditingController medicineInput = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  late TutorialManager tutorialManager;
  final GlobalKey keyuploadimg = GlobalKey();

  var formDataQuestionsInput = GlobalKey<FormState>();
  var formDataQuestions = GlobalKey<FormState>();

  bool isMedicationQuantityValid(String text) {
    if (text.isEmpty || text.isEmpty) {
      return false;
    }

    List<String> words = text.split(' ');
    if (words.isEmpty) {
      return false;
    }

    int? value = int.tryParse(words[0]);

    if (value == null || value < 1 || value > 100) {
      return false;
    }

    return true;
  }

  bool doesSecondWordContainTablets(String text) {
    if (text.isEmpty || text.isEmpty) {
      return false;
    }

    List<String> words = text.split(' ');

    if (words.length < 2) {
      return false;
    }
    return words[1].toLowerCase() == 'tabs' ||
        words[1].toLowerCase() == 'tablets';
  }

  void _maybeStartTutorial() async {
    final step = await getTutorialStep();

    if (step == 3) {
      final tutorialManager = TutorialManager(context);

      tutorialManager.targets = [
        TargetFocus(
          identify: "upload_button",
          keyTarget: keyuploadimg,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: const Text(
                "Tap here to upload Medication Images.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ];

      await Future.delayed(const Duration(milliseconds: 300));

      tutorialManager.showTutorial(
        onFinish: () async {
          await setTutorialStep(4); 
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraHomePatientScreen()),
          );
        },
      );
    }
  }

  // void showAddMedsScheduleModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return SingleChildScrollView(
  //         child: Form(
  //           key: formDataQuestionsInput,
  //           child: Container(
  //             height: MediaQuery.of(context).size.height / 1.1,
  //             padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
  //             // padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     IconButton(
  //                       onPressed: () {
  //                         medicineInput.clear();
  //                         Navigator.pop(context);
  //                       },
  //                       icon: Image.asset(
  //                         'assets/images/x-mark.png',
  //                         height: 28,
  //                         width: 28,
  //                         fit: BoxFit.contain,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 5,
  //                 ),
  //                 const Text(
  //                   'Upload Medications schedules',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 const Align(
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     'Quantity',
  //                     style:
  //                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     // Background color
  //                     borderRadius:
  //                         BorderRadius.circular(10.0), // Rounded border
  //                     border: Border.all(
  //                       color: Colors.black,
  //                       width: 1.0,
  //                     ),
  //                   ),
  //                   child: TextFormField(
  //                     controller: medicineInput,
  //                     decoration: const InputDecoration(
  //                       hintText: '2 tabs',
  //                       contentPadding: EdgeInsets.all(10.0),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF0CE25C), // NEW
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(
  //                           12,
  //                         ), // Rounded corner radius
  //                       ),
  //                     ),
  //                     onPressed: () async {
  //                       //validation textfield of medicationQuantity if empty
  //                       if (medicineInput.text.isEmpty||medicineInput.text.isEmpty) {
  //                         Get.snackbar(
  //                           "Error",
  //                           "Medication Quantity is required.",
  //                           snackPosition: SnackPosition.TOP,
  //                           backgroundColor: Color(0xFF35365D).withOpacity(0.5),
  //                           colorText: Color(0xFFF6F3E7),
  //                         );
  //                         return;
  //                       }
  //                       else if (!isMedicationQuantityValid(medicineInput.text)) {
  //                         Get.snackbar(
  //                           "Error",
  //                           "Medication Quantity is invalid.The first word should contain a number",
  //                           snackPosition: SnackPosition.TOP,
  //                           backgroundColor: Color(0xFF35365D).withOpacity(0.5),
  //                           colorText: Color(0xFFF6F3E7),
  //                         );
  //                         return;
  //                       } else if (!doesSecondWordContainTablets(medicineInput.text)) {
  //                         Get.snackbar(
  //                           "Error",
  //                           "Second word should contain 'tabs' or 'tablets'.",
  //                           snackPosition: SnackPosition.TOP,
  //                           backgroundColor: Color(0xFF35365D).withOpacity(0.5),
  //                           colorText: Color(0xFFF6F3E7),
  //                         );
  //                         return;
  //                       }
  //                     },
  //                     child: const Text(
  //                       'Add',
  //                       style: TextStyle(
  //                           fontSize: 20, fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF0CE25C), // NEW
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(
  //                           12,
  //                         ), // Rounded corner radius
  //                       ),
  //                     ),
  //                     onPressed: () {},
  //                     child: const Text(
  //                       'Close',
  //                       style: TextStyle(
  //                           fontSize: 20, fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _maybeStartTutorial();
  }

  @override
  Widget build(BuildContext context) {
    final textController1 = widget.imagetakenText ?? TextEditingController();
    final imageFiles = widget.imageFiles;
    final imageFilePills = widget.imageFilePills;
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/final-grace-background.png',
                    ),
                    fit: BoxFit.contain)),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1,
            child: Form(
              key: formDataQuestions,
              child: FutureBuilder(
                  future: controller.getPatientData(),
                  builder: (context, snapshot) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.newpatientmust,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .uploadyourmedication,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              AppLocalizations.of(context)!.hosyaku1,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              AppLocalizations.of(context)!.hosyaku2,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double
                                  .infinity, 
                              child: ElevatedButton(
                                key: keyuploadimg,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CameraHomePatientScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0CE25C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical:
                                          12), 
                                  child: Text(
                                    AppLocalizations.of(context)!.uploadimg,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            // Text(widget.imagetakenText ?? ''),
                            //upload schdules button
                            SizedBox(
                              width: double
                                  .infinity, 
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Color(0xFF35365D),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .confirmation,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .takehome,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          actions: [
                                            MaterialButton(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .confirm,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () async {
                                                await AuthenticationRepository
                                                    .instance
                                                    .MedicationChecksDoubleLayer(
                                                        currentUid, context);
                                              },
                                            ),
                                            MaterialButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .cancel,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0CE25C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    AppLocalizations.of(context)!.proceedtohome,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              AppLocalizations.of(context)!.medicationLabel,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                controller: textController1,
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .yourmedicationlabel,
                                  border: InputBorder
                                      .none, // Set this to remove the border
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double
                                  .infinity, // Set the width to expand to the available space
                              child: ElevatedButton(
                                onPressed: () async {
                                  // validation field of textmedicationlabel if empty
                                  if (textController1.text == null ||
                                      textController1.text.isEmpty) {
                                    Get.snackbar(
                                      AppLocalizations.of(context)!
                                          .snackbarInvalid,
                                      AppLocalizations.of(context)!
                                          .medicationlabelError,
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:
                                          Color(0xFF35365D).withOpacity(0.5),
                                      colorText: Color(0xFFF6F3E7),
                                    );
                                    return;
                                  }
                                  // validation field of textmedicationQuantity if empty
                                  if (formDataQuestions.currentState!
                                      .validate()) {
                                    print(
                                        'Packaging images count: ${widget.imageFiles.length}');
                                    print(
                                        'Pills images count: ${widget.imageFilePills.length}');

                                    await userRepo.createPatientMedications(
                                      context,
                                      textController1.text.trim(),
                                      widget.imageFiles,
                                      widget.imageFilePills,
                                      widget.quantity ?? '',
                                      widget.dosage ?? '',
                                      widget.instructions ?? '',
                                      details: widget.details,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0CE25C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ), // Adjust the padding as needed
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .addMedications,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
        endDrawer: AppDrawerNavigationNew(),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
