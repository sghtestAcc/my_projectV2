import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverModel {
  final String? id;
  final String? Email;
  final String? Name;
  final String? Password;

  const CaregiverModel({
    this.id,
    required this.Email,
    required this.Name,
    required this.Password,
  });

  toJson() {
    return {
      'Name': Name,
      'Email': Email,
      'Password': Password,
    };
  }

  factory CaregiverModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return CaregiverModel(
        id: document.id,
        Email: data["Email"],
        Password: data["Password"],
        Name: data["Name"]);
  }
}
