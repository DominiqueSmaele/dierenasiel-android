import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:user_repository/user_repository.dart';


part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  ProfileEditBloc({
    required UserRepository userRepository, 
    required AuthenticationBloc authenticationBloc,
    required User user
  }) : 
    _userRepository = userRepository,
    _authenticationBloc = authenticationBloc,
    super(ProfileEditState(
          firstname: Firstname.dirty(user.firstname),
          lastname: Lastname.dirty(user.lastname),
          email: Email.dirty(user.email),
        )) {
    on<ProfileEditFirstnameChanged>(_onFirstnameChanged);
    on<ProfileEditLastnameChanged>(_onLastnameChanged);
    on<ProfileEditEmailChanged>(_onEmailChanged);
    on<ProfileEditSubmitted>(_onProfileEditSubmitted);

  }

  final UserRepository _userRepository;
  final AuthenticationBloc _authenticationBloc;

  void _onFirstnameChanged(
    ProfileEditFirstnameChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    final firstname = Firstname.dirty(event.firstname);
    emit(
      state.copyWith(
        firstname: firstname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([firstname]),
      ),
    );
  }

  void _onLastnameChanged(
    ProfileEditLastnameChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    final lastname = Lastname.dirty(event.lastname);

    emit(
      state.copyWith(
        lastname: lastname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([lastname]),
      ),
    );
  }

  void _onEmailChanged(
    ProfileEditEmailChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([email]),
      ),
    );
  }

  Future<void> _onProfileEditSubmitted(
    ProfileEditSubmitted event,
    Emitter<ProfileEditState> emit,
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
      } catch (_) {
        print(_);
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}