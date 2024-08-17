import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:user_repository/user_repository.dart';

part 'update_event.dart';
part 'update_state.dart';

class ProfileUpdatePasswordBloc
    extends Bloc<ProfileUpdatePasswordEvent, ProfileUpdatePasswordState> {
  ProfileUpdatePasswordBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const ProfileUpdatePasswordState()) {
    on<ProfileUpdatePasswordChanged>(_onPasswordChanged);
    on<ProfileUpdateRepeatPasswordChanged>(_onRepeatPasswordChanged);
    on<ProfileUpdatePasswordSubmitted>(_onSubmitted);
  }

  final UserRepository _userRepository;

  void _onPasswordChanged(
    ProfileUpdatePasswordChanged event,
    Emitter<ProfileUpdatePasswordState> emit,
  ) {
    final password = Password.dirty(event.password);

    emit(
      state.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([password, state.repeatPassword]),
      ),
    );
  }

  void _onRepeatPasswordChanged(
    ProfileUpdateRepeatPasswordChanged event,
    Emitter<ProfileUpdatePasswordState> emit,
  ) {
    final repeatPassword = PasswordConfirmation.dirty(
        password: state.password.value, value: event.repeatPassword);

    emit(
      state.copyWith(
        repeatPassword: repeatPassword,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.password, repeatPassword]),
      ),
    );
  }

  Future<void> _onSubmitted(
    ProfileUpdatePasswordSubmitted event,
    Emitter<ProfileUpdatePasswordState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _userRepository.updateUserPassword(
          password: state.password.value,
          repeatPassword: state.repeatPassword.value,
        );

        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (e) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: e.toString(),
        ));
      }
    }
  }
}
