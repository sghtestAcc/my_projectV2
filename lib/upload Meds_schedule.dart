

import 'package:flutter/material.dart';

void addMedsScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
           Row(
  children: [
    IconButton(
      onPressed: () {
        // Handle the close button action here
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.close),
    ),
  ],
),

    Text(
        'Upload Medications schedules',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
              SizedBox(height: 30,),

 Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Quantity',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
 SizedBox(height: 10,),
              Container(
  decoration: BoxDecoration( // Background color
    borderRadius: BorderRadius.circular(10.0), // Rounded border
    border: Border.all(
      color: Colors.black,
      width: 1.0,
    ),
  ),
  child: TextFormField(
    decoration: InputDecoration(
      hintText: '2 tabs/tablets',
      contentPadding: EdgeInsets.all(10.0),
    ),
  ),
),
 SizedBox(height: 10,),
 Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Schedule',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
 SizedBox(height: 10,),
              Container(
  decoration: BoxDecoration( // Background color
    borderRadius: BorderRadius.circular(10.0), // Rounded border
    border: Border.all(
      color: Colors.black,
      width: 1.0,
    ),
  ),
  child: TextFormField(
    decoration: InputDecoration(
      hintText: 'Morning After meal...',
      contentPadding: EdgeInsets.all(10.0),
    ),
  ),
),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: 
              () {}, child: Text('Add', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),

               SizedBox(height: 10,),
              ElevatedButton(onPressed: 
              () {}, child: Text('Close', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
          ]),
        );
      });

}