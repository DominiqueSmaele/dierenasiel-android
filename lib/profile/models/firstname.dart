import 'package:formz/formz.dart';

enum FirstnameValidationError { empty }

class Firstname extends FormzInput<String, FirstnameValidationError> {
  const Firstname.pure() : super.pure('');
  const Firstname.dirty([super.value = '']) : super.dirty();

  @override
  FirstnameValidationError? validator(String value) {
    if (value.isEmpty) return FirstnameValidationError.empty;
    return null;
  }
}
