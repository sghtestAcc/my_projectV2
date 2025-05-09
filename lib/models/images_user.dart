import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_type.dart';

class ImagesUser {
  final String? id;
  final String? images;

  const ImagesUser({
    this.id,
    required this.images,
  });

  ImagesUser copy({
    String? id,
    String? images,
  }) =>
      ImagesUser(
        id: id ?? this.id,
        images: images ?? this.images,
      );

  toJson() {
    return {
      'images': images,
    };
  }

  factory ImagesUser.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return ImagesUser(
      id: document.id,
      images: data["images"],
      // question: data["Question"],
    );
  }

}
