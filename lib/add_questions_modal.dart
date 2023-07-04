

import 'package:flutter/material.dart';


void addQuestionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    IconButton(
      onPressed: () {
        // Handle the close button action here
      //   Navigator.push(context, MaterialPageRoute(builder: (context)=> 
      // NavigatorBar()));
      },
      icon: Icon(Icons.close),
    ),
  ],
),
              Text('Add Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Container(
  decoration: BoxDecoration(
    color: Colors.grey[200], // Background color
    borderRadius: BorderRadius.circular(10.0), // Rounded border
    border: Border.all(
      color: Colors.grey,
      width: 1.0,
    ),
  ),
  child: TextFormField(
    maxLines: 6,
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
      hintText: 'Enter your question here...',
      border: InputBorder.none,
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