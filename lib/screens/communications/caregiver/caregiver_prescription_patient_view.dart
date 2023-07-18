import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';
import 'package:my_project/screens/communications/caregiver/caregiver_prescription.dart';
import 'package:my_project/screens/communications/caregiver/caregiver_vocal.dart';

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
 Widget buildCard(int index) => Container(
  padding: const EdgeInsets.all(12.0),
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
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient $index',
              style: const TextStyle(fontSize: 15),
            ),
            Text('phoneNumber $index', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      Row(
        children: [
          Text(
            'View More',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add your button onPressed functionality here
            },
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    ],
  ),
);

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
          Text(
            'View More',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          IconButton(
            onPressed: () {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CaregviersVocalScreen(patientUid: snapshot.data![index].id ?? '',))); 
              // Add your button onPressed functionality here
            },
            icon: Icon(Icons.arrow_forward),
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


//  Expanded(
//             child: FutureBuilder<List<String>>(
//             future: userRepo.getQuestionsofCaregiver(currentEmail!),
//             builder: (context, snapshot) {
//               if(snapshot.connectionState == ConnectionState.done) {
//                 // var patientInfo2 = snapshot.data;
//                 if(snapshot.hasData) {
//                   return ListView.separated(
//                     padding: const EdgeInsets.all(10.0),
//                     itemCount: snapshot.data!.length,
//                     separatorBuilder: (context, index) {
//                       return const SizedBox(
//                   height: 15,
//                 );
//                     },
//                     itemBuilder: (context, i) {
//                         return Container(
//         padding: const EdgeInsets.all(10.0),
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(22)),
//           color: Color(0xFFF6F6F6),
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromRGBO(0, 0, 0, 0.2),
//               offset: Offset(0, 1),
//               blurRadius: 4,
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SelectableText(
//               snapshot.data![i],
//               // patientInfo2[index].Question,
//               style: const TextStyle(fontSize: 20),
//             ),
//             IconButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: snapshot.data![i],)).then(
//                   (_) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Copied to your clipboard !'),
//                       ),
//                     );
//                   },
//                 );
//               },
//               icon: const Icon(Icons.copy),
//             ),
//           ],
//         ),
//       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                         return Center(child: Text(snapshot.error.toString()));
//               } else {
//                         return const Center(
//                             child: Text('Something went wrong'));
//                       }
//               }
//               else {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//             } 
//             )
//           )