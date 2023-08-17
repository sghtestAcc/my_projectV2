import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:my_project/components/navigation_drawer.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/repos/user_repo.dart';
// import 'package:my_project/screens/communications/communications_patient.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CaregviersVocalScreen extends StatefulWidget {
  final String? patientUid;

  const CaregviersVocalScreen({super.key,this.patientUid});
  
  @override
  State<CaregviersVocalScreen> createState() => _CaregviersVocalScreenState();
}

final userRepo = Get.put(UserRepository());

class _CaregviersVocalScreenState extends State<CaregviersVocalScreen> {
  String? _translatedText;
  final _controller = TextEditingController();
  String sourceSelect = 'English';
  String targetSelect = 'English';
  bool _isLoading = false;

  String typedText = '';

  //traslate text function of medication label
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
  // PatientHomeScreen
    SpeechToText speechToText = SpeechToText();

  var isListening = false;
  var containedtext = 'coms';

String text = 'Hello world';
  final FlutterTts flutterTts = FlutterTts();
// function to get text to speech of medication labels/name
  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }
          // endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
// widget.patientUid
  @override
  Widget build(BuildContext context) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text(
              'Vocalization',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
          ),
          body: Column(children: [
            Column(
              children: [
                Container(
                  color: const Color(0xFF9EE8BF),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                  child: const Text(
                    'Translate Medication',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Enter Text",
                    suffixIcon: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // icon button with paste function of medication label/name
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
                          child: Icon(Icons.paste),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.all(10.0),
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
                    style:
                        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                StreamBuilder<List<Medication>>(
                  stream: userRepo.getAllPatientMedications(widget.patientUid),
                  builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }  else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Center(
                child: const Text('No questions added yet'),
                );
            } else if (snapshot.hasData) {
              return Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 175,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, _) => const SizedBox(
                          width: 10,
                        ),
                        itemBuilder: (context, index) => 
                        Container(
                            padding: const EdgeInsets.all(10.0),
                            width: 125,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(22)),
                              color: const Color(0xFFF6F6F6),
                              boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                              ],
                              border: Border.all(
                    color: Colors.black, // Set your desired border color here
                    width: 1, // Set the border width
                              ),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                     Text(snapshot.data![index].labels),
                    const SizedBox(height: 10),
                     ElevatedButton(
                    onPressed: () {
                      speak(snapshot.data![index].labels);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Color(0xff00A67E),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: Icon(
                        Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),
                              ),
                              // icon button with copy function of medication label/name
                              IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: snapshot.data![index].labels)).then(
                          (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to your clipboard !'),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                              ],
                            ),
                          )
                      ),
                    );
            }  else {
        return const Center(child: Text('Something went wrong'));
      } 
                  }
                ),
              ],
            )
          ]),
          endDrawer: const AppDrawerNavigation(loginType: LoginType.caregiver),
        );
  }
}
