import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';
import 'package:my_project/repos/user_repo.dart';

final userRepo = Get.put(UserRepository());

class caregiverPatientCardView extends StatefulWidget {
  int index;
  final String uid;
  caregiverPatientCardView(this.index, this.uid, {Key? key}) : super(key: key);
  
  @override
  State<caregiverPatientCardView> createState() => _caregiverPatientCardViewState();
}

class _caregiverPatientCardViewState extends State<caregiverPatientCardView> {
  bool isDropdownOpen = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(      
      child: Column(
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
              stream: userRepo.getAllPatientMedications(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Text(
                            'No medications has been added yet.', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final medications = snapshot.data!;
                  List<bool> isItemExpanded = List.filled(snapshot.data!.length, false);
                  final children = <Widget>[];
                  
                  for (int i = 0; i < medications.length; i++) {
                    children.add(
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isItemExpanded[i] = !isItemExpanded[i];
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Images and Medication Name Row
                              Row(
                                children: [
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: (medications[i].pills.isNotEmpty)
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: medications[i].pills.length,
                                                itemBuilder: (context, imgIdx) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 4),
                                                    child: Image.network(
                                                      medications[i].pills[imgIdx],
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        height: 50,
                                                        width: 50,
                                                        color: Colors.grey[300],
                                                        child: Icon(Icons.image_not_supported),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              height: 50,
                                              width: 50,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.image_not_supported),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          medications[i].labels,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        if (medications[i].quantity != null && medications[i].quantity!.isNotEmpty)
                                          Text(
                                            "Quantity: ${medications[i].quantity}",
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        if (medications[i].dosage != null && medications[i].dosage!.isNotEmpty)
                                          Text(
                                            "Dosage: ${medications[i].dosage}",
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Additional Details (Instructions and Details)
                              SizedBox(height: 8),
                              if (medications[i].instructions != null && medications[i].instructions!.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Instructions:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        medications[i].instructions!,
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              if (medications[i].details != null && medications[i].details!.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Details:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        medications[i].details!,
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                    children.add(SizedBox(height: 10));
                  }
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
                } else {
                  return const Center(child: Text('Something went wrong'));
                }
              },
            ),
        ],
      ),
    );
  }
}