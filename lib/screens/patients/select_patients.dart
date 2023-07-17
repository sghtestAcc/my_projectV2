import 'package:flutter/material.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';

import '../../components/navigation_drawer.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

List<bool> _checkedList = List.generate(10, (index) => false);

class _SelectPatientScreenState extends State<SelectPatientScreen> {

   bool isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
    //  List<bool> _checkedList = List.generate(10, (index) => false);
    Widget buildCard(int index) => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: CheckboxListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient $index',
                  style: const TextStyle(fontSize: 15),
                ),
                Text('patientEmail $index',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            value: _checkedList[index],
            onChanged: (value) {
              setState(() {
                _checkedList[index] = value!;
              });
            },
            activeColor: const Color(0xFF0CE25C),
          ),
        );


         List<int> values = [
      2,
      4,
      6,
      8,
      10
    ]; // Replace with your actual list of values

    List<bool> isItemExpanded = List.filled(values.length, false);

    Widget buildCard2(int index) => Container(
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF9EE8BF),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 0, 30),
            child: const Text(
              'Select Patient',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: 6,
          //     itemBuilder: (context, index) {
          //       return buildCard(index);
          //     },
          //   ),
          // ),
            FutureBuilder<List<GraceUser>>(
            future: userRepo.getAllPatientsWithMedications(),
            builder: (context,snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                      return  Column(
                        children: [
                          Expanded(
                    child: ListView.builder(
                     padding: const EdgeInsets.all(10.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                // return buildCard2(index);
                return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: CheckboxListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data![index].email ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                Text(snapshot.data![index].name ?? '',
                    style: const TextStyle(fontSize: 12)),                    
              ],
            ),
            value: _checkedList[index],
            onChanged: (value) {
              setState(() {
                _checkedList[index] = value!;
              });
            },
            activeColor: const Color(0xFF0CE25C),
          ),
        );
              },
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
                      }  else {
                      return const Center(child: CircularProgressIndicator());
                    }

            }), 

          //             Container(
          //   padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor:
          //           const Color(0xFF0CE25C), // Button background color
          //       shape: RoundedRectangleBorder(
          //         borderRadius:
          //             BorderRadius.circular(12), // Rounded corner radius
          //       ),
          //       minimumSize: const Size(double.infinity,
          //           40), // Adjust the width by modifying the minimumSize property
          //     ),
          //     child: const Text(
          //       'Add Patients',
          //       style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),


          
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Patient Info Medication List',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
       
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10.0),
              itemCount: 5,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemBuilder: (context, index) {
                return buildCard2(index);
              },
            ),
          )
        ],
      ),
      endDrawer: const AppDrawerNavigation(
        loginType: LoginType.caregiver,
      ),
    );
  }
}