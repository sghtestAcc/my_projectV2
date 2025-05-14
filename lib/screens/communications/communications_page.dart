import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/controllers/select_patient_controller.dart';
import 'package:my_project/repos/authentication_repository.dart';
import 'package:my_project/repos/user_repo.dart';
import 'package:my_project/screens/communications/components/add_questions_modal.dart';

import '../../models/login_type.dart';

class CommunicationsScreen extends StatefulWidget {
  // LoginScreen
  final LoginType loginType;
  // const CommunicationsScreen({super.key});
  const CommunicationsScreen({Key? key, required this.loginType})
      : super(key: key);

  @override
  State<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

// final questionsText = TextEditingController();
final userRepo = Get.put(UserRepository());
final controller = Get.put(SelectPatientController());

class _CommunicationsScreenState extends State<CommunicationsScreen> {
  String? currentEmail = FirebaseAuth.instance.currentUser!.email;

  var formData = GlobalKey<FormState>();
  String? _translatedText;
  final _controller = TextEditingController();
  String sourceSelect = 'English';
  String targetSelect = 'English';
  bool _isLoading = false;
  String typedText = '';

  Future<void> translateTextFunction(String changedText) async {
    setState(() {
      typedText = changedText;
    });
    TranslateLanguage sourceLanguage = TranslateLanguage.values.firstWhere(
      (element) => element.name == sourceSelect.toLowerCase(),
    );
    TranslateLanguage targetLanguage = TranslateLanguage.values.firstWhere(
      (element) => element.name == targetSelect.toLowerCase(),
    );
    var onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    setState(() {
      _isLoading = true;
    });
    final result = await onDeviceTranslator.translateText(_controller.text);
    setState(() {
      _translatedText = result;
      _isLoading = false;
    });
  }

  final languagePicker = TranslateLanguage.values
      .map(
        (e) => e.name.capitalize!,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            'Communications',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.2,
            child: Form(
              key: formData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFF9EE8BF),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: const Text(
                      'Translate Questions',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: DropdownButton(
                          hint: const Text('English'),
                          value: sourceSelect,
                          onChanged: (newValue) {
                            setState(() {
                              sourceSelect = newValue ?? '';
                              translateTextFunction(typedText);
                            });
                          },
                          items: languagePicker.map((valueItem) {
                            return DropdownMenuItem(
                              value: valueItem,
                              child: Text(valueItem),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: DropdownButton(
                          hint: const Text('English'),
                          value: targetSelect,
                          onChanged: (newValue) {
                            setState(() {
                              targetSelect = newValue ?? '';
                              translateTextFunction(typedText);
                            });
                          },
                          items: languagePicker.map((valueItem) {
                            return DropdownMenuItem(
                              value: valueItem,
                              child: Text(valueItem),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _controller,
                    onChanged: translateTextFunction,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter text',
                      suffixIcon: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Clipboard.getData('text/plain').then((value) {
                                if (value != null) {
                                  _controller.text = value.text!;
                                  setState(() {
                                    typedText = value.text!;
                                    translateTextFunction(typedText);
                                  });
                                }
                              });
                            },
                            child: const Icon(Icons.paste),
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _isLoading
                          ? 'Loading...'
                          : _translatedText ?? 'Enter text to be translated',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  widget.loginType == LoginType.patient
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 2,
                          )),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(15, 20, 0, 20),
                          child: const Text(
                            'Common / Saved questions for Patients',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 2,
                          )),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(15, 20, 0, 20),
                          child: const Text(
                            'Common / Saved questions for Caregivers',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                  //patients view questions
                  widget.loginType == LoginType.patient
                      ? Expanded(
                          child: StreamBuilder<List<String>>(
                          stream: userRepo.getQuestionsofPatient(currentEmail),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            } else if (snapshot.hasData &&
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Image.asset(
                                        'assets/images/to-do-list.png'), // Adjust the image path accordingly
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('No questions added yet'),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasData) {
                              return ListView.separated(
                                padding: const EdgeInsets.all(10.0),
                                itemCount: snapshot.data!.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 15);
                                },
                                itemBuilder: (context, i) {
                                  return Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      color: Color(0xFFF6F6F6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          snapshot.data![i] ?? '',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                  text: snapshot.data![i] ?? '',
                                                )).then(
                                                  (_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Copied to your clipboard !'),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.copy),
                                            ),
                                            IconButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Color(0xFF35365D),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          title: const Text(
                                                            'Are you Sure?',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          content: const Text(
                                                              'This would delete a question',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          actions: [
                                                            MaterialButton(
                                                              child: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                // await AuthenticationRepository.instance.MedicationChecksDoubleLayer(currentUid,context);
                                                                await UserRepository
                                                                    .instance
                                                                    .deleteBothUserQuestions(
                                                                  context,
                                                                  currentEmail!,
                                                                  snapshot.data![
                                                                          i] ??
                                                                      '',
                                                                );
                                                              },
                                                            ),
                                                            MaterialButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                'cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      });
                                                },
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }
                          },
                        ))
                      : Expanded(
                          child: StreamBuilder<List<String>>(
                          stream:
                              userRepo.getQuestionsofCaregiver(currentEmail),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            } else if (snapshot.hasData &&
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Image.asset(
                                        'assets/images/to-do-list.png'), // Adjust the image path accordingly
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text('No questions added yet'),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasData) {
                              return ListView.separated(
                                padding: const EdgeInsets.all(10.0),
                                itemCount: snapshot.data!.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 15);
                                },
                                itemBuilder: (context, i) {
                                  return Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      color: Color(0xFFF6F6F6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          snapshot.data![i] ?? '',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                  text: snapshot.data![i] ?? '',
                                                )).then(
                                                  (_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Copied to your clipboard !'),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.copy),
                                            ),
                                            IconButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Color(0xFF35365D),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          title: const Text(
                                                            'Are you Sure?',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          content: const Text(
                                                              'This would delete a question',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          actions: [
                                                            MaterialButton(
                                                              child: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                // await AuthenticationRepository.instance.MedicationChecksDoubleLayer(currentUid,context);
                                                                await UserRepository
                                                                    .instance
                                                                    .deleteBothUserQuestions(
                                                                  context,
                                                                  currentEmail!,
                                                                  snapshot.data![
                                                                          i] ??
                                                                      '',
                                                                );
                                                              },
                                                            ),
                                                            MaterialButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                'cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      });
                                                },
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }
                          },
                        )),
                  widget.loginType == LoginType.patient
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              addQuestionsModal(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF6F6F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    22), // Rounded corner radius
                                side: const BorderSide(
                                  color: Colors
                                      .black, // Add your desired border color here
                                  width:
                                      1, // Add your desired border width here
                                ),
                              ),
                            ),
                            child: const Text(
                              'Add Questions?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              addQuestionsModal2(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                  0xDDF6F6F6), // Use backgroundColor instead of primary
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    22), // Rounded corner radius
                                side: const BorderSide(
                                  color: Colors.black, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                            ),
                            child: const Text(
                              'Add Questions?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ))
                ],
              ),
            ),
          ),
        ),
        endDrawer: widget.loginType == LoginType.patient
            ? const AppDrawerNavigation(loginType: LoginType.patient)
            : const AppDrawerNavigation(loginType: LoginType.caregiver),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
