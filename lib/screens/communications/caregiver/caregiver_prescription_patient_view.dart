import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';
import 'package:my_project/screens/communications/caregiver/caregiver_prescription.dart';
import 'package:my_project/screens/communications/caregiver/caregiver_vocal.dart';

import '../../../components/navigation.tab.dart';
import '../../../repos/user_repo.dart';

class CaregiverPrescriptionViewPatient extends StatefulWidget {

  // final String? patientUid;
  
  const CaregiverPrescriptionViewPatient({super.key});

  @override
  State<CaregiverPrescriptionViewPatient> createState() => _CaregiverPrescriptionViewPatientState();
}

class _CaregiverPrescriptionViewPatientState extends State<CaregiverPrescriptionViewPatient> {
  final userRepo = Get.put(UserRepository());
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Vocalization',
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
      children: [
        Container(
          color: const Color(0xFF9EE8BF),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
          child: const Text(
            'Select Patient Medication To Translate',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

// getAllPatientsWithMedications
        FutureBuilder<List<GraceUser>>(
          future: userRepo.getAllPatientsWithMedications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if(snapshot.hasData) {
                return Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(10.0),
                shrinkWrap: true,  // Add shrinkWrap property
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (context, index) {
                  return Container(
  padding: const EdgeInsets.all(12.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(22)),
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
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot.data![index].name ?? '',
              style: const TextStyle(fontSize: 15),
            ),
            Text(snapshot.data![index].email ?? '', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      Row(
        children: [
          GestureDetector(
            child: Text(
            'View More',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ), 
          onTap: () {
             Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CaregviersVocalScreen(patientUid: snapshot.data![index].id ?? '',))); 
          }
          ),
          IconButton(
            onPressed: () {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CaregviersVocalScreen(patientUid: snapshot.data![index].id ?? '',))); 
              // Add your button onPressed functionality here
            },
            icon: Image.asset('assets/images/arrow-right.png'),
          ),
        ],
      ),
    ],
  ),
);
                },
              ),
            );
              } else if (snapshot.hasError) {
                          return Center(
                    child: Text(snapshot.error
              .toString()));
              } else {
                                                  return const Center(
                                                      child: Text(
                                                          'Something went wrong'));
              } 
            } else {
            return const Center(
                    child:
                     CircularProgressIndicator());
                                              }            
          }
        ),
        SizedBox(height: 20,),
      ],
    ),
    endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
  );
}
}