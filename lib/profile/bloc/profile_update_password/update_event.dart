part of 'update_bloc.dart';

sealed class ProfileUpdatePasswordEvent extends Equatable {
  const ProfileUpdatePasswordEvent();

  @override
  List<Object> get props => [];
}

final class ProfileUpdatePasswordChanged extends ProfileUpdatePasswordEvent {
  const ProfileUpdatePasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class ProfileUpdateRepeatPasswordChanged extends ProfileUpdatePasswordEvent {
  const ProfileUpdateRepeatPasswordChanged(this.repeatPassword);

  final String repeatPassword;

  @override
  List<Object> get props => [repeatPassword];
}

final class ProfileUpdatePasswordSubmitted extends ProfileUpdatePasswordEvent {
  const ProfileUpdatePasswordSubmitted();
}