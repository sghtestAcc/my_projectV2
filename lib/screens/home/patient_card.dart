// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_project/controllers/select_patient_controller.dart';
// import 'package:my_project/models/grace_user.dart';
// import 'package:my_project/models/medications.dart';
// import 'package:my_project/screens/camera/patients_upload_meds.dart';

// class ViewPatientCard extends StatefulWidget {
//   final int index;

//   ViewPatientCard(this.index, {Key? key}) : super(key: key);

//   @override
//   State<ViewPatientCard> createState() => _ViewPatientCardState();
// }

// class _ViewPatientCardState extends State<ViewPatientCard> {
//   final controller = Get.put(SelectPatientController());
//   String lol = '';
//   bool isDropdownOpen = false;


//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<GraceUser>>(
//                   future: controller.getPatients(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       if (snapshot.hasData) {
//                         List<GraceUser> patients = snapshot.data!;
//                         // Apply search filter
//                         List<GraceUser> filteredPatients =
//                             patients.where((patient) {
//                           String email = patient.email ?? '';
//                           String name = patient.name ?? '';
//                           return email
//                                   .toLowerCase()
//                                   .contains(lol.toLowerCase()) ||
//                               name.toLowerCase().contains(lol.toLowerCase());
//                         }).toList();
//                         return Expanded(
//                             child: ListView.separated(
//                                 padding: const EdgeInsets.all(10.0),
//                                 shrinkWrap: true,
//                                 itemCount: filteredPatients.length,
//                                 separatorBuilder: (context, index) {
//                                   return const SizedBox(
//                                     height: 10,
//                                   );
//                                 },
//                                 itemBuilder: (context, index) {
//                                   GraceUser patient = filteredPatients[index];
//                                   String email = patient.email ?? '';
//                                   String name = patient.name ?? '';
//                                   return 
//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(
//                                         10, 10, 10, 0),
//                                     decoration: const BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(22)),
//                                       color: Color(0xDDF6F6F6),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Color.fromRGBO(0, 0, 0, 0.5),
//                                           offset: Offset(0, 1),
//                                           blurRadius: 4,
//                                           spreadRadius: 0,
//                                         ),
//                                       ],
//                                     ),
//                                     child: 
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           email,
//                                           style: TextStyle(fontSize: 15),
//                                         ),
//                                         Text(name),
//                                         Row(
//                                     children: [
//                                     const Text(
//                                     'View more for medication info',
//                                  style: TextStyle(fontSize: 10),
//                                ),
//                             IconButton(
//                             onPressed: () {
//                              setState(() {
//                               isDropdownOpen = !isDropdownOpen;
//                              });
//                            },
//                            icon: Icon(
//                              isDropdownOpen ? Icons.expand_less : Icons.expand_more),
//                          ),
//                           ],
//                        ),
//                       if (isDropdownOpen)    
//                        FutureBuilder<List<Medication>>(
//                         future: userRepo.getAllPatientsMedications(email),
//                         builder: (context,snapshot) {
//                         if(snapshot.connectionState == ConnectionState.done) {
//                         if(snapshot.hasData) {
//                         final childrenfields = <Widget>[];
//                         var patientsInfoMedicationAll = snapshot.data;
//                         for (var i = 0; i < patientsInfoMedicationAll!.length; i++) {
                          
//                              childrenfields.add(
//                               Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                               Container(
//                               decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12), // Adjust the value as needed for the desired roundness
//                               border: Border.all(color: Colors.black, width: 1), // Set the border color and width
//                             ),
//                               child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12), // Same value as the BoxDecoration for rounded corners
//                               child: Image.network(
//                               patientsInfoMedicationAll[i].pills ,
//                               height: 50,
//                               width: 50,
//                               fit: BoxFit.cover,
//                             ),
//                                              ),
//                                             ),
//                                 Text(patientsInfoMedicationAll[i].labels, 
//                                 style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text(patientsInfoMedicationAll[i].quantity, 
//                                 style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text(patientsInfoMedicationAll[i].schedule, 
//                                 style: TextStyle(fontSize: 15),
//                                 ),
//                                 SizedBox(height: 10,),
//                              ]),
//                              );
//                              childrenfields.add(SizedBox(height: 10,));
//                         }
//                           return Column(
//                           children: childrenfields,);
//                           } else if (snapshot.hasError) {
//                           return Center(child: Text(snapshot.error.toString()));
//                           } else {
//                           return const Center(
//                           child: Text('Something went wrong'));
//                           }
//                           } else {
//                           return const Center(child: CircularProgressIndicator());
//                           }
//                         },    
//                        ),
//                       //  viewpatientcard(index),
//                       //         if (isDropdownOpen)
//                       //         viewpatientcard(index)
//                       //                   Row(
//                       //                     children: [
//                       //                       viewpatientcard(index)
//                       //                     ],
//                       //                   ),
//                                       ],
//                                     ),
//                                   );
//                                 }));
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text(snapshot.error.toString()));
//                       } else {
//                         return const Center(
//                             child: Text('Something went wrong'));
//                       }
//                     } else {
//                       // return const Center(child: Text(''));
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                   },
//                 );
//   }
// }
