part of 'authentication_bloc.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AuthenticationSubscriptionRequested extends AuthenticationEvent {}

final class AuthenticationVerifyUser extends AuthenticationEvent {}

final class AuthenticationUserUpdated extends AuthenticationEvent {
  const AuthenticationUserUpdated(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class AuthenticationLogoutPressed extends AuthenticationEvent {}