part of 'update_bloc.dart';

final class ProfileUpdatePasswordState extends Equatable {
  const ProfileUpdatePasswordState({
    this.status = FormzSubmissionStatus.initial,
    this.password = const Password.pure(),
    this.repeatPassword = const PasswordConfirmation.pure(),
    this.isValid = false,
    this.error = '',
  });

  final FormzSubmissionStatus status;
  final Password password;
  final PasswordConfirmation repeatPassword;
  final bool isValid;
  final String error;

  ProfileUpdatePasswordState copyWith({
    FormzSubmissionStatus? status,
    Password? password,
    PasswordConfirmation? repeatPassword,
    bool? isValid,
    String? error,
  }) {
    return ProfileUpdatePasswordState(
      status: status ?? this.status,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, password, repeatPassword];
}
