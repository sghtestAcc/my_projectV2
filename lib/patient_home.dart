import 'package:flutter/material.dart';
import 'package:my_project/navigation_drawer.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: PatientHomeScreen(loginType: loginType3.patientsHomeScreen),
    ));

enum loginType3 { patientsHomeScreen, caregiversHomeScreen}

    class PatientHomeScreen extends StatefulWidget {      
      

final loginType3 loginType;
const PatientHomeScreen({Key? key, required this.loginType}): super(key: key);

  //  final LoginType2 registerType;
  // const RegisterScreen({Key? key, required this.registerType}): super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();  
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {

   TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
     Widget buildCard(int index) => Container(
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
      body:
      Container(
        child: Column(
          children: [
              Container(
                  child: Stack(
                     alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/new-sgh-design.png', ),
                            Image.asset(
                'assets/images/Grace-bg-new-edited.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              widget.loginType == loginType3.patientsHomeScreen ? 
               const Positioned.fill(child: Align(
                alignment: Alignment.bottomLeft,
               child: Padding(
               padding:EdgeInsets.all(20.0),
               child: Column(
                mainAxisAlignment: MainAxisAlignment.end ,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                Text('Hi Welcome Patient', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                Text('How can I help you today?', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),   
                // Align(
                //   alignment: Alignment.bottomLeft,
                //   child: Transform.translate(
                //     offset: const Offset(0.0, 15.0),
                //     child: Container(
                //       child: TextField(
                //               decoration: InputDecoration(
                //             hintText: 'Quick search a patient here',
                //             prefixIcon: Icon(Icons.search),
                //               ),
                //              ),
                //     ),
                //   ),
                // )
               ],
               )
               ),
               ),) : const Positioned.fill(child: Align(
                alignment: Alignment.bottomLeft,
               child: Padding(
               padding:EdgeInsets.all(20.0),
               child: Column(
                mainAxisAlignment: MainAxisAlignment.end ,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                Text('Hi Welcome Caregivers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                Text('How can I help you today?', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),   
                // Align(
                //   alignment: Alignment.bottomLeft,
                //   child: Transform.translate(
                //     offset: const Offset(0.0, 15.0),
                //     child: Container(
                //       child: TextField(
                //               decoration: InputDecoration(
                //             hintText: 'Quick search a patient here',
                //             prefixIcon: Icon(Icons.search),
                //               ),
                //              ),
                //     ),
                //   ),
                // )
               ],
               )
               ),
               ),)
          
                      ]
                      ) 
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/drugs.png',  height: 90, width: 90,  ),
                   Image.asset('assets/images/mic.png', height: 90, width: 90, ),
                  Image.asset('assets/images/photo-camera.png',  height: 90, width: 90,),
                ],
              ), 
              ),
              Container(
                child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Prescriptions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  Text('Vocalization', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  Text('PhotoScanner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                ],
              ), 
              ),
              SizedBox(height: 10,),
              Container(
                padding:EdgeInsets.all(10.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Medication status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),  
      
                ]),
              ),
             Expanded(
               child: ListView.separated(
                 padding:EdgeInsets.all(10.0),
                 itemCount: 10,
                 separatorBuilder: (context,index) {
                  return const SizedBox(height: 10,);
                 },
                 itemBuilder: (context, index) {
                  return buildCard(index);
                 },
             
               ),
             ) 
                
          ],
        ),
      ),
       drawer: AppDrawerNavigation(),
    );
  }
}