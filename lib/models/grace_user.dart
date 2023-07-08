import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_type.dart';

class GraceUser {
  final String? id;
  final String? email;
  final String? name;
  final LoginType loginType;

  const GraceUser({
    this.id,
    required this.email,
    required this.name,
    required this.loginType,
  });

  GraceUser copy({
    String? id,
    String? email,
    String? name,
    LoginType? loginType,
  }) =>
      GraceUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        loginType: loginType ?? this.loginType,
      );

  toJson() {
    return {
      'Name': name,
      'Email': email,
      'LoginType': loginType.name,
    };
  }

  factory GraceUser.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return GraceUser(
      id: document.id,
      email: data["Email"],
      name: data["Name"],
      loginType: LoginType.values.firstWhere(
        (element) => element.name == data['LoginType'],
      ),
    );
  }
}
