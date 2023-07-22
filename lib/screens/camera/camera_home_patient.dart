import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/components/navigation.tab.dart';
import 'package:my_project/models/login_type.dart';
import 'package:my_project/screens/camera/camera_home_patient_pill.dart';
import 'package:my_project/screens/camera/patients_upload_meds.dart';

import '../../components/navigation_drawer_new.dart';

class CameraHomePatientScreen extends StatefulWidget {
  final String? path;

  const CameraHomePatientScreen({Key? key, this.path}) : super(key: key);
  @override
  State<CameraHomePatientScreen> createState() =>
      _CameraHomePatientScreenState();
}

class _CameraHomePatientScreenState extends State<CameraHomePatientScreen> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";
  // File? croppedImageFile;

  TextEditingController controller = TextEditingController();

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
            ' Upload for Medication Labels',
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                // getImage(ImageSource.gallery);
                // pickImage(source: ImageSource.gallery);
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              )),
          const SizedBox(
            height: 20,
          ),
              ElevatedButton(
              onPressed: () { 
                if (imageFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select an Medication Label image')),
                );
                } else {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CameraHomePatientPillScreen(imagetakenText: controller)));  
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
                'Select Medication Pills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              )),

          const SizedBox(
            height: 20,
          ),
          if (!textScanning && imageFile == null)
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300]!,
            ),
          if (imageFile != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 200,
              child: Image.file(
                File(imageFile!.path),
                fit: BoxFit.fitWidth,
              ),
            ),
        
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                'Translated Medication Label:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        decoration: const InputDecoration(
                          hintText: "Your Medication will appear here...",
                          border:
                              InputBorder.none, // Set this to remove the border
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
   endDrawer: AppDrawerNavigationNew(),
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
      imageFile = XFile(croppedFile.path);
      getRecognisedText(imageFile!);
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

    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText += "${line.text} ";
      }
    }
    controller.text = scannedText; // Set the value of the TextEditingController to the scanned text
  
    textScanning = false;
    setState(() {});
  }


  Future<String> pickImage({ImageSource? source,}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage = await picker.pickImage(source: source!,imageQuality: 50);
      if (getImage != null) {
        path = '';
        textScanning = true;
        imageFile = getImage;
        // Image.file(File(selectedImage!.path))
        XFile? file = XFile(imageFile!.path); 
        String fileName = file.path.split('/').last;
        // File(imageFile!.path),

        print(await file.length());
        print(fileName);
        path = getImage.path;
        setState(() {});
        // getRecognisedText(getImage);
      } else {
        path = '';
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
      log(e.toString());
    }

    return path;
  }

}