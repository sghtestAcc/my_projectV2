import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/camera/Add_questions_modal.dart';
import 'package:my_project/screens/camera/camera_home_patient.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/patient_home.dart';

class PatientUploadMedsScreen extends StatefulWidget {
  // final XFile? image;
  const PatientUploadMedsScreen({Key? key,this.imagetakenText,this.imagetakenPill}) : super(key: key);

  final TextEditingController? imagetakenText;
  final XFile? imagetakenPill;

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

  void convertText()  {
      medsQuantity.text = medicineInput.text;
      medsSchedule.text = medsScheduleInput.text;
}




    void showAddMedsScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Form(
          key: formDataQuestionsInput,
          child: Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
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
                      icon: Image.asset('assets/images/x-mark.png', height: 28, width: 28, fit: BoxFit.contain,),
                    ),
                  ],
                ),
                const Text(
                  'Upload Medications schedules',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Get.snackbar(
                          "Error",
                          "Please fill in Medication Quantity.",
                          // const Color(0xFF0CE25C)#35365D
                          snackPosition: SnackPosition.TOP,
                          //  backgroundColor: Colors.redAccent.withOpacity(0.1),
                          // colorText: Colors.red,
                          backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                          // colorText: Colors.white,
                          colorText: Color(0xFFF6F3E7),
                      );
                      return null;
                    }
                          return null;
                        },
                        controller: medicineInput,
                        decoration: const InputDecoration(
                          hintText: '2 tabs...',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Get.snackbar(
                          "Error",
                          "Please fill in Medication Schedule.",
                          // const Color(0xFF0CE25C)#35365D
                          snackPosition: SnackPosition.TOP,
                          //  backgroundColor: Colors.redAccent.withOpacity(0.1),
                          // colorText: Colors.red,
                          backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                          // colorText: Colors.white,
                          colorText: Color(0xFFF6F3E7),
                      );
                      return null;
                    }
                          return null;
                        },
                        controller: medsScheduleInput,
                        decoration: const InputDecoration(
                          hintText: 'Morning After meal...',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
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
                      if (formDataQuestionsInput.currentState!.validate()) {
                        convertText();
                        medicineInput.clear();
                        medsScheduleInput.clear();
                        Navigator.pop(context);
                                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 
  @override
  Widget build(BuildContext context) {
      final textController1 = widget.imagetakenText ?? TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/Grace-bg-new-edited.png',
                  ),
                  fit: BoxFit.contain)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: formDataQuestions,
        child: FutureBuilder(
          future: controller.getPatientData(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'New Patients Must',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'upload your medication',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'These information would assist caregivers',
                      style: TextStyle(fontSize: 15),
                    ),
                    const Text(
                      'in managing your medication effectively',
                      style: TextStyle(fontSize: 15),
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
                              vertical: 12), // Adjust the padding as needed
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
                              vertical: 12), // Adjust the padding as needed
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
                                // Color(0xFF35365D).withOpacity(0.3),
                                backgroundColor: Color(0xFF35365D),
                                shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                      ),
                                title: Text('Are you Sure?', style: TextStyle(color: Colors.white),),
                                content: Text('This would take you to Home', style: TextStyle(color: Colors.white), ),
                                actions: [
                                  MaterialButton(
                                  child: Text('Confirm', style: TextStyle(color: Colors.white),),
                                  onPressed: () async {
                                    await AuthenticationRepository.instance.MedicationChecksDoubleLayer(currentUid);
                                    // Navigator.push(
                                    //  context,
                                    //  MaterialPageRoute(
                                    //  builder: (context) => const NavigatorBar(
                                    //  loginType: LoginType.patient,
                                    //  ),
                                    //  ),
                                    // ); 
                                  },
                                  ),
                                   MaterialButton(onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('cancel', style: TextStyle(color: Colors.white),),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          border: InputBorder.none, // Set this to remove the border
                        ),
                      ),
                    ),
                    const Text(
                      'Medication Quantity:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextFormField(
                        validator: (value) {
                            if (value == null || value.isEmpty) {
                          Get.snackbar(
                          "Error",
                          "Medication Quantity is required.",
                          // const Color(0xFF0CE25C)#35365D
                          snackPosition: SnackPosition.TOP,
                          //  backgroundColor: Colors.redAccent.withOpacity(0.1),
                          // colorText: Colors.red,
                          backgroundColor: Color(0xFF35365D).withOpacity(0.3),
                          // colorText: Colors.white,
                          colorText: Color(0xFFF6F3E7),
                      );
                      return null;
                    }
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        // controller: controller,
                        enabled: false,
                        controller: medsQuantity,
                        decoration: const InputDecoration(
                          hintText: "Your Medication Quantity...",
                          border: InputBorder.none, // Set this to remove the border
                        ),
                      ),
                    ),
                    const Text(
                      'Medication Schedules:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                              Get.snackbar(
                          "Error",
                          "Medication schedule is required.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          colorText: Colors.red,
                      );
                      return null;
                    }
                    return null;
                        },
                        controller: medsSchedule,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        // controller: controller,
                        enabled: false,
                        decoration: const InputDecoration(
                          hintText: "Your Medication Schedule...",
                          border: InputBorder.none, // Set this to remove the border
                        ),
                      ),
                    ),
        
                    SizedBox(
                      width: double.infinity, // Set the width to expand to the available space
                      child: ElevatedButton(
                        onPressed: () async {
                           if (formDataQuestions.currentState!.validate()) {
                            await userRepo.createPatientMedications(
                            textController1.text.trim(), 
                            widget.imagetakenPill, 
                            medsQuantity.text.trim(), 
                            medsSchedule.text.trim(), 
                            // currentEmail!,
                            // patientsInfo?.name
                            );
                            formDataQuestions.currentState?.reset();
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
          }
        ),
      ),
    );
  }
}

