import 'package:flutter/material.dart';

class AppDrawerNavigation  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
    color: Colors.black, // Set the desired color here
  ),
        ),
        ListTile(
          leading: Image.asset('assets/images/logout.png', height: 28, width: 28,),
        
          title: Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          onTap: () {
            
          }
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Image.asset('assets/images/world.png', height: 28, width: 28,),
          title: Text('Change Language',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) ),
          onTap: () {
    // Navigator.of(context).pushReplacementNamed(WeatherScreen.routeName);
    }
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
            leading: Image.asset('assets/images/drugs.png', height: 28, width: 28,),
            title: Text('Prescriptions'),
            onTap: () {
              // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);

            }
          // Navigator.of(context).pushReplacementNamed(GalleryScreen.routeName),
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Image.asset('assets/images/mic.png', height: 28, width: 28,),
          title: Text('Vocalizations'),
          onTap: () {
            
          } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Image.asset('assets/images/photo-camera.png', height: 28, width: 28,),
          title: Text('PhotoScanner'),
          onTap: () {
            
          } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Communications'),
          onTap: () {
            
          } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
        ),
         Divider(height: 3, color: Colors.blueGrey),
         ListTile(
          leading: Icon(Icons.logout),
          title: Text('Patients'),
          onTap: () {
            
          } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
        ),


      ]),
    );
  }
}