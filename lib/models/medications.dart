import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String labels;
  final String pills;
  final String quantity;
  final String schedule;
  final String email;

  const Medication({
    this.id,
    required this.labels,
    required this.pills,
    required this.quantity,
    required this.schedule,
    required this.email,
  });

  toJson() {
    return {
      'Labels': labels,
      'Pills': pills,
      'Quantity': quantity,
      'Schedule': schedule,
      'Email': email,
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
    );
  }

  Medication copy({
    String? id,
    String? labels,
    String? pills,
    String? quantity,
    String? schedule,
    String? email,
  }) =>
      Medication(
        id: id ?? this.id,
        labels: labels ?? this.labels,
        pills: pills ?? this.pills,
        quantity: quantity ?? this.quantity,
        schedule: schedule ?? this.schedule,
        email: email ?? this.email,
      );
}
