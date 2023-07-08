import 'package:flutter/material.dart';
import 'models/authentication_repository.dart';

enum LoginType5 { patientsNavgation, caregiversNavgation }

class AppDrawerNavigation extends StatefulWidget {
  final LoginType5 loginType;

  // const AppDrawerNavigation({super.key});

  const AppDrawerNavigation({Key? key, required this.loginType})
      : super(key: key);

  @override
  State<AppDrawerNavigation> createState() => _AppDrawerNavigationState();
}

class _AppDrawerNavigationState extends State<AppDrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return widget.loginType == LoginType5.patientsNavgation
        ? Drawer(
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
                    // AuthenticationRepository.instance.loginPUser(
                    //                         controller.email.text.trim(),
                    //                         controller.password.text.trim());
                    //                   }
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
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/drugs.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Prescriptions'),
                  onTap: () {
                    // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
                  }
                  // Navigator.of(context).pushReplacementNamed(GalleryScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/mic.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Vocalizations'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/photo-camera.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('PhotoScanner'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Communications'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              //  Divider(height: 3, color: Colors.blueGrey),
              //  ListTile(
              //   leading: Icon(Icons.logout),
              //   title: Text('Patients'),
              //   onTap: () {

              //   } // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
              // ),
            ]),
          )
        : Drawer(
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
                    // AuthenticationRepository.instance.loginPUser(
                    //                         controller.email.text.trim(),
                    //                         controller.password.text.trim());
                    //                   }
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
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/drugs.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Prescriptions'),
                  onTap: () {
                    // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
                  }
                  // Navigator.of(context).pushReplacementNamed(GalleryScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/mic.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('Vocalizations'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: Image.asset(
                    'assets/images/photo-camera.png',
                    height: 28,
                    width: 28,
                  ),
                  title: const Text('PhotoScanner'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Communications'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
              const Divider(height: 3, color: Colors.blueGrey),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Patients'),
                  onTap:
                      () {} // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName),
                  ),
            ]),
          );
  }
}
