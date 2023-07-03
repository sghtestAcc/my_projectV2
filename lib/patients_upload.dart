import 'package:flutter/material.dart';
import 'package:my_project/camera_home_patient.dart';
import 'package:my_project/navigation_drawer.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: PatientUploadScreen(),
    ));


    class PatientUploadScreen extends StatefulWidget {      
  const PatientUploadScreen({Key? key});

  @override
  State<PatientUploadScreen> createState() => _PatientUploadScreenState();  
}

class _PatientUploadScreenState extends State<PatientUploadScreen> {

   TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/Grace-bg-new-edited.png',
                  ),
                  fit: BoxFit.contain
              )
          ),
        ),
        backgroundColor: Colors.white, 
        iconTheme: IconThemeData(color: Colors.black), 
      ), 
      body: 
      Container(
        padding: EdgeInsets.fromLTRB(40, 10, 40, 0) ,
        child: Center(
          child: 
            Column(children: [
                         Text('New Patients Must', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Text('upload your medication', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
           Text('These information would assist caregivers', style: TextStyle(fontSize: 15),),
             Text('in managing your medication effectively', style: TextStyle(fontSize: 15),),
            SizedBox(height: 20,),


//upload images button
         Container(
  width: double.infinity, // Set the width to expand to the available space
  child: ElevatedButton(
    onPressed: () {
      // Add your onPressed logic here
         Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
    },
    style: ElevatedButton.styleFrom(
      primary: Color(0xFF0CE25C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12), // Adjust the padding as needed
      child: Text(
        'Upload Images',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Colors.black,),
      ),
    ),
  ),
),   

    SizedBox(height: 20,),

//upload schdules button
            Container(
  width: double.infinity, // Set the width to expand to the available space
  child: ElevatedButton(
    onPressed: () {
      // Add your onPressed logic here
      //  Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
    },
    style: ElevatedButton.styleFrom(
      primary: Color(0xFF0CE25C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12), // Adjust the padding as needed
      child: Text(
        'Upload Schedules',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Colors.black,),
      ),
    ),
  ),
),   
 SizedBox(height: 20,),
  Container(
  width: double.infinity, // Set the width to expand to the available space
  child: ElevatedButton(
    onPressed: () {
      // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
      
    },
    style: ElevatedButton.styleFrom(
      primary: Color(0xFF0CE25C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12), // Adjust the padding as needed
      child: Text(
        'Add Meds Info',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Colors.black,),
      ),
    ),
  ),
), 
 SizedBox(height: 20,),
  Container(
  width: double.infinity, // Set the width to expand to the available space
  child: ElevatedButton(
    onPressed: () {
      // Add your onPressed logic here
    },
    style: ElevatedButton.styleFrom(
      primary: Color(0xFF0CE25C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12), // Adjust the padding as needed
      child: Text(
        'Proceed to homepage',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Colors.black,),
      ),
    ),
  ),
),
SizedBox(height: 20,),
         Text('Medication Label:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
           Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                     style: TextStyle(
    color: Colors.black, 
  ),
                    // controller: controller,
                    enabled: false,
                        decoration: InputDecoration(
    hintText: "Your Medication Label... ",
    border: InputBorder.none, // Set this to remove the border
  ),
                  ),
              ),
         Text('Medication Quantity:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                     style: TextStyle(
    color: Colors.black, 
  ),
                    // controller: controller,
                    enabled: false,
                        decoration: InputDecoration(
    hintText: "Your Medication Quantity...",
    border: InputBorder.none, // Set this to remove the border
  ),
                  ),
              ),
              Text('Medication Schedules:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextFormField(
                     style: TextStyle(
    color: Colors.black, 
  ),
                    // controller: controller,
                    enabled: false,
                        decoration: InputDecoration(
    hintText: "Your Medication Schedule...",
    border: InputBorder.none, // Set this to remove the border
  ),
                  ),
              ),
          
         
    



            
            ]),
          )
      ),
    );
    
  }
}