import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:my_project/screens/camera/camera_patient_pills_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../repos/authentication_repository.dart';
import '../screens/camera/camera_patient_meds_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawerNavigationNew extends StatefulWidget {
  int selectedScreen = 0;
  AppDrawerNavigationNew({Key? key, this.selectedScreen = 0}) : super(key: key);

  @override
  State<AppDrawerNavigationNew> createState() => _AppDrawerNavigationNewState();
}

class _AppDrawerNavigationNewState extends State<AppDrawerNavigationNew> {
  String changedText = '';
  String sourceLang = 'English';
  final languagePicker = TranslateLanguage.values
      .map(
        (e) => e.name.capitalize!,
      )
      .toList();

  final Selectedscreens = [
    CameraHomePatientScreen(),
    CameraHomePatientPillScreen(),
  ];

  String _getLanguageNameFromLocale(Locale locale, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (locale.languageCode) {
      case 'en':
        return loc.languageEnglish;
      case 'zh':
        return loc.chinese;
      case 'tl':
        return loc.tagalog;
      case 'id':
        return loc.indonesian;
      case 'my':
        return loc.burmese;
      case 'ta':
        return loc.tamil;
      case 'ms':
        return loc.malay;
      default:
        return loc.languageEnglish;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppBar(
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(
            color: Colors.black, // Set the desired color here
          ),
        ),
        if (!(context.widget.runtimeType.toString().contains('LoginScreen') ||
            context.widget.runtimeType.toString().contains('RegisterScreen')))
          ListTile(
            leading: Image.asset(
              'assets/images/logout.png',
              height: 28,
              width: 28,
            ),
            title: Text(
              AppLocalizations.of(context)!.drawerLogout,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              AuthenticationRepository.instance.logout(context);
            },
          ),
        const Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: Image.asset(
            'assets/images/world.png',
            height: 28,
            width: 28,
          ),
          title: Text(AppLocalizations.of(context)!.changeLanguage,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      AppLocalizations.of(context)!.dialogSelectLanguageTitle),
                  content: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownButton<Locale>(
                      isExpanded: true,
                      value: Get.locale ?? const Locale('en'),
                      onChanged: (Locale? newLocale) async {
                        if (newLocale != null) {
                          setState(() {
                            sourceLang =
                                _getLanguageNameFromLocale(newLocale, context);
                          });
                          Get.updateLocale(newLocale);

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'selectedLocale', newLocale.languageCode);

                          Navigator.pop(context);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Text(
                              AppLocalizations.of(context)!.languageEnglish),
                        ),
                        DropdownMenuItem(
                          value: const Locale('zh'),
                          child: Text(AppLocalizations.of(context)!.chinese),
                        ),
                        DropdownMenuItem(
                          value: const Locale('tl'),
                          child: Text(AppLocalizations.of(context)!.tagalog),
                        ),
                        DropdownMenuItem(
                          value: const Locale('id'),
                          child: Text(AppLocalizations.of(context)!.indonesian),
                        ),
                        DropdownMenuItem(
                          value: const Locale('my'),
                          child: Text(AppLocalizations.of(context)!.burmese),
                        ),
                        DropdownMenuItem(
                          value: const Locale('ta'),
                          child: Text(AppLocalizations.of(context)!.tamil),
                        ),
                        DropdownMenuItem(
                          value: const Locale('ms'),
                          child: Text(AppLocalizations.of(context)!.malay),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ]),
    );
  }
}
