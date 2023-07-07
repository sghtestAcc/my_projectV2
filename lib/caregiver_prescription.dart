import 'package:flutter/material.dart';
import 'package:my_project/navigation.tab.dart';
import 'package:my_project/navigation_drawer.dart';

class CaregiverPrescription extends StatefulWidget {
  const CaregiverPrescription({super.key});

  @override
  State<CaregiverPrescription> createState() => _CaregiverPrescriptionState();
}

class _CaregiverPrescriptionState extends State<CaregiverPrescription> {


  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {

   List<int> values = [2, 4, 6, 8, 10]; // Replace with your actual list of values

List<bool> isItemExpanded = List.filled(values.length, false);

    Widget buildCard(int index) => 
Container(
  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
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
        style: TextStyle(fontSize: 15),
      ),
      Text('phoneNumber $index', style: TextStyle(fontSize: 12)),
      Row(
        children: [
          Text(
            'View more for medication info',
            style: TextStyle(fontSize: 10),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isDropdownOpen = !isDropdownOpen;
              });
            },
            icon: Icon(isDropdownOpen ? Icons.expand_less : Icons.expand_more),
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
                        Text('1 $i', style: TextStyle(fontSize: 12)),
                        Text('1 $i', style: TextStyle(fontSize: 12)),
                        Text('Morning', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isItemExpanded[i])
                    Padding(
                      padding: EdgeInsets.only(left: 20.0), // Adjust the indentation as needed
                      child: Text(
                        'Additional medication info for item $i',
                        style: TextStyle(fontSize: 12),
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
      appBar: AppBar(
        title: Text(
          'Prescriptions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 45),
            decoration: BoxDecoration(
              color: Color(0xFF9EE8BF), // Background color/ Rounded border
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Patient',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Medications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6), // Background color
                  borderRadius: BorderRadius.circular(10.0), // Rounded border
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PatientName 1'),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Patient1@gmail.com'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Feed Medication 1 during the Morning, after meals'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Feed Medication 2 during the Morning, after meals'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Feed Medication 3 during the Morning, after meals'),
                    ]),
              )
            ]),
          ),
          Container(
            width: double.infinity,
            // padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6), // Background color // Rounded border
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Patient info Medication List',
                  style: TextStyle(fontSize: 20),
                )),
          ),
          SizedBox(
            height: 10,
          ),
           Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(10.0),
                itemCount: 10,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (context, index) {
                  return buildCard(index);
                },
              ),
            )
        ],
      )),
      endDrawer: AppDrawerNavigation(loginType: LoginType5.patientsNavgation),
      // bottomNavigationBar: NavigatorBar(loginType: LoginType4.patientsLoginBottomTab,),
      // Get.to(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,));
    );
  }
}
