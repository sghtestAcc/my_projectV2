import 'package:flutter/material.dart';
import 'package:my_project/navigation.tab.dart';
import 'package:my_project/navigation_drawer.dart';

class CaregiverPrescription extends StatelessWidget {
  const CaregiverPrescription({super.key});
  // PatientHomeScreen

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F6), // Background color
                borderRadius: BorderRadius.circular(10.0), // Rounded border
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              child: const Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PatientName 1',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'Quantity',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'Schedule',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'xxx@gmail.com',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medication 1',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '3 tabs',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'Morning \n After meals',
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ]),
            ),
          ),
        ],
      )),
      endDrawer: AppDrawerNavigation(loginType: LoginType5.patientsNavgation),
      // bottomNavigationBar: NavigatorBar(loginType: LoginType4.patientsLoginBottomTab,),
      // Get.to(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,));
    );
  }
}
