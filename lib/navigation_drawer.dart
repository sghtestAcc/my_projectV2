import 'package:flutter/material.dart';

class AppDrawerNavigation  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    
    return Drawer(
      child: Column(
        children: [

        AppBar(
          title: Text("Hello Friend!"),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.bug_report_sharp),
          title: Text('Report a bug'),
          onTap: () {
            
          }
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Icon(Icons.wb_sunny_sharp),
          title: Text('current weather'),
          onTap: () {

    // Navigator.of(context).pushReplacementNamed(WeatherScreen.routeName);
    }
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
            leading: Icon(Icons.sports_basketball_rounded),
            title: Text('Facility'),
            onTap: () {
              // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);

            }
          // Navigator.of(context).pushReplacementNamed(GalleryScreen.routeName),
        ),
        Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('LogOut'),
          onTap: () {
            
          } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
        ),
        Divider(height: 3, color: Colors.blueGrey),
      ]),
    );
  }
}