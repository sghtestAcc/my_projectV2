import 'package:flutter/material.dart';
import 'package:my_project/login_page.dart';
import 'package:my_project/register_page.dart';
void main() => runApp(MaterialApp(
      title: "App",
      home: HomeScreen(),
    ));

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            children: [
Image.asset('assets/images/Medi_Assist-removebg-preview.png', 
            height: 175,
            width: 175,
            fit: BoxFit.cover),
            Image.asset('assets/images/sgh.png'),
                        Text('Welcome to SGH`s Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text('Tracker Application!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
            },  
             child: Text('Caregiver  Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), style: ElevatedButton.styleFrom(
            primary: Color(0xFF0CE25C),
        minimumSize: const Size(320,50), // NEW
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corner radius
    ),
      ), 
      ),
          Expanded(child: Image.asset('assets/images/sghDesign.png')),            
            ],
      )),
    );
  }
}
