import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class RegisterFailure {
  final String message;

  const RegisterFailure({required this.message});

  factory RegisterFailure.fromCode(String code, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    switch (code) {
      case 'invalid-email':
        return RegisterFailure(message: localizations.invalidEmailError);
      case 'operation-not-allowed':
        return RegisterFailure(message: localizations.operationNotAllowedError);
      case 'wrong-password':
        return RegisterFailure(message: localizations.wrongPasswordError);
      default:
        return RegisterFailure(message: localizations.emailExistsError);
    }
  }
}
