import 'package:flutter/material.dart';

import '../../../models/grace_user.dart';
import '../../../models/medications.dart';
import 'caregiver_vocal.dart';

class myCardPrescription extends StatefulWidget {
 

  int index;
  final String uid;
  final String email;
  myCardPrescription(this.index, this.uid, this.email, {Key? key}) : super(key: key);

  @override
  State<myCardPrescription> createState() => _myCardPrescriptionState();
}

class _myCardPrescriptionState extends State<myCardPrescription> {
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
                            FutureBuilder<List<Medication>>(
                            future: userRepo.displayPatientsMedications(widget.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  final medications = snapshot.data!; // List<Medication>
                                  // Create a list of medication info items
                                  List<bool> isItemExpanded = List.filled(snapshot.data!.length, false);
                                  final children = <Widget>[];
                                  for (int i = 0; i < medications.length; i++) {
                                    children.add(
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isItemExpanded[i] = !isItemExpanded[i];
                                            // Handle the onTap event for each item if needed
                                          });
                                        },
                                        child: Column(
                                          children: [
                                               Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Feed ${medications[i].labels} during the ${medications[i].schedule}',
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    children.add(SizedBox(height: 10,));
                                  }
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: children,
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(snapshot.error.toString()),
                                  );
                                } else {
                                  return const Center(
                                    child: Text('Something went wrong'),
                                  );
                                }
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
            ],
          ),
        );
  }
}