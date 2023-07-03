
import 'package:flutter/material.dart';

class PatientModel {
  final String? id;
  final String? Email;
  final String? Name;
   final String? Password;
  // final String? Labels;
  // final Image? Pills;
  // final String? Quantity;
  // final String? Schedules;
  
  const PatientModel({
    this.id,
    required this.Email,
    required this.Name,
    required this.Password,
    // this.Labels,
    // this.Pills,
    // this.Quantity,
    // this.Schedules
  });

  toJson() {
    return {
      'Name' : Name,
      'Email' : Email,
      'Password' : Password,
    };
  }
}