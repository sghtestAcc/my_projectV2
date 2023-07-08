import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverModel {
  final String? id;
  final String? email;
  final String? name;
  final String? password;

  const CaregiverModel({
    this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  toJson() {
    return {
      'Name': name,
      'Email': email,
      'Password': password,
    };
  }

  factory CaregiverModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return CaregiverModel(
        id: document.id,
        email: data["Email"],
        password: data["Password"],
        name: data["Name"]);
  }
}
