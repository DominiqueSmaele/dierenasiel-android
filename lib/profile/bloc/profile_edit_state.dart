part of 'profile_edit_bloc.dart';

final class ProfileEditState extends Equatable {
  const ProfileEditState({
    this.status = FormzSubmissionStatus.initial,
    this.firstname = const Firstname.pure(),
    this.lastname = const Lastname.pure(),
    this.email = const Email.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final Firstname firstname;
  final Lastname lastname;
  final Email email;
  final bool isValid;

  ProfileEditState copyWith({
    FormzSubmissionStatus? status,
    Firstname? firstname,
    Lastname? lastname,
    Email? email,
    bool? isValid,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, firstname, lastname, email];
}