import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_project/patient_home.dart';
// import 'package:my_project/patient_home.dart';

import 'camera_home_patient.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: LoginScreen(),
    ));


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Country selectedCountry  = Country(
  phoneCode: "65", 
  countryCode: "SG", 
  e164Sc: 0, 
  geographic: true, 
  level: 1, 
  name: "Singapore", 
  example: "Singapore", 
  displayName: "Singapore", 
  displayNameNoCountryCode: "SG", 
  e164Key: "");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: 
      Column(
        children: [
            Container(
                child: Center(
                  child:Column(
                    children: [
                      Image.asset('assets/images/Grace-bg-new-edited.png',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            Image.asset('assets/images/sgh.png' ,height: 100, width: 180,),
            SizedBox(height: 10,),
              Text('Caregiver Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),       ],
                    )
                     ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  Text('Phone number', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10,),
                  TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), 
                    ),
                    prefixIcon: (
                      Container
                      (padding: const EdgeInsets.all(10),
                      child: InkWell(onTap: (){
                        showCountryPicker(context: context, 
                        countryListTheme: const CountryListThemeData(bottomSheetHeight: 500),
                        onSelect: (value) {
                             setState(() {
                             selectedCountry = value;
                          });
                        });
                      },
                      child: Text("${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      ),),
                    ))
                  ),
                ),
                SizedBox(height: 10,),
                Text('Password', style: TextStyle(fontSize: 20)),
                SizedBox(height: 10,),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), )
                  ),
                ),
                SizedBox(height: 10,),
               Container(
                width: double.infinity,
                height: 50,
                child:  ElevatedButton(onPressed: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> PatientHomeScreen()));
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraHomeScreenPatient()));
            },  
             child: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), style: ElevatedButton.styleFrom(
            primary: Color(0xFF0CE25C),// NEW
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corner radius
    ),
      ), 
      ),
               ),
               SizedBox(height: 10,),
               Text('Dont have an account? Sign up', style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline),)
                ]
              )
            ),
Expanded(child: Align(alignment: Alignment.bottomCenter, child: Image.asset('assets/images/sghDesign.png'),)),
            //  Expanded(child: Image.asset('assets/images/sghDesign.png')),   
        ],
      ),
    );
  }
}



