import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/caregiver_prescription.dart';
import 'package:my_project/caregiver_vocal.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/patient_user.dart';
import 'package:my_project/models/select_patient_controller.dart';
import 'package:my_project/navigation_drawer.dart';
import 'package:my_project/patients_prescriptions.dart';
import 'package:my_project/patients_vocalization.dart';

class PatientHomeScreen extends StatefulWidget {
  final LoginType loginType;
  const PatientHomeScreen({Key? key, required this.loginType})
      : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  TextEditingController searchController = TextEditingController();
  final controller = Get.put(SelectPatientController());

  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    // bool isDropdownOpen = false;
    List<int> values = [
      2,
      4,
      6,
      8,
      10
    ]; // Replace with your actual list of values

    List<bool> isItemExpanded = List.filled(values.length, false);

    Widget buildCard(int index) => Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient $index',
                style: const TextStyle(fontSize: 15),
              ),
              Text('phoneNumber $index', style: const TextStyle(fontSize: 12)),
              Row(
                children: [
                  const Text(
                    'View more for medication info',
                    style: TextStyle(fontSize: 10),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDropdownOpen = !isDropdownOpen;
                      });
                    },
                    icon: Icon(
                        isDropdownOpen ? Icons.expand_less : Icons.expand_more),
                  ),
                ],
              ),
              if (isDropdownOpen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < values.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isItemExpanded[i] = !isItemExpanded[i];
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('1 $i',
                                    style: const TextStyle(fontSize: 12)),
                                Text('1 $i',
                                    style: const TextStyle(fontSize: 12)),
                                const Text('Morning',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isItemExpanded[i])
                            Padding(
                              padding: const EdgeInsets.only(
                                  left:
                                      20.0), // Adjust the indentation as needed
                              child: Text(
                                'Additional medication info for item $i',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        );

    return Scaffold(
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
      body: Column(
        children: [
          widget.loginType == LoginType.patient
              ? FutureBuilder(
                  future: controller.getPatientData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        PatientModel patientsInfo =
                            snapshot.data as PatientModel;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/new-sgh-design.png'),
                            Image.asset(
                              'assets/images/Grace-bg-new-edited.png',
                              height: 100,
                              width: 100,
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
                                        "Hi welcome ${patientsInfo.name}",
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
              : Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/images/new-sgh-design.png',
                  ),
                  Image.asset(
                    'assets/images/Grace-bg-new-edited.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hi Welcome Patient"),
                              // Text('Hi Welcome' + patientUser.Name!;, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                              Text(
                                'How can I help you today?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Quick search a patient here',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  )
                ]),
          widget.loginType == LoginType.patient
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
                          height: 90,
                          width: 90,
                        ),
                      ),
                      // PatientsVocalScreen
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
                            height: 90,
                            width: 90,
                          )),

                      Image.asset(
                        'assets/images/photo-camera.png',
                        height: 90,
                        width: 90,
                      ),
                    ],
                  ),
                )
              : Container(
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
                                      const CaregiverPrescription()));
                        },
                        child: Image.asset(
                          'assets/images/drugs.png',
                          height: 90,
                          width: 90,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CaregviersVocalScreen()));
                        },
                        child: Image.asset(
                          'assets/images/mic.png',
                          height: 90,
                          width: 90,
                        ),
                      ),
                      Image.asset(
                        'assets/images/photo-camera.png',
                        height: 90,
                        width: 90,
                      ),
                    ],
                  ),
                ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Prescriptions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Vocalization',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'PhotoScanner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    'Medication status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10.0),
              itemCount: 10,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemBuilder: (context, index) {
                return buildCard(index);
              },
            ),
          )
        ],
      ),
      endDrawer: widget.loginType == LoginType.patient
          ? const AppDrawerNavigation(loginType: LoginType5.patientsNavgation)
          : const AppDrawerNavigation(
              loginType: LoginType5.caregiversNavgation),
    );
  }
}
