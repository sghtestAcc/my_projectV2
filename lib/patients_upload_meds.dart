import 'package:flutter/material.dart';
import 'package:my_project/camera_home_patient.dart';
import 'package:my_project/navigation_drawer.dart';
import 'package:my_project/patient_home.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: PatientUploadMedsScreen(),
    ));

class PatientUploadMedsScreen extends StatefulWidget {
  const PatientUploadMedsScreen({Key? key});

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
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    'Upload Medications schedules',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quantity',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
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
                      decoration: InputDecoration(
                        hintText: '2 tabs/tablets',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Schedule',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
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
                      decoration: InputDecoration(
                        hintText: 'Morning After meal...',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Add',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: Text(
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
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/Grace-bg-new-edited.png',
                  ),
                  fit: BoxFit.contain)),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: formData,
        child: Container(
            padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
            child: Center(
              child: Column(children: [
                Text(
                  'New Patients Must',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  'upload your medication',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'These information would assist caregivers',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'in managing your medication effectively',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 20,
                ),

                //upload images button
                Container(
                  width: double
                      .infinity, // Set the width to expand to the available space
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your onPressed logic here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraHomeScreenPatient()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0CE25C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12), // Adjust the padding as needed
                      child: Text(
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

                SizedBox(
                  height: 20,
                ),

                //upload schdules button
                Container(
                  width: double
                      .infinity, // Set the width to expand to the available space
                  child: ElevatedButton(
                    onPressed: () {
                      addMedsScheduleModal(context);
                      // Add your onPressed logic here
                      //  Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0CE25C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12), // Adjust the padding as needed
                      child: Text(
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
                SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PatientHomeScreen(
                                loginType: loginType3.patientsHomeScreen)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0CE25C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
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

                SizedBox(
                  height: 20,
                ),
                Text(
                  'Medication Label:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    // controller: controller,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Your Medication Label... ",
                      border: InputBorder.none, // Set this to remove the border
                    ),
                  ),
                ),
                Text(
                  'Medication Quantity:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    // controller: controller,
                    enabled: false,
                    controller: medsQuantity,
                    decoration: InputDecoration(
                      hintText: "Your Medication Quantity...",
                      border: InputBorder.none, // Set this to remove the border
                    ),
                  ),
                ),
                Text(
                  'Medication Schedules:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    // controller: controller,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Your Medication Schedule...",
                      border: InputBorder.none, // Set this to remove the border
                    ),
                  ),
                ),

                Container(
                  width: double
                      .infinity, // Set the width to expand to the available space
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0CE25C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12), // Adjust the padding as needed
                      child: Text(
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
              ]),
            )),
      ),
    );
  }
}
