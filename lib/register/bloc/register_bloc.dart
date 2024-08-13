import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dierenasiel_android/register/register.dart';
import 'package:formz/formz.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository,
        super(const RegisterState()) {
    on<RegisterFirstnameChanged>(_onFirstnameChanged);
    on<RegisterLastnameChanged>(_onLastnameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onFirstnameChanged(
    RegisterFirstnameChanged event,
    Emitter<RegisterState> emit,
  ) {
    final firstname = Firstname.dirty(event.firstname);
    emit(
      state.copyWith(
        firstname: firstname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([firstname, state.lastname, state.email, state.password]),
      ),
    );
  }

  void _onLastnameChanged(
    RegisterLastnameChanged event,
    Emitter<RegisterState> emit,
  ) {
    final lastname = Lastname.dirty(event.lastname);
    emit(
      state.copyWith(
        lastname: lastname,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.firstname, lastname, state.email, state.password]),
      ),
    );
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.firstname, state.lastname, email, state.password]),
      ),
    );
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.firstname, state.lastname, state.email, password]),
      ),
    );
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _authenticationRepository.register(
          firstname: state.firstname.value,
          lastname: state.lastname.value,
          email: state.email.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            error: e.toString()
        ));
      }
    }
  }
}