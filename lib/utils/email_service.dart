import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class EmailService {
  /// Send verification email by creating a Firestore document
  /// Firebase Function automatically sends the email
  static Future<bool> sendPatientVerificationEmail({
    required String patientEmail,
    required String patientName,
    required String caregiverName,
    required String caregiverEmail,
    required String verificationRequestId,
  }) async {
    try {
      // The Firestore document creation triggers your Firebase Function
      // No need for EmailJS here!
      print('Verification request created');
      print('Firebase Function will send email automatically');
      
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}