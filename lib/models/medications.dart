
import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String labels;
  final List<String> pills;
  final List<String> packaging;
  final String dosage;
  final String schedule;
  final String? quantity;
  final String? email;
  final String? name;

  const Medication({
    this.id,
    required this.labels,
    required this.pills,
    required this.packaging, 
    required this.dosage,
    required this.schedule,
    this.quantity,
    this.email,
    this.name
  });

  
  Medication copy({
    String? id,
    String? labels,
    List<String>? pills, 
    String? quantity,
    String? schedule,
    String? email,
    String? name
  }) =>
      Medication(
        id: id ?? this.id,
        labels: labels ?? this.labels,
        pills: pills ?? this.pills,
        packaging: packaging ?? this.packaging,
        dosage: dosage ?? this.dosage,
        schedule: schedule ?? this.schedule,
        email: email ?? this.email,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
      );

  toJson() {
    return {
      'Labels': labels,
      'Pills': pills,
      'Packaging': packaging,
      'Dosage': dosage,
      'Schedule': schedule,
      'Email': email,
      'Name' : name,
      'Quantity': quantity,
    };
  }

  factory Medication.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return Medication(
      id: document.id,
      labels: data["Labels"],
      pills: (data["Pills"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      packaging: (data["Packaging"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dosage: data["Dosage"] ?? '',
      schedule: data["Schedule"],
      email: data["Email"],
      name: data["Name"],
      quantity: data["Quantity"],
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
