import 'package:flutter/material.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/grace_user.dart';
import 'package:my_project/models/login_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../repos/authentication_repository.dart';
import 'package:my_project/utils/tutorial_manager.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<LoginType> selectedLoginTypes = [];

  var formData = GlobalKey<FormState>();
  final GlobalKey keyRegisterForm = GlobalKey();
  final GlobalKey keyCheckboxSection = GlobalKey();
  late TutorialManager tutorialManager;

  final email = TextEditingController();
  final fullName = TextEditingController();
  final password = TextEditingController();
  bool showAccountTypeError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final step = await getTutorialStep();
      if (step == 2) {
        currentTutorialStep = 2;

        tutorialManager = TutorialManager(
          context,
          keyLoginButton: keyRegisterForm,
        );

        tutorialManager.targets = [
          TargetFocus(
            identify: "register_fields",
            keyTarget: keyRegisterForm,
            contents: [
              TargetContent(
                align: ContentAlign.top,
                child: const Text(
                  "Fill in these fields to register.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            shape: ShapeLightFocus.RRect,
            radius: 12,
            paddingFocus: 0,
          ),
          TargetFocus(
            identify: "register_checkboxes",
            keyTarget: keyCheckboxSection,
            contents: [
              TargetContent(
                align: ContentAlign.bottom,
                child: const Text(
                  "To register as a Dual Account, check both Patient and Caregiver.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            shape: ShapeLightFocus.RRect,
            radius: 12,
            paddingFocus: 0,
          ),
/*           TargetFocus(
            identify: "intro_fullscreen",
            targetPosition: TargetPosition(
              const Size(1, 1), // Valid size
              const Offset(0, 0), // On screen (not -500)
            ),
            shape: ShapeLightFocus.RRect,
            radius: 0,
            contents: [
              TargetContent(
                align: ContentAlign.bottom,
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Let’s try making your own account!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ), */
        ];

        tutorialManager.showTutorial(
          onFinish: () async {
            await setTutorialStep(3);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        );
      }
    });
  }

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
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: formData,
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/final-grace-background.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    Image.asset('assets/images/sgh.png'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.register,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                key: keyRegisterForm,
                padding: const EdgeInsets.all(20),
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
                    TextFormField(
                      controller: email,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .emailRequiredError)),
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
                      child: Text(AppLocalizations.of(context)!.accountType,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      key: keyCheckboxSection,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: showAccountTypeError
                              ? Colors.red
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        children: LoginType.values
                            .where((type) => type != LoginType.dualAccount)
                            .map((type) {
                          return CheckboxListTile(
                            title: Text(
                              type == LoginType.patient
                                  ? AppLocalizations.of(context)!
                                      .accountTypePatient
                                  : AppLocalizations.of(context)!
                                      .accountTypeCaregiver,
                            ),
                            value: selectedLoginTypes.contains(type),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedLoginTypes.add(type);
                                } else {
                                  selectedLoginTypes.remove(type);
                                }
                                showAccountTypeError =
                                    false; // clear error on change
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),
                    ),
                    if (showAccountTypeError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!
                                .selectAccountTypeError,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context)!.fullname,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: fullName,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .fullnamerequired)),
                          );
                          return AppLocalizations.of(context)!.fullnamerequired;
                        }
                        //changed to every first letter in the word to be full caps in the users Fullname
                        //-applies to Both Patients and Caregivers-
                        else if (!RegExp(
                                r"^[A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z]+)*$")
                            .hasMatch(value.trim())) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .fullnamecapitalerror),
                            ),
                          );
                          return AppLocalizations.of(context)!
                              .fullnamecapitalerror;
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
                      child: Text(AppLocalizations.of(context)!.password,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .errorPasswordRequired)),
                          );
                          return AppLocalizations.of(context)!
                              .errorPasswordRequired;
                        } else if (value.length < 6) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .errorPasswordTooShort)),
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
                    )
                  ],
                ),
              ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      selectedLoginTypes.contains(LoginType.caregiver)
                          ? 'assets/images/sgh-design-caregiver.png'
                          : 'assets/images/sghDesign.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isValid = formData.currentState!.validate();

                        setState(() {
                          showAccountTypeError = selectedLoginTypes.isEmpty;
                        });

                        if (!isValid || selectedLoginTypes.isEmpty) return;

                        // Determine login type
                        LoginType loginType;
                        if (selectedLoginTypes.contains(LoginType.patient) &&
                            selectedLoginTypes.contains(LoginType.caregiver)) {
                          loginType = LoginType.dualAccount;
                        } else {
                          loginType = selectedLoginTypes.first;
                        }

                        final user = GraceUser(
                          email: email.text.trim(),
                          name: fullName.text.trim(),
                          loginType: loginType,
                        );

                        await AuthenticationRepository.instance.registerUser(
                          email.text.trim(),
                          password.text.trim(),
                          loginType,
                          user,
                          context,
                        );

                        email.clear();
                        password.clear();
                        fullName.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CE25C), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Rounded corner radius
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.haveaccountlogin,
                          style: const TextStyle(
                              fontSize: 15,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
