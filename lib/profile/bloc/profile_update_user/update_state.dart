part of 'update_bloc.dart';

final class ProfileUpdateState extends Equatable {
  const ProfileUpdateState({
    this.status = FormzSubmissionStatus.initial,
    this.firstname = const Firstname.pure(),
    this.lastname = const Lastname.pure(),
    this.email = const Email.pure(),
    this.isValid = false,
    this.error = '',
  });

  final FormzSubmissionStatus status;
  final Firstname firstname;
  final Lastname lastname;
  final Email email;
  final bool isValid;
  final String error;

  ProfileUpdateState copyWith({
    FormzSubmissionStatus? status,
    Firstname? firstname,
    Lastname? lastname,
    Email? email,
    bool? isValid,
    String? error,
  }) {
    return ProfileUpdateState(
      status: status ?? this.status,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, firstname, lastname, email];
}
