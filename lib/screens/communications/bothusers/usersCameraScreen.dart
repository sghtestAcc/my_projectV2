import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../components/navigation.tab.dart';
import '../../../models/login_type.dart';

class RecognizePageBothUsers extends StatefulWidget {
  final String? path;
  const RecognizePageBothUsers({Key? key, this.path}) : super(key: key);

  @override
  State<RecognizePageBothUsers> createState() => _RecognizePageBothUsersState();
}

class _RecognizePageBothUsersState extends State<RecognizePageBothUsers> {
  bool _isBusy = false;

  TextEditingController controller = TextEditingController();
  String typedText = '';
  String? _translatedText;
  String sourceSelect = 'English';
  String targetSelect = 'English';
  bool _isLoading = false;

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
    final result = await onDeviceTranslator.translateText(controller.text);
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
  void initState() {
    super.initState();

    final InputImage inputImage = InputImage.fromFilePath(widget.path!);
    processImage(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: 
      //   AppBar(
      //   title: const Text(
      //     'PhotoScanner',
      //     style: TextStyle(color: Colors.black, fontSize: 25),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   centerTitle: true,
      // ),
      AppBar(
        title:  const Text(
          'PhotoScanner',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:  IconThemeData(color: Colors.black),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //   Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //   builder: (context) => 
        //   NavigatorBar(
        //   loginType: LoginType.patient),
        //   ));
        //   },
        // ),
      ),
        body: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
              children: [
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
              controller: controller,
              onChanged: translateTextFunction,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Enter text',
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
              ],
            ));
  }

  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    log(image.filePath!);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);

    controller.text = recognizedText.text;
    _translatedText = controller.text; 

    ///End busy state
    setState(() {
      _isBusy = false;
    });
  }
}