import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

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
              getImage(ImageSource.camera);
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
              getImage(ImageSource.gallery);
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
    // width: 225,
    // height: 225,
    child: Image.file(File(imageFile!.path),
    fit: BoxFit.fitWidth,),
  ), 
  SizedBox(height: 10,),
  Expanded(
    child: Column(
      children: [
         Text('Translated Medication Label:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        //  SizedBox(height: 15,),
         Row(
          children: [
           Text(scannedText,textAlign: TextAlign.center,style: TextStyle(fontSize: 18)),
          ],
         ),
        //  Text(scannedText, style: TextStyle(fontSize: 20),),
      ],
    ),
  ),
            ]),
          )
      ),
    );
  }

  void getImage(ImageSource? source) async {
     try {
      final pickedImage = await ImagePicker().pickImage(source: source!);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
	  scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

   void getRecognisedText(XFile image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final inputImage = InputImage.fromFilePath(image.path);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
  
    await textRecognizer.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

}