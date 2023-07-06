import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/navigation.tab.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: CameraHomeScreenPatient(),
    ));


    class CameraHomeScreenPatient extends StatefulWidget {
      final String? path;

  const CameraHomeScreenPatient({Key? key, this.path}) :super(key: key);
  @override
  State<CameraHomeScreenPatient> createState() => _CameraHomeScreenPatientState();
}

class _CameraHomeScreenPatientState extends State<CameraHomeScreenPatient> {
  @override


  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";
  File? croppedImageFile;

  TextEditingController controller = TextEditingController();

  void initState() {

    super.initState();
   
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/Grace-bg-new-edited.png',
                  ),
                  fit: BoxFit.contain
              )
          ),
        ),
        backgroundColor: Colors.white, 
        iconTheme: IconThemeData(color: Colors.black), 
      ), 
      body: 
      Container(
        child: Center(
          child: 
            Column(children: [
              SizedBox(height: 20,),
      Text(' Upload for Medication Labels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),
        Text('First Time users must', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        Text('upload a photo or', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        Text('snap a photo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),

         ElevatedButton(
          onPressed: () {
              // getImage(ImageSource.camera);
              // getImage(ImageSource.camera);
              pickImage(source: ImageSource.camera).then((value) {
                if(value != '') {
                  imageCropperView(value, context);
                }
              });
            },
           style: 
           ElevatedButton.styleFrom(
          primary: Color(0xFF0CE25C),
          minimumSize: const Size(320,50), // NEW
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corner radius
         ),
        ),
           child: Text('Capture Photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
           ),
    SizedBox(height: 20,),
           ElevatedButton(
          onPressed: () {        
              // getImage(ImageSource.gallery);
              // pickImage(source: ImageSource.gallery);
              pickImage(source: ImageSource.gallery).then((value) {
                if(value != '') {
                  imageCropperView(value, context);
                }
              });
            },
           style: 
           ElevatedButton.styleFrom(
          primary: Color(0xFF0CE25C),
          minimumSize: const Size(320,50), // NEW
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corner radius
         ),
        ),
           child: Text('Photo Files', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
           ),
    SizedBox(height: 20,),
            ElevatedButton(
          onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              Navigator.push(context, MaterialPageRoute(builder: (context)=> NavigatorBar(loginType: LoginType4.patientsLoginBottomTab,)));
            },
           style: 
           
           ElevatedButton.styleFrom(
          primary: Color(0xFF0CE25C),
          minimumSize: const Size(320,50), // NEW
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corner radius
         ),
        ),
           child: Text('Continue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
           ),
           SizedBox(height: 20,),
           if (!textScanning && imageFile == null)
           Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300]!,
                  ),     
            if (imageFile != null)
  Container(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
    height: 200,
    child: Image.file(File(imageFile!.path),
    fit: BoxFit.fitWidth,),
  ), 
  //  if (imageFile != null) 
  //     Container(
  //       padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
  //       height: 200,
  //       child: Image.file(
  //         File(imageFile!.path),
  //         fit: BoxFit.fitWidth,
  //       ),
  //     ),
  //   if (croppedImageFile != null) 
  //     Container(
  //       padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
  //       height: 200,
  //       child: Image.file(File(croppedImageFile!.path),
  //         fit: BoxFit.fitWidth,
  //       ),
  //     ),
  //      Container(
  //       width: 200,
  //       height: 200,
  //       color: Colors.grey[300]!,
  //     ),
    
  SizedBox(height: 10,),
 Column(
      children: [
         Text('Translated Medication Label:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        // Text(scannedText),
         Row(
          children: [
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                     style: TextStyle(
                    color: Colors.black, 
                  ),
                    controller: controller,
                    maxLines: 1,
                    enabled: false,
                        decoration: InputDecoration(
    hintText: "Your Medication will appear here...",
    border: InputBorder.none, // Set this to remove the border
  ),
  
                  ),
              ),
            )
          ],
         ),
      ],
    ),
 
            ]),
          )
      ),
    );
  }

// ({ImageSource? source})

 Future<void> imageCropperView(String? path,BuildContext context) async {

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path!,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper for first image',
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

    if(croppedFile != null) {
      log('image cropped');
      // return imageFile =croppedFile.path;
      // setState(() {
      //   imageFile = null;
      //   croppedImageFile = croppedFile;
      // });
    } else {
      // return '';
      log('do nothing');
    }
  }



  Future<String> pickImage({ImageSource? source}) async {
  final picker = ImagePicker();
  String path = '';
  try {
    final getImage = await picker.pickImage(source: source!);
    if (getImage != null) {
      path = '' ;
      textScanning = true;
      imageFile = getImage;
      path = getImage.path;
      setState(() {});
      getRecognisedText(getImage);
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

void getRecognisedText(XFile image) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final inputImage = InputImage.fromFilePath(image.path);

  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

  await textRecognizer.close();

  scannedText = "";
  for (TextBlock block in recognizedText.blocks) {
    for (TextLine line in block.lines) {
      scannedText += line.text + " ";
    }
  }
  
  controller.text = scannedText; // Set the value of the TextEditingController to the scanned text

  textScanning = false;
  setState(() {});
}


  // Future<String> getImage({ImageSource? source}) async {
  //    String path = '';
  //    try {
  //     final pickedImage = await ImagePicker().pickImage(source: source!);
  //     if (pickedImage != null) {
  //       textScanning = true;
  //       imageFile = pickedImage;
  //       setState(() {});
  //       getRecognisedText(pickedImage);
  //     }
  //   } catch (e) {
  //     textScanning = false;
  //     imageFile = null;
	//     scannedText = "Error occured while scanning";
  //     setState(() {});
  //   }
  // }
}