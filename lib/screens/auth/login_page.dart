import 'package:flutter/material.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/screens/auth/forget_password_page.dart';
import 'package:my_project/screens/auth/register_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/login_type.dart';
import 'package:my_project/components/navigation_drawer_new.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginType? selectedLoginType;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // String? email;
  // String? password;

  final email = TextEditingController();
  final password = TextEditingController();

  var formData = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu), // Hamburger icon
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
      ),
      endDrawer: AppDrawerNavigationNew(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/final-grace-background.png',
                    height: 175,
                    width: 175,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    'assets/images/sgh.png',
                    height: 100,
                    width: 180,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    AppLocalizations.of(context)!.login,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.email,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: email,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .emailRequiredError),
                            ),
                          );
                          return AppLocalizations.of(context)!
                              .emailRequiredError;
                        } else if (!value.contains('@')) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .errorInvalidEmail),
                            ),
                          );
                          return AppLocalizations.of(context)!
                              .errorInvalidEmail;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.password,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .errorPasswordRequired),
                            ),
                          );
                          return AppLocalizations.of(context)!
                              .errorPasswordRequired;
                        } else if (value.length < 6) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .errorPasswordTooShort),
                            ),
                          );
                          return AppLocalizations.of(context)!
                              .errorPasswordTooShort;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.accountType,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<LoginType>(
                      value: selectedLoginType,
                      onChanged: (LoginType? newValue) {
                        setState(() {
                          selectedLoginType = newValue!;
                        });
                      },
                      validator: (value) => value == null
                          ? AppLocalizations.of(context)!
                              .selectAccountTypeValidation
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      items: [LoginType.patient, LoginType.caregiver]
                          .map((LoginType type) {
                        return DropdownMenuItem<LoginType>(
                          value: type,
                          child: Text(
                            type == LoginType.patient
                                ? AppLocalizations.of(context)!
                                    .accountTypePatient
                                : AppLocalizations.of(context)!
                                    .accountTypeCaregiver,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen()),
                        );
                      },
                      child: Align(
                        alignment: Alignment
                            .centerRight, // Align the text to the right
                        child: Text(
                          AppLocalizations.of(context)!.forgetPasswordHeader,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      // height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool isFormValid = formData.currentState!.validate();

                          if (!isFormValid) return;

                          if (selectedLoginType == null) {
                            scaffoldMessengerKey.currentState
                                ?.showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .selectAccountTypeError),
                            ));
                            return;
                          }

                          await AuthenticationRepository.instance.loginUser(
                            email.text.trim(),
                            password.text.trim(),
                            selectedLoginType!,
                            context,
                          );
                          formData.currentState?.reset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0CE25C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.noAccountSignUp,
                        style: const TextStyle(
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  selectedLoginType == LoginType.caregiver
                      ? 'assets/images/sgh-design-caregiver.png'
                      : 'assets/images/sghDesign.png',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
