import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{
  final String? id;
  final String title;
  final String body;
  final String dateTime;

   const Notifications(
      {required this.id,
      required this.title,
      required this.body,
      required this.dateTime,
     });

     factory Notifications.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return Notifications(
      id: document.id,
      title: data["Title"],
      body: data["Body"],
      dateTime: data["DateTime"]
    );
  }
}