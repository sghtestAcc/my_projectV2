class RegisterFailure {
  final String message;

  const RegisterFailure([this.message = "An Unknown error occured."]);

  factory RegisterFailure.code(String code) {
    switch (code) {
      case 'invalid-email':
        return const RegisterFailure('Email is not valid.');
      case 'operation-not-allowed':
        return const RegisterFailure(
            'Operation is not allowed. Please contact support.');
      case 'wrong-password':
        return const RegisterFailure('Your password is invalid.');
      default:
        return const RegisterFailure();
    }
  }

  static fromCode(String code) {}
}