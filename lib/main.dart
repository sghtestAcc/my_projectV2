import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:my_project/screens/auth/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_project/notification_service.dart'; // Add this import
import 'package:my_project/controllers/account_controller.dart';
import 'firebase_options.dart';
import 'repos/authentication_repository.dart';
import 'models/login_type.dart';
import 'package:my_project/screens/auth/register_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/screens/home/app_guide_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode =
      prefs.getString('selectedLocale') ?? 'en'; // default to English
  final savedLocale = Locale(savedLocaleCode);

  Get.put(AccountController());
  Get.put(AuthenticationRepository());

  runApp(MyApp(savedLocale));
}

Future<void> checkFirstLaunch(
    BuildContext context, VoidCallback showTutorial) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('hasSeenGuide') ?? true;

  if (isFirstLaunch) {
    // Delay so widgets are rendered
    debugPrint("✅ First launch detected, showing tutorial");
    Future.delayed(Duration(milliseconds: 300), showTutorial);

    // Mark guide as seen
    await prefs.setBool('hasSeenGuide', false);
  }
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  MyApp(this.initialLocale);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "App",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: initialLocale, // set saved locale
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey keyLoginButton = GlobalKey();
  final GlobalKey keySignUpButton = GlobalKey();
  late List<TargetFocus> targets;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initTargets();
      checkFirstLaunch(context, showTutorial);
    });
  }

  void initTargets() {
    targets = [
      TargetFocus(
        identify: "login",
        keyTarget: keyLoginButton,
        contents: [],
        shape: ShapeLightFocus.RRect, // Rounded rectangle
        radius: 8, // Smaller radius = tighter corner roundness
        paddingFocus: 4, // Smaller padding = tighter circle
      ),
      TargetFocus(
        identify: "signup",
        keyTarget: keySignUpButton,
        contents: [],
        shape: ShapeLightFocus.RRect,
        radius: 8,
        paddingFocus: 4,
      ),
    ];
  }

  void showTutorial() {
    TutorialCoachMark tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "SKIP",
      paddingFocus: 10,
      onClickTarget: (target) {
        String msg = "";
        switch (target.identify) {
          case "login":
            msg = "Click here to login as a patient or caregiver";
            break;
          case "signup":
            msg = "Or create a new account here!";
            break;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              duration: Duration(seconds: 3),
            ),
          );
      },
      onSkip: () => true,
      onFinish: () => print("Tutorial finished"),
    )..show(context: context);
  }

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
              Text(
                AppLocalizations.of(context)!.titlepage1stMsg,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                AppLocalizations.of(context)!.titlepage2ndMsg,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Image.asset(
                'assets/images/sgh.png',
                fit: BoxFit.contain,
              ),
              Text(
                AppLocalizations.of(context)!.titlepage3rdMsg,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                AppLocalizations.of(context)!.titlepage4thMsg,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                key: keyLoginButton,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LoginScreen();
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
                child: Text(
                  AppLocalizations.of(context)!.login,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                key: keySignUpButton,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const RegisterScreen();
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
                child: Text(
                  AppLocalizations.of(context)!.signUp,
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