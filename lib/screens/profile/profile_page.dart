import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/repos/user_repo.dart';

import '../../controllers/select_patient_controller.dart';
import 'change_password_modal.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  XFile? imageFile;

  String profileuid = FirebaseAuth.instance.currentUser!.uid;
  final userRepo = Get.put(UserRepository());
  final controller = Get.put(SelectPatientController());

Future<String> pickImage({ImageSource? source,}) async {
    final picker = ImagePicker();
    String path = '';
    try {
      final getImage = await picker.pickImage(source: source!,imageQuality: 50);
      if (getImage != null) {
        path = '';
        imageFile = getImage;
        // Image.file(File(selectedImage!.path))
        // XFile? file = XFile(imageFile!.path); 
        // String fileName = file.path.split('/').last;
        // File(imageFile!.path),
        path = getImage.path;
        setState(() {});
      } else {
        path = '';
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
      log(e.toString());
    }

    return path;
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
            toolbarTitle: 'Cropping profile picture',
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

    } else {
      // return '';
      log('do nothing');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Profile',
    style: TextStyle(color: Colors.black, fontSize: 25),
  ),
  backgroundColor: Colors.transparent,
  automaticallyImplyLeading: false,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.black),
  centerTitle: true,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black, // Border color
        width: 2.0, // Border width
      ),
    ),
  ),
),
      body: SingleChildScrollView(
        child: Container(
           height: MediaQuery.of(context).size.height/ 1,
          child: Column(
            children: [
              // Image.asset('assets/images/new-sgh-design.png', height: 100, fit:BoxFit.cover,),
               SizedBox(height: 10,),
              
          Stack(
          children: [
              StreamBuilder(
          stream: userRepo.getUserimages(profileuid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a static image when waiting for data or loading
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/user.png', fit: BoxFit.contain),
          );
            } else if (snapshot.hasError) {
          // Show an error message if there is an error with the stream
          return Center(child: Text(snapshot.error.toString()));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 128,
                width: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Set the color of the border here
                    width: 2.0, // Set the width of the border here
                  ),
                ),
                child:
                imageFile != null
                    ?
                ClipOval(
                        child: Image.file(
                          File(imageFile!.path),
                          height: 128,
                          width: 128,
                          fit: BoxFit.contain,
                        ),
                      )
              : Image.asset('assets/images/user.png',
                        fit: BoxFit.contain,
                      ),
            )
              );
            } else if(snapshot.hasData) {
          // Show the streamed image data
          var userimages = snapshot.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 128,
              width: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Set the color of the border here
                  width: 2.0, // Set the width of the border here
                ),
              ),
              child:  ClipOval(
                      child: Image.network(
                        userimages?.images ?? '',
                        height: 128,
                        width: 128,
                        fit: BoxFit.contain,
                      ),
                    )
            ),
          );
            } else {
              return Column(
                children: [
                  ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 128,
                    width: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black, // Set the color of the border here
                        width: 2.0, // Set the width of the border here
                      ),
                    ),
                    child:
                    Column(
                      children: [
                          if (imageFile != null)
                            ClipOval(
                            child: Image.file(
                              File(imageFile!.path),
                              height: 128,
                              width: 128,
                              fit: BoxFit.contain,
                            ),
                          ),
                      ],)
            )
                  ),

                ],
              );
            }
          },
              ),   
            Positioned(
          bottom: 8, // Adjust the position of the button as needed
          right: 8, // Adjust the position of the button as needed
          child: Transform.translate(
          offset: Offset(0, 8), // Adjust the vertical shift to your desired position
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1), // Adjust the border color and width as needed
              color: Color(0xFF999999), // Replace this with your desired background color
            ),
            child: IconButton(
              onPressed: () {
                 pickImage(source: ImageSource.gallery).then((value) {
                      if (value != '') {
                        imageCropperView(value, context);
                      }
                    });
                // Add your button onPressed logic here
              },
              icon: Icon(Icons.edit), // Replace this with your desired icon
              iconSize: 30, // Adjust the icon size as needed
              color: Colors.white, // Replace this with your desired icon color
            ),
          ),
          ),
            ),
          ],
              ),
              const SizedBox(height: 20,),
              FutureBuilder(
          future: controller.getPatientData(),
          builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasData) {
              var patientsInfo = snapshot.data;
                  return Container(
          padding: EdgeInsets.all(20.0),
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1), 
          borderRadius: BorderRadius.circular(12),
          ),
          child: 
          Column(
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Password:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                GestureDetector(
                  onTap: () {
                     ChangePasswordModal(context);
                  },
                  child: Text("edit", style: 
                  TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),)
              ],
              ),
              const Divider(
              color: Colors.black, // Adjust the color of the separator line as needed
              thickness: 1, // Adjust the thickness of the separator line as needed
            ),
              const SizedBox(height: 10,),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                Text('${patientsInfo?.email}', style: const TextStyle(fontSize: 20),),
              ],
              ),
              const Divider(
              color: Colors.black, // Adjust the color of the separator line as needed
              thickness: 1, // Adjust the thickness of the separator line as needed
            ),
              const SizedBox(height: 10,),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Full Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Text('${patientsInfo?.name}', style: const TextStyle(fontSize: 20),),
              ],
              ),
              const Divider(
              color: Colors.black, // Adjust the color of the separator line as needed
              thickness: 1, // Adjust the thickness of the separator line as needed
            ),
            const SizedBox(height: 10,), 
            ],
          ),
            );
            }  else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
            } else {
            return const Center(
            child: Text('Something went wrong'));
            }
           } else {
            return const Center(child: CircularProgressIndicator());
            }
              
          }
              ),
               Container(
          padding: EdgeInsets.all(20.0),
          width: double.infinity,
           child: ElevatedButton(
                    onPressed: () {
                      UserRepository.instance.addImage(imageFile,profileuid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0CE25C),
                      // minimumSize: const Size(320, 50), // NEW
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corner radius
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    )),
               ),
          ],
          ),
        ),
      ),
    );
  }
}