import 'package:flutter/material.dart';
import 'package:my_project/navigation_drawer.dart';

class PatientsPrescripScreen extends StatelessWidget {
  const PatientsPrescripScreen({super.key});
  // PatientHomeScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 45),
            decoration: const BoxDecoration(
              color: Color(0xFF9EE8BF), // Background color/ Rounded border
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Patient',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Medications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6), // Background color
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
              color:
                  const Color(0xFFF6F6F6), // Background color // Rounded border
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Patient info Medication List',
                  style: TextStyle(fontSize: 20),
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6), // Background color
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
      ),
      endDrawer:
          const AppDrawerNavigation(loginType: LoginType5.patientsNavgation),
      // bottomNavigationBar: NavigatorBar(loginType: LoginType4.patientsLoginBottomTab,),
      // Get.to(() => NavigatorBar(loginType: LoginType4.caregiversLoginBottomTab,));
    );
  }
}
