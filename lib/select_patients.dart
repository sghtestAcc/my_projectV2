import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  ),
);



 Widget buildCard2(int index) => Container(
padding: EdgeInsets.all(10.0),
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(22)),
    color: Colors.grey,
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
  toolbarHeight: 40,
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Text(
    'Patients',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ),
  titleTextStyle: TextStyle(
    color: Colors.black,
  ),
  centerTitle: true, // Set centerTitle to false for left alignment
),
      body: Container(
        child: Column(
          //  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFF9EE8BF),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
              child: Text('Select Patient', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold) ,),),
              Container(
                height: 200,
                child: Expanded(
                   child: ListView.builder(
                     itemCount: 5,
                     itemBuilder: (context, index) {
                      return buildCard(index);
                     },
                   ),    
                ),
              ),
              
             ElevatedButton(onPressed: () {}, child: Text('add Patients')),
              Container(
                padding: EdgeInsets.all(20.0),
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
    );
  }
}