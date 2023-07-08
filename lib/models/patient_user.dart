import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String? id;
  final String? email;
  final String? name;
  final String? password;

  const PatientModel({
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

  factory PatientModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return PatientModel(
        id: document.id,
        email: data["Email"],
        password: data["Password"],
        name: data["Name"]);
  }
}


  // final String? Labels;
  // final Image? Pills;
  // final String? Quantity;
  // final String? Schedules;

  // this.Labels,
    // this.Pills,
    // this.Quantity,
    // this.Schedules


