import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String labels;
  final String pills;
  final String quantity;
  final String schedule;
  final String? email;
  final String? name;

  const Medication({
    this.id,
    required this.labels,
    required this.pills,
    required this.quantity,
    required this.schedule,
    this.email,
    this.name
  });

  
  Medication copy({
    String? id,
    String? labels,
    String? pills,
    String? quantity,
    String? schedule,
    String? email,
    String? name
  }) =>
      Medication(
        id: id ?? this.id,
        labels: labels ?? this.labels,
        pills: pills ?? this.pills,
        quantity: quantity ?? this.quantity,
        schedule: schedule ?? this.schedule,
        email: email ?? this.email,
        name: name ?? this.name,
      );

  toJson() {
    return {
      'Labels': labels,
      'Pills': pills,
      'Quantity': quantity,
      'Schedule': schedule,
      'Email': email,
      'Name' : name
    };
  }

  factory Medication.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return Medication(
      id: document.id,
      labels: data["Labels"],
      pills: data["Pills"],
      quantity: data["Quantity"],
      schedule: data["Schedule"],
      email: data["Email"],
      name: data["Name"],
    );
  }

  // factory Medication.fromJson(
  //   Map<String, dynamic> jsonData,
  // ) {
  //   return Medication(
  //     labels: jsonData["Labels"],
  //     pills: jsonData["Pills"],
  //     quantity: jsonData["Quantity"],
  //     schedule: jsonData["Schedule"],
  //     email: jsonData["Email"],
  //     name: jsonData["Name"],
  //   );
  // }

  // static Map<String, dynamic> toListString(Medication medications) {
  //   return {
  //     'Labels': medications.labels,
  //     'Pills': medications.pills,
  //     'Quantity': medications.quantity,
  //     'Schedule': medications.schedule,
  //     'Email': medications.email,
  //     'Name' : medications.name
  //   };
  // }

  // // Format the list into string to store into Firebase
  // static String encode(List<Medication> medications) {
  //   return jsonEncode(medications.map<Map<String, dynamic>>((medications) => Medication.toListString(medications)).toList());
  // }

  // // Format the string back to list
  // static List<Medication> decode(String medicationsString) {
  //   return (jsonDecode(medicationsString) as List<dynamic>).map((item) => Medication.fromJson(item)).toList();
  // }

}
