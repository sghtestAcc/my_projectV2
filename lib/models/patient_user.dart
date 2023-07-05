
import 'package:flutter/material.dart';

class PatientModel {
  final String? id;
  final String? Email;
  final String? Name;
   final String? Password;
  
  const PatientModel({
    this.id,
    required this.Email,
    required this.Name,
    required this.Password,
  });

  toJson() {
    return {
      'Name' : Name,
      'Email' : Email,
      'Password' : Password,
    };
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


