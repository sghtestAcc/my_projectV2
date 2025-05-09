import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/screens/auth/login_page.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'repos/authentication_repository.dart';
import 'models/login_type.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthenticationRepository()));

  runApp(
    const GetMaterialApp(
      title: "App",
  //     localizationsDelegates: [
  //   GlobalMaterialLocalizations.delegate,
  //   GlobalWidgetsLocalizations.delegate,
  //   GlobalCupertinoLocalizations.delegate,
  // ],
  // supportedLocales: [
  //   Locale('en', ''), // English
  //   Locale('hi', ''), // Spanish
  //   Locale('ar', ''),
  //   Locale('fr', ''),
  // ],
  // locale: Locale('fr', ''),
  home: HomeScreen(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "App",
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   Locale('en', ''), // English
      //   Locale('hi', ''), // Spanish
      //   Locale('ar', ''),
      //   Locale('fr', ''),
      // ],
      // locale: Locale('fr', ''),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();


}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    //  final localizations = AppLocalizations.of(context);
    return Scaffold(
  body: SingleChildScrollView(
    child: Center(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Image.asset(
            'assets/images/final-grace-background.png',
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
          const Text(
            'Guided Resources, Assistance',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const Text(
            'and Communication for Empowered Care',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Image.asset(
            'assets/images/sgh.png',
            fit: BoxFit.contain,
          ),
          const Text(
            'Welcome to SGH`s Medication',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Tracker Application',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen(loginType: LoginType.patient);
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0CE25C),
              minimumSize: const Size(320, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Patient Login',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen(
                      loginType: LoginType.caregiver,
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0CE25C),
              minimumSize: const Size(320, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Caregiver Login',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Align(
            child: Image.asset('assets/images/sghDesign.png'),
          ),
        ],
      ),
    ),
  ),
);

  }
}


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
//       .then((value) => Get.put(AuthenticationRepository()));

//   runApp(const MyApp());
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: "App",
//       // localizationsDelegates: [
//       //   GlobalMaterialLocalizations.delegate,
//       //   GlobalWidgetsLocalizations.delegate,
//       //   GlobalCupertinoLocalizations.delegate,
//       // ],
//       // supportedLocales: [
//       //   Locale('en', ''), // English
//       //   Locale('hi', ''), // Spanish
//       //   Locale('ar', ''),
//       //   Locale('fr', ''),
//       // ],
//       // localizationsDelegates: AppLocalizations.localizationsDelegates,
//       // supportedLocales: AppLocalizations.supportedLocales,
//       // locale: _locale,
//       home: HomeScreen(),
//     );
//   }
// }

// class _HomeScreenState extends State<HomeScreen> {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Image.asset(
//                 'assets/images/final-grace-background.png',
//                 height: 200,
//                 width: 200,
//                 fit: BoxFit.cover,
//               ),
//               const Text(
//                 'Guided Resources, Assistance',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//               ),
//               const Text(
//                 'and Communication for Empowered Care',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//               ),
//               Image.asset(
//                 'assets/images/sgh.png',
//                 fit: BoxFit.contain,
//               ),
//               const Text(
//                 'Welcome to SGH`s Medication',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//               ),
//               const Text(
//                 'Tracker Application',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginScreen(loginType: LoginType.patient),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0CE25C),
//                   minimumSize: const Size(320, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Patient Login',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginScreen(loginType: LoginType.caregiver),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0CE25C),
//                   minimumSize: const Size(320, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Caregiver Login',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(height: 80),
//               Align(
//                 child: Image.asset('assets/images/sghDesign.png'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }