import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';

import 'package:flutter/material.dart';

class caregiverPatientCardView extends StatefulWidget {
  int index;
  final String uid;
  // patientcard(this.index, t{super.key});
  caregiverPatientCardView(this.index, this.uid, {Key? key}) : super(key: key);
  @override
  State<caregiverPatientCardView> createState() => _caregiverPatientCardViewState();
}

class _caregiverPatientCardViewState extends State<caregiverPatientCardView> {
      bool isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
    return Container(      
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [  
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
                          StreamBuilder<List<Medication>>(
                            stream: userRepo.getAllPatientMedications(widget.uid) ,
                            builder: (context, snapshot) {
                               if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                              }  else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Text('No medications has been added yet.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)),
                ],
              ),
            );
                } else if (snapshot.hasData) {
                  final medications = snapshot.data!; // List<Medication>
                    // Create a list of medication info items
                    List<bool> isItemExpanded =
                        List.filled(snapshot.data!.length, false);
                    final children = <Widget>[];
                    for (int i = 0; i < medications.length; i++) {
                      children.add(
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isItemExpanded[i] = !isItemExpanded[i];
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    medications[i].pills,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                medications[i].labels,
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                medications[i].quantity,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                medications[i].schedule,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                      children.add(SizedBox(
                        height: 10,
                      ));
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
                  } else {
                    return const Center(child: Text('Something went wrong'));
                  }
                })
        ],
      ),
    );
  }
}