import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_project/login_page.dart';
import 'package:my_project/register_page.dart';

import 'firebase_options.dart';
void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
runApp(
  MaterialApp(
      title: "App",
      home: HomeScreen(),
// ...
)
);
} 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            children: [
              SizedBox(height: 10,),
Image.asset('assets/images/Grace-bg-new-edited.png', 
            height: 200,
            width: 200,
            fit: BoxFit.cover),
            Text('Guided Resources, Assistance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
             Text('and Communication for Empowered Care', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
            Image.asset('assets/images/sgh.png', fit: BoxFit.contain,),
                        Text('Welcome to SGH`s Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Tracker Application', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(loginType: LoginType.patientsLogin)));
            },
           style: ElevatedButton.styleFrom(
            primary: Color(0xFF0CE25C),
        minimumSize: const Size(320,50), // NEW
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corner radius
    ),
      ),
           child: Text('Patient Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (){
               Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(loginType: LoginType.caregiversLogin)));
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
            },  
             child: Text('Caregiver  Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), style: ElevatedButton.styleFrom(
            primary: Color(0xFF0CE25C),
        minimumSize: const Size(320,50), // NEW
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corner radius
    ),
      ), 
      ),
      Expanded(child: Align(alignment: Alignment.bottomCenter, child: Image.asset('assets/images/sghDesign.png'),))       
            ],
      )),
    );
  }
}
