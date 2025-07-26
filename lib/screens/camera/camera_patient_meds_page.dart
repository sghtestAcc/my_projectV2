import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_capture/multi_image_capture.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/camera/camera_patient_pills_page.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/models/translated_text_line.dart';
import 'package:my_project/utils/gpt_utils.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../components/navigation_drawer_new.dart';

class CameraHomePatientScreen extends StatefulWidget {
  final String? path;

  const CameraHomePatientScreen({Key? key, this.path}) : super(key: key);
  @override
  State<CameraHomePatientScreen> createState() =>
      _CameraHomePatientScreenState();
}

class TranslatedTextPainter extends CustomPainter {
  final List<TranslatedTextLine> translatedLines;
  final Size originalImageSize;
  final Size displayedImageSize;

  TranslatedTextPainter({
    required this.translatedLines,
    required this.originalImageSize,
    required this.displayedImageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 1.0;

    // Scale ratios
    final scaleX = displayedImageSize.width / originalImageSize.width;
    final scaleY = displayedImageSize.height / originalImageSize.height;

    for (final line in translatedLines) {
      final Rect scaledBox = Rect.fromLTRB(
        line.boundingBox.left * scaleX,
        line.boundingBox.top * scaleY,
        line.boundingBox.right * scaleX,
        line.boundingBox.bottom * scaleY,
      );

      // Background white box
      canvas.drawRect(
        scaledBox.inflate(4),
        Paint()..color = Colors.white.withOpacity(0.7),
      );
      canvas.drawRect(scaledBox, borderPaint);

      // Auto-size logic
      final maxWidth = scaledBox.width;
      final maxHeight = scaledBox.height;

      double fontSize = 14;
      TextPainter textPainter;

      do {
        final textSpan = TextSpan(
          text: line.translatedText,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            fontFamily: 'NotoSansSC',
          ),
        );

        textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );

        textPainter.layout(maxWidth: maxWidth);

        fontSize -= 0.5;
        if (fontSize < 6) break; // prevent font from becoming too small
      } while (textPainter.height > maxHeight || textPainter.width > maxWidth);

      textPainter.paint(canvas, scaledBox.topLeft);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

List<TranslatedTextLine> translatedLines = [];

class _CameraHomePatientScreenState extends State<CameraHomePatientScreen> {
  bool textScanning = false;
  List<XFile> imageFiles = [];
  String scannedText = "";
  TextEditingController controller = TextEditingController();
  TextEditingController quantityController = TextEditingController(); // NEW
  TextEditingController dosageController = TextEditingController(); // NEW
  TextEditingController instructionsController = TextEditingController(); // NEW
  TextEditingController detailsController = TextEditingController(); // NEW

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/final-grace-background.png',
                  ),
                  fit: BoxFit.contain)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 1,
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.uploadmedicationpackaging,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () async {
                  // Open MultiImageCapture screen for multi-photo capture
                  final List<XFile> capturedFiles = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiImageCapture(
                        onAddImage: (file) async {
                          setState(() {
                            imageFiles.add(XFile(file.path));
                          });
                        },
                        onRemoveImage: (file) async {
                          return true;
                        },
                        onComplete: (files) async {},
                      ),
                    ),
                  );
                  // After MultiImageCapture closes, add images to your list and refresh UI
                  if (capturedFiles != null && capturedFiles.isNotEmpty) {
                    setState(() {
                      imageFiles.addAll(capturedFiles);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CE25C),
                  minimumSize: const Size(320, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.capturephoto,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  // onPressed: () async {
                  // // Pick multiple images using the ImagePicker
                  //   final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

                  //   if (selectedImages != null && selectedImages.isNotEmpty) {
                  //     // Add the selected images to your list and update UI
                  //     setState(() {
                  //       imageFiles.addAll(selectedImages);  // Add all selected images to imageFilepills list
                  //     });
                  //   }
                  // },
                  onPressed: () {
                    // Pick multiple images using pickMultiImage
                    pickImages().then((selectedImages) {
                      if (selectedImages.isNotEmpty) {
                        setState(() {
                          imageFiles.addAll(
                              selectedImages); // Add sel ected images to the list
                        });

                        // Directly process each selected image for text recognition
                        getRecognisedText(
                            selectedImages); // Recognize text for all selected images
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    minimumSize: const Size(320, 50), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corner radius
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.uploadphoto,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (imageFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .medicationpackageempty)),
                      );
                    } else if (controller.text.isEmpty ||
                        controller.text.isEmpty) {
                      Get.snackbar(
                        AppLocalizations.of(context)!.snackbarInvalid,
                        AppLocalizations.of(context)!.medicationpackagenotext,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
                        colorText: Color(0xFFF6F3E7),
                      );
                      return;
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CameraHomePatientPillScreen(
                                imagetakenText: controller,
                                imageFiles: imageFiles,
                                quantity: quantityController.text,
                                dosage: dosageController.text,
                                instructions: instructionsController.text,
                                details: detailsController.text,
                              )));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    minimumSize: const Size(320, 50), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corner radius
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.selectpillphoto,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),

              const SizedBox(
                height: 20,
              ),
              // Image Display
              if (!textScanning && imageFiles.isEmpty)
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300]!,
                ),
              if (imageFiles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageFiles.length,
                    itemBuilder: (context, index) {
                      final file = File(imageFiles[index].path);
                      return FutureBuilder<Size>(
                        future: _getOriginalImageSize(file),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                                width: 150, height: 200); // Placeholder
                          }
                          final originalSize = snapshot.data!;
                          // Replace inside ListView.builder
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width -
                                  40, // screen width minus padding
                              height: 300, // increased height
                              child: Stack(
                                children: [
                                  Image.file(
                                    file,
                                    fit: BoxFit.cover, // Maintain aspect ratio
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 300,
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: TranslatedTextPainter(
                                        translatedLines: translatedLines,
                                        originalImageSize: originalSize,
                                        displayedImageSize: Size(
                                          MediaQuery.of(context).size.width -
                                              40,
                                          300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.translatedmedicalpackaging,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: TextFormField(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            controller: controller,
                            maxLines: 1,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.yourmedswillappearhere,
                              border: InputBorder
                                  .none, // Set this to remove the border
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
      endDrawer: AppDrawerNavigationNew(),
    );
  } //test

  Future<void> imageCropperView(String? path, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path!,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropping Images for Medication Labels',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      log('image cropped');
      imageFiles.add(XFile(croppedFile.path));
      getRecognisedText(imageFiles);
    } else {
      // return '';
      log('do nothing');
    }
  }
  //   void getRecognisedText(XFile image) async {
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final inputImage = InputImage.fromFilePath(image.path);
  //   final RecognizedText recognizedText =
  //       await textRecognizer.processImage(inputImage);
  //   await textRecognizer.close();
  //   scannedText = "";
  //   for (TextBlock block in recognizedText.blocks) {
  //     for (TextLine line in block.lines) {
  //       scannedText += "${line.text} ";
  //     }
  //   }
  //   controller.text = scannedText; // Set the value of the TextEditingController to the scanned text
  //   textScanning = false;
  //   setState(() {});
  // }

  // Function to pick multiple images
  Future<List<XFile>> pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    // Return the selected images, or an empty list if nothing is selected
    return pickedFiles ?? [];
  }

//   void getRecognisedText(List<XFile> images) async {
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     scannedText = "";

//     for (var image in images) {
//       final inputImage = InputImage.fromFilePath(image.path);
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           scannedText += "${line.text} ";
//         }
//       }
//     }

//     await textRecognizer.close();

//     controller.text = scannedText.trim(); // update controller with combined text
//     textScanning = false;
//     setState(() {});
// }

  Map<String, List<TranslatedTextLine>> translatedLinesMap = {};

  Future<void> getRecognisedText(List<XFile> images) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    translatedLines.clear();
    scannedText = "";

    for (var image in images) {
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          scannedText += "${line.text}\n"; // for GPT input

          try {
            final translated =
                await translateWithGPT(line.text, targetLanguage: "Chinese");

            translatedLines.add(
              TranslatedTextLine(
                boundingBox: line.boundingBox,
                translatedText: translated,
              ),
            );
          } catch (e) {
            log('Translation error: $e');
          }
        }
      }
    }

    await textRecognizer.close();

    // Pass combined text to GPT for structured info
    String gptResponse = "";
    try {
      gptResponse = await extractMedicationInfoWithGPT(scannedText);
    } catch (e) {
      gptResponse =
          '{"medication_name": "Error extracting", "dosage": "", "quantity": "", "instructions": "", "details": ""}';
    }

    Map<String, dynamic> extracted = {};
    try {
      extracted = jsonDecode(gptResponse);
    } catch (e) {
      extracted = {
        "medication_name": gptResponse,
        "dosage": "",
        "quantity": "",
        "instructions": "",
        "details": ""
      };
    }

    controller.text = extracted["medication_name"] ?? "";
    dosageController.text = extracted["dosage"] ?? "";
    instructionsController.text = extracted["instructions"] ?? "";
    quantityController.text = extracted["quantity"] ?? "";
    detailsController.text = extracted["details"] ?? "";

    textScanning = false;
    setState(() {}); // triggers repaint & UI update
  }

  Future<String> pickImage({ImageSource? source}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage =
          await picker.pickImage(source: source!, imageQuality: 50);
      if (getImage != null) {
        textScanning = true;

        setState(() {
          imageFiles.add(getImage);
        });

        path = getImage.path;
      } else {
        path = '';
      }
    } catch (e) {
      textScanning = false;
      scannedText = "Error occurred while scanning";
      setState(() {});
      log(e.toString());
    }
    return path;
  }

  Future<Size> _getOriginalImageSize(File file) async {
    final imageBytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  Future<String> extractMedicationInfoWithGPT(String scannedText) async {
    final String? apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found');
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            "role": "system",
            "content":
                "You are an assistant that helps to extract the medication name, dosage, total quantity, instructions (e.g. take orally 2 tablet(s) 3 times a day) and details (e.g. may cause drowsiness etc...) from the message. Return the result as a JSON object with keys: \"medication_name\", \"dosage\", \"quantity\", \"instructions\", \"details\". No extra text."
          },
          {
            "role": "user",
            "content":
                "Extract the medication info as JSON from the following message: $scannedText"
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      print('Failed to get response from server: ${response.body}');
      throw Exception('Failed to get response from server');
    }
  }

//   Future<String> extractMedicationName(String message) async {
//   final String apiKEY = dotenv.env['OPENAI_API_KEY']!;
//   final String apiURL = 'https://api.openai.com/v1/chat/completions';

//   final response = await http.post(
//     Uri.parse(apiURL),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $apiKEY',
//     },
//     body: jsonEncode({
//       "model": "gpt-3.5-turbo",
//       "messages": [
//         {
//           "role": "system",
//           "content": "You are an assistant that helps to extract the medication name from the message. Return the message only with the medication name, no additional text"
//         },
//         {
//           "role": "user",
//           "content": "Extract the medication name from the following message: $message"
//         }
//       ]
//     }),
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['choices'][0]['message']['content'];
//   } else {
//     print('Failed to get response from server: ${response.body}');
//     throw Exception('Failed to get response from server');
//   }
// }

  // Map<String, String> extractMedicationInfo(String fullText) {
  //   final Map<String, String> result = {
  //     "Medication Name": "",
  //     "Dosage": "",
  //     "Quantity": "",
  //     "Instructions": "",
  //     "Details": "",
  //   };

  //   final lines = fullText.split('\n');

  //   final List<String> commonMedNames = [
  //   "panadol", "paracetamol", "telfast", "ibuprofen", "amoxicillin", "cetirizine",
  //   "claritin", "zrytec", "aspirin", "tylenol", "diclofenac", "omeprazole",
  //   "metformin", "atorvastatin", "simvastatin", "losartan", "amlodipine",
  //   "prednisolone", "orphenadrine", "anarex", "augmentin", "naproxen",
  //   "gabapentin", "tramadol", "fexofenadine", "loratadine", "dextromethorphan"
  //   ];

  //   final List<String> detailKeywords = [
  //     "may cause drowsiness",
  //     "do not operate machinery",
  //     "avoid alcohol",
  //     "keep out of reach of children",
  //     "for external use only",
  //     "shake well before use",
  //     "do not exceed stated dose",
  //     "store below 25°c",
  //     "keep refrigerated",
  //     "for fever/pain/muscle relaxation",
  //     "contains paracetamol",
  //   ];

  //   List<String> detailsList = [];

  //   for (final line in lines) {
  //     final lower = line.toLowerCase();

  //   if (result["Medication Name"]!.isEmpty) {
  //     for (final med in commonMedNames) {
  //       if (lower.contains(med)) {
  //         result["Medication Name"] = line.trim();
  //         break;
  //       }
  //     }
  //   }

  //     // Improved dosage extraction: get the full phrase with name and dosage
  //     if (result["Dosage"]!.isEmpty &&
  //         RegExp(r'([a-zA-Z ]+\d+\s?(mg|g|ml|mcg))', caseSensitive: false).hasMatch(line)) {
  //       result["Dosage"] = RegExp(r'([a-zA-Z ]+\d+\s?(mg|g|ml|mcg))', caseSensitive: false)
  //         .firstMatch(line)?.group(0)?.trim() ?? "";
  //     }

  //     // Improved total quantity extraction
  //     if (result["Quantity"]!.isEmpty) {
  //       final quantityMatch = RegExp(
  //         r'(?:(?:qty|quantity|total)[:\s]*)?(\d+)\s*(tablets?|caplets?|tabs?|tab/s?)',
  //         caseSensitive: false,
  //       ).firstMatch(line);

  //       if (quantityMatch != null) {
  //         result["Quantity"] = "${quantityMatch.group(1)} ${quantityMatch.group(2)}";
  //       }
  //     }

  //     if (result["Instructions"]!.isEmpty &&
  //           RegExp(r'(take.*(?:tablet|tab|capsule|caplet).*)', caseSensitive: false).hasMatch(line)) {
  //         result["Instructions"] = line.trim();
  //       } else if (result["Instructions"]!.isEmpty &&
  //           (lower.contains("take") || lower.contains("orally"))) {
  //         result["Instructions"] = line.trim();
  //       }

  //     // Collect all matching details
  //       for (final keyword in detailKeywords) {
  //         if (lower.contains(keyword)) {
  //           detailsList.add(line.trim());
  //           break;
  //         }
  //       }
  //     }
  //     result["Details"] = detailsList.join('; ');
  //     return result;
  // }
}
