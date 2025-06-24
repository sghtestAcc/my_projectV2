import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String labels;
  final List<String> pills;
  final List<String> packaging;
  final String? quantity;
  final String? dosage;
  final String? email;
  final String? name;
  final String? instructions;
  final String? details;

  const Medication({
    this.id,
    required this.labels,
    required this.pills,
    required this.packaging, 
    this.quantity,
    this.dosage,
    this.email,
    this.name,
    this.instructions,
    this.details,
  });

  Medication copy({
    String? id,
    String? labels,
    List<String>? pills, 
    List<String>? packaging,
    String? quantity,
    String? dosage,
    String? email,
    String? name,
    String? instructions,
    String? details,
  }) =>
      Medication(
        id: id ?? this.id,
        labels: labels ?? this.labels,
        pills: pills ?? this.pills,
        packaging: packaging ?? this.packaging,
        quantity: quantity ?? this.quantity,
        dosage: dosage ?? this.dosage,
        email: email ?? this.email,
        name: name ?? this.name,
        instructions: instructions ?? this.instructions,
        details: details ?? this.details,
      );

  toJson() {
    return {
      'Labels': labels,
      'Pills': pills,
      'Packaging': packaging,
      'Quantity': quantity,
      'Dosage': dosage,
      'Email': email,
      'Name' : name,
      'Instructions': instructions,
      'Details': details,
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
      quantity: data["Quantity"],
      dosage: data["Dosage"],
      email: data["Email"],
      name: data["Name"],
      instructions: data["Instructions"],
      details: data["Details"],
    );
  }
}
