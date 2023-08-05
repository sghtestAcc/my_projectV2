import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/screens/home/patient_home.dart';

import '../../../repos/authentication_repository.dart';
import '../../../repos/user_repo.dart';

class PatientsPrescripScreen extends StatefulWidget {
  const PatientsPrescripScreen({super.key});

  @override
  State<PatientsPrescripScreen> createState() => _PatientsPrescripScreenState();
}

  final userRepo = Get.put(UserRepository());
  final _authRepo = Get.put(AuthenticationRepository());

class _PatientsPrescripScreenState extends State<PatientsPrescripScreen> {
  final currentEmail = _authRepo.firebaseUser.value?.email;
  final controller = Get.put(SelectPatientController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text(
          'Prescriptions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:  IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(
          builder: (context) => 
          NavigatorBar(
          loginType: LoginType.patient),
          ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height / 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 45),
                decoration: const BoxDecoration(
                  color: Color(0xFF9EE8BF), // Background color/ Rounded border
                ),
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                   const Text(
                    'Patient',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                   const SizedBox(
                    height: 10,
                  ),
                   const Text(
                    'Medications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                   const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF6F6F6), // Background color
                          borderRadius: BorderRadius.circular(10.0), // Rounded border
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: FutureBuilder(
                          future: controller.getPatientData(),
                          builder: (context, snapshot) {
                           if (snapshot.connectionState == ConnectionState.done) {
                              if(snapshot.hasData) {
                                 var patientsInfo = snapshot.data;
                                 return  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                       Text(
                                            "${patientsInfo?.name}",
                                            style: const TextStyle(
                                            fontSize: 15,
                                            ),
                                            ),
                                       Text(
                                            "${patientsInfo?.email}",
                                              style: const TextStyle(
                                               fontSize: 15,
                                              ),
                                      ),
                                      SizedBox(height: 10,),
                                       StreamBuilder<List<Medication>>(
                                  stream: userRepo.getPatientMedications(patientsInfo?.id),
                                  builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.done) {
                                  if(snapshot.hasData) {
                                  var patientsInfoMedication = snapshot.data;
                                  final children = <Widget>[];
                                  for (var i = 0; i < patientsInfoMedication!.length; i++) {
                                  children.add(
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text(
                                  'Feed ${patientsInfoMedication[i].labels} during the ${patientsInfoMedication[i].schedule}',
                                  style: TextStyle(fontSize: 15),
                                    ),
                                  SizedBox(height: 10,),
                                   ]),
                                  );
                                  children.add(SizedBox(height: 10,));
                                  }
                                  return Column(
                                  children: children,);
                                  } else if (snapshot.hasError) {
                                  return Center(child: Text(snapshot.error.toString()));
                                  } else {
                                  return const Center(
                                  child: Text('Something went wrong'));
                                  }
                                  }  else {
                                  return const Center(child: CircularProgressIndicator());
                                  }
                                  })
               
                                  ],
                                 );
                              } else if (snapshot.hasError) {
                                        return Center(child: Text(snapshot.error.toString()));
                              } else {
                                        return const Center(
                                            child: Text('Something went wrong'));
                                      }
                           }else  {
                                      return const Center(child: CircularProgressIndicator());
                            }
                          }
                        ),
                      ),
                    ],
                  )
                ]),
              ),
              Container(
                width: double.infinity,
                // padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color:
                       Color(0xFFF6F6F6), // Background color // Rounded border
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child: Container(
                    padding:  EdgeInsets.all(10.0),
                    child:  const Text(
                      'Patient info Medication List',
                      style: TextStyle(fontSize: 20),
                    )),
              ),
               const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color:const Color(0xFFF6F6F6), // Background color
                    borderRadius: BorderRadius.circular(10.0), // Rounded border
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  child:  
                  Column(
                    children: [
                       FutureBuilder(
                              future: controller.getPatientData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                   if (snapshot.hasData) {
                                    var patientsInfo = snapshot.data;
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Text(
                                            "${patientsInfo?.name}",
                                            style: const TextStyle(
                                            fontSize: 15,
                                            ),
                                            ),
                                            const Text(
                                           'Quantity',
                                            style: TextStyle(fontSize: 15),
                                            ),   
                                                  const Text(
                                              'Schedule',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                           ],
                                        ),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: [
                                             Text(
                                            "${patientsInfo?.email}",
                                            style: const TextStyle(
                                            fontSize: 15,
                                            ),
                                            ),
                                          ],
                                        ),
                                          const SizedBox(
                                           height: 20,
                                          ),
                                          StreamBuilder<List<Medication>>(
                          stream: userRepo.getPatientMedications(patientsInfo?.id),
                      builder: (context, snapshot) {
                         if(snapshot.connectionState == ConnectionState.done) {
                           if(snapshot.hasData) {
                              var patientsInfoMedication = snapshot.data;
                              final children = <Widget>[];
                              for (var i = 0; i < patientsInfoMedication!.length; i++) {
                                 children.add(
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Container(
                                  decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), // Adjust the value as needed for the desired roundness
                                  border: Border.all(color: Colors.black, width: 1), // Set the border color and width
                                ),
                                  child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12), // Same value as the BoxDecoration for rounded corners
                                  child: Image.network(
                                  patientsInfoMedication[i].pills ,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                                                 ),
                                                ),
                                    Text(patientsInfoMedication[i].labels, 
                                    style: TextStyle(fontSize: 15),
                                    ),
                                    Text(patientsInfoMedication[i].quantity, 
                                    style: TextStyle(fontSize: 15),
                                    ),
                                    Text(patientsInfoMedication[i].schedule, 
                                    style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(height: 10,),
                                 ]),
                                //  SizedBox(height: 10,),
                                 );
                                 children.add(SizedBox(height: 10,));
                              }
                                   return Column(
                                    children: children,);
                           } else if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()));
                  } else {
                     return const Center(
                                child: Text('Something went wrong'));
                  }
                         }  else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      }),
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
                              },),
                    const SizedBox(
                      height: 20,
                    ),
              
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      //  endDrawer: AppDrawerNavigation(loginType: widget.loginType),
      endDrawer: const AppDrawerNavigation(loginType: LoginType.patient),
    );
  }
}
