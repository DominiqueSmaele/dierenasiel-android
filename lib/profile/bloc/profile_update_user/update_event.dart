part of 'update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object> get props => [];
}

final class InitializeProfileUpdate extends ProfileUpdateEvent {}

final class ProfileUpdateFirstnameChanged extends ProfileUpdateEvent {
  const ProfileUpdateFirstnameChanged(this.firstname);

  final String firstname;

  @override
  List<Object> get props => [firstname];
}

final class ProfileUpdateLastnameChanged extends ProfileUpdateEvent {
  const ProfileUpdateLastnameChanged(this.lastname);

  final String lastname;

  @override
  List<Object> get props => [lastname];
}

final class ProfileUpdateEmailChanged extends ProfileUpdateEvent {
  const ProfileUpdateEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class ProfileUpdateSubmitted extends ProfileUpdateEvent {
  const ProfileUpdateSubmitted();
}
