part of 'profile_edit_bloc.dart';

sealed class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object> get props => [];
}

final class InitializeProfileEdit extends ProfileEditEvent {}

final class ProfileEditFirstnameChanged extends ProfileEditEvent {
  const ProfileEditFirstnameChanged(this.firstname);

  final String firstname;

  @override
  List<Object> get props => [firstname];
}

final class ProfileEditLastnameChanged extends ProfileEditEvent {
  const ProfileEditLastnameChanged(this.lastname);

  final String lastname;

  @override
  List<Object> get props => [lastname];
}

final class ProfileEditEmailChanged extends ProfileEditEvent {
  const ProfileEditEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class ProfileEditSubmitted extends ProfileEditEvent {
  const ProfileEditSubmitted();
}