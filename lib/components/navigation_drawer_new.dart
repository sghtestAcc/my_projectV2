import 'package:flutter/material.dart';

import '../repos/authentication_repository.dart';

class AppDrawerNavigationNew extends StatelessWidget {
  const AppDrawerNavigationNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppBar(
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(
                  color: Colors.black, // Set the desired color here
                ),
              ),
              ListTile(
                  leading: Image.asset(
                    'assets/images/logout.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    AuthenticationRepository.instance.logout();
                  }),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/world.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Change Language',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigator.of(context).pushReplacementNamed(WeatherScreen.routeName);
                  }),



         
              //  Divider(height: 3, color: Colors.blueGrey),
              //  ListTile(
              //   leading: Icon(Icons.logout),
              //   title: Text('Patients'),
              //   onTap: () {

              //   } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
              // ),
            ]),
          );
  }
}