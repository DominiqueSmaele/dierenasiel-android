part of 'register_bloc.dart';

final class RegisterState extends Equatable {
  const RegisterState({
    this.status = FormzSubmissionStatus.initial,
    this.firstname = const Firstname.pure(),
    this.lastname = const Lastname.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.error = '',
  });

  final FormzSubmissionStatus status;
  final Firstname firstname;
  final Lastname lastname;
  final Email email;
  final Password password;
  final bool isValid;
  final String error;

  RegisterState copyWith({
    FormzSubmissionStatus? status,
    Firstname? firstname,
    Lastname? lastname,
    Email? email,
    Password? password,
    bool? isValid,
    String? error,
  }) {
    return RegisterState(
      status: status ?? this.status,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, firstname, lastname, email, password];
}
