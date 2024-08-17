import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:user_repository/user_repository.dart';

part 'update_event.dart';
part 'update_state.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc(
      {required UserRepository userRepository,
      required AuthenticationBloc authenticationBloc,
      required User user})
      : _userRepository = userRepository,
        _authenticationBloc = authenticationBloc,
        super(ProfileUpdateState(
          firstname: Firstname.dirty(user.firstname),
          lastname: Lastname.dirty(user.lastname),
          email: Email.dirty(user.email),
        )) {
    on<ProfileUpdateFirstnameChanged>(_onFirstnameChanged);
    on<ProfileUpdateLastnameChanged>(_onLastnameChanged);
    on<ProfileUpdateEmailChanged>(_onEmailChanged);
    on<ProfileUpdateSubmitted>(_onSubmitted);
  }

  final UserRepository _userRepository;
  final AuthenticationBloc _authenticationBloc;

  void _onFirstnameChanged(
    ProfileUpdateFirstnameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final firstname = Firstname.dirty(event.firstname);
    emit(
      state.copyWith(
        firstname: firstname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([firstname, state.lastname, state.email]),
      ),
    );
  }

  void _onLastnameChanged(
    ProfileUpdateLastnameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final lastname = Lastname.dirty(event.lastname);

    emit(
      state.copyWith(
        lastname: lastname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.firstname, lastname, state.email]),
      ),
    );
  }

  void _onEmailChanged(
    ProfileUpdateEmailChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.firstname, state.lastname, email]),
      ),
    );
  }

  Future<void> _onSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        final user = await _userRepository.updateUser(
          firstname: state.firstname.value,
          lastname: state.lastname.value,
          email: state.email.value,
        );

        _authenticationBloc.add(AuthenticationUserUpdated(user));

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
