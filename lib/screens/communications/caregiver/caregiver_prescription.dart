import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/communications/caregiver/view_card.dart';
import 'package:my_project/screens/home/patient_card.dart';

import '../../../components/navigation.tab.dart';

class CaregiverPrescription extends StatefulWidget {
  const CaregiverPrescription({super.key});

  @override
  State<CaregiverPrescription> createState() => _CaregiverPrescriptionState();
}

class _CaregiverPrescriptionState extends State<CaregiverPrescription> {
  bool isDropdownOpen = false;
final userRepo = Get.put(UserRepository());
  @override
  Widget build(BuildContext context) {

     final controller = Get.put(SelectPatientController());
    String lol = '';
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
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(
          builder: (context) => 
          NavigatorBar(
          loginType: LoginType.caregiver),
          ));
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: const BoxDecoration(
              color: Color(0xFF9EE8BF), // Background color/ Rounded border
            ),
            child:
              SizedBox(
                height: 300,
                child: FutureBuilder<List<GraceUser>>(
                    future: userRepo.getAllPatientsWithMedications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          List<GraceUser> patients = snapshot.data!;
                          // Apply search filter
                          List<GraceUser> filteredPatients =
                              patients.where((patient) {
                            String email = patient.email ?? '';
                            String name = patient.name ?? '';
                            return email
                                    .toLowerCase()
                                    .contains(lol.toLowerCase()) ||
                                name.toLowerCase().contains(lol.toLowerCase());
                          }).toList();
                          return ListView.separated(
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
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    color: Color(0xDDF6F6F6),
                                     border: Border.all(
                                       color: Colors.black.withOpacity(0.5),
                                      width: 1,
                                    ),
                                    boxShadow: const [
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
                                       myCardPrescription(index,uid,email),
                                        // patientcard(index,uid),
                                    ],
                                  ),
                                );
                              });
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
                  ),
              ),
            //     Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //   const Text(
            //     'Patient',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            //   const SizedBox(
            //     height: 10,
            //   ),
            //   const Text(
            //     'Medications',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            //   const SizedBox(
            //     height: 10,
            //   ),
            //   Container(
            //     padding: const EdgeInsets.all(20.0),
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       color: const Color(0xFFF6F6F6), // Background color
            //       borderRadius: BorderRadius.circular(10.0), // Rounded border
            //       border: Border.all(
            //         color: Colors.black,
            //         width: 1.0,
            //       ),
            //     ),
            //     child: const Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('PatientName 1'),
            //           SizedBox(
            //             height: 5,
            //           ),
            //           Text('Patient1@gmail.com'),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           Text('Feed Medication 1 during the Morning, after meals'),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           Text('Feed Medication 2 during the Morning, after meals'),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           Text('Feed Medication 3 during the Morning, after meals'),
            //         ]),
            //   )
            // ]),
          ),



          Container(
            width: double.infinity,
            // padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF6F6F6), // Background color // Rounded border
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Patient info Medication List',
                  style: TextStyle(fontSize: 20),
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<List<GraceUser>>(
          future: userRepo.getAllPatientsWithMedications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        List<GraceUser> patients = snapshot.data!;
                        // Apply search filter
                        List<GraceUser> filteredPatients =
                            patients.where((patient) {
                          String email = patient.email ?? '';
                          String name = patient.name ?? '';
                          return email
                                  .toLowerCase()
                                  .contains(lol.toLowerCase()) ||
                              name.toLowerCase().contains(lol.toLowerCase());
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
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      color: Color(0xDDF6F6F6),
                                       border: Border.all(
                                         color: Colors.black.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: const [
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
                                         patientcard(index,uid),
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
      endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
    );
  }
}
