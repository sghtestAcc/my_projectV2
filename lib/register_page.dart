import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: RegisterScreen(),
    ));


    class RegisterScreen extends StatelessWidget {
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
                      Image.asset(
              'assets/images/Medi_Assist-removebg-preview.png',
              height: 175,
              width: 175,
              fit: BoxFit.cover,
            ),
            Image.asset('assets/images/sgh.png'),
            SizedBox(height: 10,),
              Text('Caregiver Register', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),       ],
                    )
                     ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Phone number', style: TextStyle(fontSize: 15)),
                  SizedBox(height: 10,),
                  TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), )
                  ),
                  
                ),
                SizedBox(height: 10,),
                Text('Password', style: TextStyle(fontSize: 15)),
                SizedBox(height: 10,),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), )
                  ),
                ),
                SizedBox(height: 10,),
                Text('Confirm Password', style: TextStyle(fontSize: 15)),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), )
                  ),
                ),
               Container(
                width: double.infinity,
                child:  ElevatedButton(onPressed: (){
            },  
             child: Text('Register', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), style: ElevatedButton.styleFrom(
            primary: Color(0xFF0CE25C),// NEW
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corner radius
    ),
      ), 
      ),
               ),
                ]
              )
            ),
            //  Expanded(child: Image.asset('assets/images/sghDesign.png')),   
        ],
      ),
    );
  }
}