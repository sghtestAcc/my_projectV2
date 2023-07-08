class RegisterFailure {
  final String message;

  const RegisterFailure({required this.message});

  factory RegisterFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const RegisterFailure(
          message: 'Email is not valid.',
        );
      case 'operation-not-allowed':
        return const RegisterFailure(
          message: 'Operation is not allowed. Please contact support.',
        );
      case 'wrong-password':
        return const RegisterFailure(
          message: 'Your password is invalid.',
        );
      default:
        return const RegisterFailure(
          message: "An Unknown error occured.",
        );
    }
  }
}
