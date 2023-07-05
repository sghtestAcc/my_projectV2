import 'dart:core';

class LogInFailure {
  final String message;

  const LogInFailure([this.message = "An Unknown error occured."]);

  factory LogInFailure.code(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInFailure('Email is not valid.');
      case 'operation-not-allowed':
        return const LogInFailure(
            'Operation is not allowed. Please contact support.');
      case 'wrong-password':
        return const LogInFailure('Your password is invalid.');
      default:
        return const LogInFailure();
    }
  }
  static fromCode(String code) {}
}