import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_capture/multi_image_capture.dart';
import 'package:my_project/screens/camera/patients_upload_meds_page.dart';

import '../../components/navigation_drawer_new.dart';

class CameraHomePatientPillScreen extends StatefulWidget {
  final String? path;
  final TextEditingController? imagetakenText;
  final List<XFile> imagetakenPills;

  const CameraHomePatientPillScreen({
    Key? key, 
    this.path, 
    this.imagetakenText,
    this.imagetakenPills = const [],
    }) : super(key: key);
  @override
  State<CameraHomePatientPillScreen> createState() =>
      _CameraHomePatientPillScreenState();
}

class _CameraHomePatientPillScreenState extends State<CameraHomePatientPillScreen> {
  bool textScanning = false;
  List<XFile> imageFilepills = [];
  String scannedTextpills = "";
  List<File> croppedImageFile = [];


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
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height/ 1,
          child: Center(
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
                onPressed: () async {
                  final List<File> capturedFiles = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiImageCapture(
                        onAddImage: (file) async {},
                        onRemoveImage: (file) async {return true;},
                        onComplete: (files) async {
                          Navigator.pop(context, files);  // <-- this will close camera screen
                        },
                      ), 
                    )
                  ); // <-- uses your new function
                  setState(() {
                    imageFilepills.addAll(
                      capturedFiles.map((file) => XFile(file.path)),
                    );
                  }); 
                  return;
                  // onPressed: () {
                  //   pickImage(source: ImageSource.camera).then((value) {
                  //     if (value != '') {
                  //       imageCropperView(value, context);
                  //     }
                  //   });
                  // },
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    minimumSize: const Size(320, 50), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corner radius
                    ),
                  ),
                child: const Text(
                  'Capture Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                )
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

                    if (selectedImages != null && selectedImages.isNotEmpty) {
                      setState(() {
                        imageFilepills.addAll(selectedImages);
                      });
                    }
                  },
                  //      pickImage(source: ImageSource.gallery).then((value) {
                  //     if (value != '') {
                  //       imageCropperView(value, context);
                  //     }
                  //   });
                  // },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CE25C),
                    minimumSize: const Size(320, 50), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corner radius
                    ),
                  ),
                  child: const Text(
                    'Upload Photo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (imageFilepills.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an image Pill')),
                    );
                    } else {
                    Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => PatientUploadMedsScreen(imagetakenText: widget.imagetakenText,imagetakenPills: imageFilepills)));  
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  )),
              const SizedBox(
                height: 20,
              ),
              if (!textScanning && imageFilepills.isEmpty)
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300]!,
                ),
              // if (imageFilepills != null)
              //   Container(
              //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //     height: 200,
              //     child: Image.file(
              //       File(imageFilepills!.path),
              //       fit: BoxFit.fitWidth,
              //     ),
              //   ),
            if (imageFilepills.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageFilepills.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(imageFilepills[index].path),
                        width: 150,
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
      endDrawer: AppDrawerNavigationNew(),
    );
  }

//crop function for label/image scanner 
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
      imageFilepills.add(XFile(croppedFile.path));
    } else {
      log('do nothing');
    }
  }


//function to pick image by gallery and camera -patients-
  // Future<String> pickImage({ImageSource? source}) async {
  //   final picker = ImagePicker();
  //   String path = '';
  //   try {
  //     final getImage = await picker.pickImage(source: source!,imageQuality: 50);
  //     if (getImage != null) {
  //       path = '';
  //       textScanning = true;
  //       imageFilepills = getImage;
  //       // function to compress file size of image before adding the medication parameters
  //       // final compressedFile = await FlutterImageCompress.compressAndGetFile(imageFilepills!.path,"$compressedImagePath/file1.jpg",
  //       // quality: 5,
  //       //   );
  //       //   imageFilepills = XFile(compressedFile!.path);
  //         path = getImage.path;
  //         setState(() {});
  //     } else {
  //       path = '';
  //     }
  //   } catch (e) {
  //     textScanning = false;
  //     imageFilepills = null;
  //     scannedTextpills = "Error occured while scanning";
  //     setState(() {});
  //     log(e.toString());
  //   }
  //   return path;
  // }

  Future<String> pickImage({ImageSource? source}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage = await picker.pickImage(source: source!, imageQuality: 50);
      if (getImage != null) {
        textScanning = true;

        // ✅ Add this image to the list instead of replacing
        setState(() {
          imageFilepills.add(getImage);
        });

        path = getImage.path;
      } else {
        path = '';
      }
    } catch (e) {
      textScanning = false;
      scannedTextpills = "Error occurred while scanning";
      setState(() {});
      log(e.toString());
    }
    return path;
  }
  Future<void> captureAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? captured = await picker.pickImage(source: ImageSource.camera);

    if (captured != null) {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: captured.path,
        );

      if (cropped != null) {
        setState(() {
          imageFilepills.add(XFile(cropped.path)); // store cropped image
        });
      }
    }
  }

}