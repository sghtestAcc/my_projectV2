import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';

class CameraHomePatientPillScreen extends StatefulWidget {
  final String? path;
  final String? imagetakenText;
  final XFile? imagetakenPill;

  const CameraHomePatientPillScreen({Key? key, this.path, this.imagetakenText,this.imagetakenPill}) : super(key: key);
  @override
  State<CameraHomePatientPillScreen> createState() =>
      _CameraHomePatientPillScreenState();
}

class _CameraHomePatientPillScreenState extends State<CameraHomePatientPillScreen> {
  bool textScanning = false;

  XFile? imageFilepills;


  String scannedTextpills = "";
  File? croppedImageFile;

  TextEditingController controller = TextEditingController();

  String compressedImagePath = "/storage/emulated/0/Download/";

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
                    'assets/images/Grace-bg-new-edited.png',
                  ),
                  fit: BoxFit.contain)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            ' Upload for Medication Pills',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
           const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                pickImage(source: ImageSource.camera).then((value) {
                  if (value != '') {
                    imageCropperView(value, context);
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
              child: const Text(
                'Capture Photo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                pickImage(source: ImageSource.gallery).then((value) {
                  if (value != '') {
                    imageCropperView(value, context);
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
              child: const Text(
                'Photo Files',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const NavigatorBar(
                //               loginType: LoginType.patient,
                //             )));
                // Navigator.of(context)
                // .push(MaterialPageRoute(builder: (_) => PatientUploadMedsScreen(imagetaken: imageFilepills)));  
                if (imageFilepills == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select an image Pill')),
                );
                } else {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PatientUploadMedsScreen(imagetakenText: widget.imagetakenText,imagetakenPill: imageFilepills)));  
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
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 20,
          ),
          if (!textScanning && imageFilepills == null)
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300]!,
            ),
          if (imageFilepills != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 200,
              child: Image.file(
                File(imageFilepills!.path),
                fit: BoxFit.fitWidth,
              ),
            ),
        
          // const SizedBox(
          //   height: 10,
          // ),
          // Column(
          //   children: [
          //     // Text(scannedText),
          //     Row(
          //       children: [
          //         Expanded(
          //           child: Container(
          //             padding: const EdgeInsets.all(20),
          //             child: TextFormField(
          //               style: const TextStyle(
          //                 color: Colors.black,
          //               ),
          //               controller: controller,
          //               maxLines: 1,
          //               enabled: false,
          //               decoration: const InputDecoration(
          //                 hintText: "Your Medication will appear here...",
          //                 border:
          //                     InputBorder.none, // Set this to remove the border
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //   ],
          // ),
        ]),
      ),
    );
  }



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
      ] ,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropping Images for Medication Pills',
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
      imageFilepills = XFile(croppedFile.path);
      // });
    } else {
      // return '';
      log('do nothing');
    }
  }

    void getRecognisedText(XFile image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final inputImage = InputImage.fromFilePath(image.path);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    scannedTextpills = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedTextpills += "${line.text} ";
      }
    }
    controller.text = scannedTextpills; // Set the value of the TextEditingController to the scanned text
    textScanning = false;
    setState(() {});
  }

  Future<String> pickImage({ImageSource? source}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage = await picker.pickImage(source: source!,imageQuality: 50);
      if (getImage != null) {
        path = '';
        textScanning = true;
        imageFilepills = getImage;
           final compressedFile = await FlutterImageCompress.compressAndGetFile(imageFilepills!.path,"$compressedImagePath/file1.jpg",
          quality: 5,
          );
          imageFilepills = XFile(compressedFile!.path);
          path = getImage.path;
          setState(() {});
          getRecognisedText(getImage);
      } else {
        path = '';
      }
    } catch (e) {
      textScanning = false;
      imageFilepills = null;
      scannedTextpills = "Error occured while scanning";
      setState(() {});

      log(e.toString());
    }
    return path;
  }
}