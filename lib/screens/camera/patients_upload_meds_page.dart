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

import '../../components/navigation_drawer_new.dart';

class PatientUploadMedsScreen extends StatefulWidget {
  final TextEditingController? imagetakenText;
  final List<XFile> imagetakenPills;
  // final XFile? image;
  const PatientUploadMedsScreen({
    Key? key, 
    this.imagetakenText, 
    this.imagetakenPills = const [],
  }): super(key: key);

  @override
  State<PatientUploadMedsScreen> createState() => _PatientUploadMedsScreenState();
}

XFile? imageFile2;

final _authRepo = Get.put(AuthenticationRepository());
final userRepo = Get.put(UserRepository());

class _PatientUploadMedsScreenState extends State<PatientUploadMedsScreen> {
  final currentEmail = _authRepo.firebaseUser.value?.email;
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController medsLabel = TextEditingController();
  final controller = Get.put(SelectPatientController());

  TextEditingController medsQuantity = TextEditingController();
  TextEditingController medsSchedule = TextEditingController();
  TextEditingController medicineInput = TextEditingController();
  TextEditingController medsScheduleInput = TextEditingController();

  var formDataQuestionsInput = GlobalKey<FormState>();
  var formDataQuestions = GlobalKey<FormState>();

  void convertText() {
    medsQuantity.text = medicineInput.text;
    medsSchedule.text = medsScheduleInput.text;
    Navigator.pop(context);
  }


  bool isMedicationQuantityValid(String text) {
  if (text.isEmpty|| text.isEmpty) {
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
  if (text.isEmpty|| text.isEmpty) {
    return false;
  }

  List<String> words = text.split(' ');

  if (words.length < 2) {
    return false;
  }
  return words[1].toLowerCase() == 'tabs' || words[1].toLowerCase() == 'tablets';
}

  void showAddMedsScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Form(
            key: formDataQuestionsInput,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.1,
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              // padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          medicineInput.clear();
                          medsScheduleInput.clear();
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          'assets/images/x-mark.png',
                          height: 28,
                          width: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Upload Medications schedules',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quantity',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      // Background color
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded border
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: TextFormField(
                      controller: medicineInput,
                      decoration: const InputDecoration(
                        hintText: '2 tabs',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Schedule',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      // Background color
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded border
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: TextFormField(
                      controller: medsScheduleInput,
                      decoration: const InputDecoration(
                        hintText: 'Morning/before meals',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corner radius
                        ),
                      ),
                      onPressed: () async {
                        //validation textfield of medicationQuantity if empty
                        if (medicineInput.text.isEmpty||medicineInput.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Medication Quantity is required.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7),
                          );
                          return;
                        } 
                        else if (!isMedicationQuantityValid(medicineInput.text)) {
                          Get.snackbar(
                            "Error",
                            "Medication Quantity is invalid.The first word should contain a number",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7),
                          );
                          return;
                        } else if (!doesSecondWordContainTablets(medicineInput.text)) {
                          Get.snackbar(
                            "Error",
                            "Second word should contain 'tabs' or 'tablets'.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                            colorText: Color(0xFFF6F3E7),
                          );
                          return;
                        } 
                        //validation textfield of medicationSchedule if empty
                        else if (medsScheduleInput.text.isEmpty|| medsScheduleInput.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Medication Schedule is required.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                            colorText: Color(0xFFF6F3E7),
                          );
                          return;
                        } 
                        else {
                          convertText();
                          medicineInput.clear();
                          medsScheduleInput.clear();
                        }

                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corner radius
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController1 = widget.imagetakenText ?? TextEditingController();
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
                      // height: MediaQuery.of(context).size.height/ 2,
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'New Patients Must',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'upload your medication',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'These information would assist caregivers',
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text(
                              'in managing your medication effectively',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //upload images button
                            SizedBox(
                              width: double
                                  .infinity, // Set the width to expand to the available space
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add your onPressed logic here
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
                                          12), // Adjust the padding as needed
                                  child: const Text(
                                    'Upload Images',
                                    style: TextStyle(
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
                                  .infinity, // Set the width to expand to the available space
                              child: ElevatedButton(
                                onPressed: () {
                                  showAddMedsScheduleModal(context);
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
                                          12), // Adjust the padding as needed
                                  child: const Text(
                                    'Upload Schedules',
                                    style: TextStyle(
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
                                            'Are you Sure?',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          content: Text(
                                            'This would take you to Home',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          actions: [
                                            MaterialButton(
                                              child: Text(
                                                'Confirm',
                                                style: TextStyle(
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
                                                'cancel',
                                                style: TextStyle(
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
                                  child: const Text(
                                    'Proceed to home',
                                    style: TextStyle(
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
                            const Text(
                              'Medication Label:',
                              style: TextStyle(
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
                                decoration: const InputDecoration(
                                  hintText: "Your Medication Label... ",
                                  border: InputBorder
                                      .none, // Set this to remove the border
                                ),
                              ),
                            ),
                            const Text(
                              'Medication Quantity:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                enabled: false,
                                controller: medsQuantity,
                                decoration: const InputDecoration(
                                  hintText: "Your Medication Quantity...",
                                  border: InputBorder
                                      .none, // Set this to remove the border
                                ),
                              ),
                            ),
                            const Text(
                              'Medication Schedules:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: TextFormField(
                                controller: medsSchedule,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                // controller: controller,
                                enabled: false,
                                decoration: const InputDecoration(
                                  hintText: "Your Medication Schedule...",
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
                                      "Error",
                                      "Please fill in the Medication Label.",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:Color(0xFF35365D).withOpacity(0.5),
                                      colorText: Color(0xFFF6F3E7),
                                    );
                                    return;
                                  } 
                                  // validation field of textmedicationQuantity if empty
                                  else if (medsQuantity.text == null ||
                                      medsQuantity.text.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Please fill in the Medication Quantity.",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:Color(0xFF35365D).withOpacity(0.5),
                                      colorText: Color(0xFFF6F3E7),
                                    );
                                    return;
                                  } 
                                   // validation field of textmedicationSchedule if empty
                                  else if (medsSchedule.text == null ||
                                      medsSchedule.text.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Please fill in the Medication Schedule.",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                                      colorText: Color(0xFFF6F3E7),
                                    );
                                    return;
                                  }
                                  if (formDataQuestions.currentState!.validate()) {
                                    await userRepo.createPatientMedications(
                                      textController1.text.trim(),
                                      widget.imagetakenPills,
                                      medsQuantity.text.trim(),
                                      medsSchedule.text.trim(),
                                    );
                                    textController1.clear();
                                    medsQuantity.clear();
                                    medsSchedule.clear();
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
                                  child: const Text(
                                    'Add Medications',
                                    style: TextStyle(
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