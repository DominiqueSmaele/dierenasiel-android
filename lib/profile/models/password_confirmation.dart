import 'package:formz/formz.dart';

enum PasswordConfirmationValidationError { empty, mismatch }

class PasswordConfirmation extends FormzInput<String, PasswordConfirmationValidationError> {
  const PasswordConfirmation.pure({this.password = ''}) : super.pure('');
  const PasswordConfirmation.dirty({required this.password, value = ''})
      : super.dirty(value);

  final String password;

  @override
  PasswordConfirmationValidationError? validator(String value) {
    if (value.isEmpty) return PasswordConfirmationValidationError.empty;
    if (password != value) return PasswordConfirmationValidationError.mismatch;
    return null;
  }
}