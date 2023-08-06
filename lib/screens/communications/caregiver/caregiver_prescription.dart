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
      body: SingleChildScrollView(
        child: Container(
        height: MediaQuery.of(context).size.height/ 1,
          child: Column(
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
                    child: 
                    StreamBuilder(
                      stream: userRepo.getAllPatientsWithMedications2(),
                      builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                      } else if (snapshot.hasData) {
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
                } else {
            return const Center(child: Text('Something went wrong'));
                }
                      }),
                    
                  ),
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
              StreamBuilder<List<GraceUser>>(
                stream: userRepo.getAllPatientsWithMedications2(),
                builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                 return Center(child: CircularProgressIndicator());
                }  else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData) {
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

                } else {
            return const Center(child: Text('Something went wrong'));
                }
                })
            ],
          ),
        ),
      ),
      endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
    );
  }
}
