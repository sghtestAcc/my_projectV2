import 'package:flutter/material.dart';

class PatientsPrescripScreen extends StatelessWidget {
  const PatientsPrescripScreen({super.key});
  // PatientHomeScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
           Column(
            children: [
              Text('Patient', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Text('Medications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Container(
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10), // Set border radius
             ),
          child: Column(
          children: [
            Text('PatientName 1'),
            Text('Patient1@gmail.com'),
            Text('Feed Medication 1 during the Morning, after meals'),
            Text('Feed Medication 2 during the Morning, after meals'),
            Text('Feed Medication 3 during the Morning, after meals'),
            ],
            ),
            )
              ],)
          ]),
      ),
    );
  }
}