part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class RegisterFirstnameChanged extends RegisterEvent {
  const RegisterFirstnameChanged(this.firstname);

  final String firstname;

  @override
  List<Object> get props => [firstname];
}

final class RegisterLastnameChanged extends RegisterEvent {
  const RegisterLastnameChanged(this.lastname);

  final String lastname;

  @override
  List<Object> get props => [lastname];
}

final class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}