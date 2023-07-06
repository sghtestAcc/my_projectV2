import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/navigation_drawer.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

List<bool> _checkedList = List.generate(10, (index) => false);

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  @override
  Widget build(BuildContext context) {
    //  List<bool> _checkedList = List.generate(10, (index) => false);
         Widget buildCard(int index) => 
        Container(
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
        Text('Patient $index', style: TextStyle(fontSize: 15),),
        Text('patientEmail $index', style: TextStyle(fontSize: 12)),
      ],
    ),
    value: _checkedList[index], 
    onChanged: (value) {
      setState(() {
        _checkedList[index] = value!;
      });
    },
    activeColor: Color(0xFF0CE25C), 
  ),
);

 Widget buildCard2(int index) => Container(
padding: EdgeInsets.all(10.0),
  decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          color: Color(0xDDF6F6F6),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
  height: 75,
    child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Patient $index', style: TextStyle(fontSize: 15),),
        Text('phoneNumber $index', style: TextStyle(fontSize: 12)),
        SizedBox(height: 10,),
        Text('View more for medication info', style: TextStyle(fontSize: 10))
      ],),
);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:AppBar(
          title: Text('Patients', style: TextStyle(color: Colors.black,fontSize: 25),),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
      body: Container(
        child: Column(
          children: [
            Container(
  color: Color(0xFF9EE8BF),
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
  child: Text(
    'Select Patient',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ),
),
Expanded(
  child: ListView.builder(
    itemCount: 6,
    itemBuilder: (context, index) {
      return buildCard(index);
    },
  ),
),

              
              Container(
  padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
  child: ElevatedButton(
    onPressed: () {
      // Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
    },
    child: Text(
      'Add Patients',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      primary: Color(0xFF0CE25C), // Button background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corner radius
      ),
      minimumSize: Size(double.infinity, 40), // Adjust the width by modifying the minimumSize property
    ),
  ),
),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Patient Info Medication List', style: TextStyle(fontSize: 20)),
                ),
              ),
              Expanded(
               child: ListView.separated(
                 padding:EdgeInsets.all(10.0),
                 itemCount: 5,
                 separatorBuilder: (context,index) {
                  return const SizedBox(height: 10,);
                 },
                 itemBuilder: (context, index) {
                  return buildCard2(index);
                 },
               ),
             ) 
        ]),
      ),
      endDrawer: AppDrawerNavigation(loginType: LoginType5.caregiversNavgation),
    );
  }
}