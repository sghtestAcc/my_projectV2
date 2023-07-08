import 'package:flutter/material.dart';
import 'package:my_project/screens/camera/camera_home_patient.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/home/patient_home.dart';

class PatientUploadMedsScreen extends StatefulWidget {
  const PatientUploadMedsScreen({Key? key}) : super(key: key);

  @override
  State<PatientUploadMedsScreen> createState() =>
      _PatientUploadMedsScreenState();
}

class _PatientUploadMedsScreenState extends State<PatientUploadMedsScreen> {
  final email = TextEditingController();
  final fullName = TextEditingController();

  //  TextEditingController searchController = TextEditingController();
  TextEditingController medsQuantity = TextEditingController();
  TextEditingController medsSchedule = TextEditingController();

  var formData = GlobalKey<FormState>();

  void addMedsScheduleModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle the close button action here
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Text(
                    'Upload Medications schedules',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
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
                      controller: medsQuantity,
                      decoration: const InputDecoration(
                        hintText: '2 tabs/tablets',
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
                      decoration: const InputDecoration(
                        hintText: 'Morning After meal...',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Add',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
        key: formData,
        child: Container(
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
                                  const CameraHomeScreenPatient()));
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

                //upload schdules button
                SizedBox(
                  width: double
                      .infinity, // Set the width to expand to the available space
                  child: ElevatedButton(
                    onPressed: () {
                      addMedsScheduleModal(context);
                      // Add your onPressed logic here
                      //  Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientHomeScreen(
                            loginType: LoginType.patient,
                          ),
                        ),
                      );
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
                        'Proceed to homepage',
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
                    // controller: controller,
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
                  width: double
                      .infinity, // Set the width to expand to the available space
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
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
        ),
      ),
    );
  }
}
