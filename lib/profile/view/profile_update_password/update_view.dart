import 'package:dierenasiel_android/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:formz/formz.dart';

class ProfileUpdatePasswordView extends StatelessWidget {
  const ProfileUpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileUpdatePasswordBloc, ProfileUpdatePasswordState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: green,
                  content: Text('Wachtwoord gewijzigd!'),
                  showCloseIcon: true,
                ),
              );
          } else if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  backgroundColor: errorColor,
                  content: Text(state.error.isNotEmpty
                      ? state.error
                      : 'Fout bij het wijzigen van het wachtwoord...'),
                  showCloseIcon: true,
                ),
              );
          }
        },
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _UserProfileHeader(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _PasswordInput(),
                const Padding(padding: EdgeInsets.all(16)),
                _RepeatPasswordInput(),
                const Padding(padding: EdgeInsets.all(16)),
                _ProfileUpdatePasswordButton(),
                const Padding(padding: EdgeInsets.all(8)),
                _BackButton()
              ],
            ),
          ),
        ]))));
  }
}

class _UserProfileHeader extends StatelessWidget {
  const _UserProfileHeader();

  @override
  Widget build(BuildContext context) {
    final firstName =
        context.select((AuthenticationBloc bloc) => bloc.state.user.firstname);
    final lastName =
        context.select((AuthenticationBloc bloc) => bloc.state.user.lastname);

    String initials = '';

    initials += firstName.isNotEmpty ? firstName[0] : '';
    initials += lastName.isNotEmpty ? lastName[0] : '';

    return SizedBox(
      height: 275,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipPath(
            clipper: CurveClipper(), // Custom clipper for curved shape
            child: Container(
              height: 185,
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            top: 90,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: white,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileUpdatePage()),
                        );
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text('$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 30,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passwordError = context.select(
      (ProfileUpdatePasswordBloc bloc) => bloc.state.password,
    );

    String? errorText;
    switch (passwordError.error) {
      case PasswordValidationError.empty:
        errorText = 'Wachtwoord mag niet leeg zijn';
      default:
        errorText = 'Ongeldig wachtwoord';
    }

    return TextField(
      key: const Key('profileUpdatePasswordForm_passwordInput_textField'),
      onChanged: (password) {
        context
            .read<ProfileUpdatePasswordBloc>()
            .add(ProfileUpdatePasswordChanged(password));
      },
      obscureText: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Nieuw wachtwoord',
        errorText: passwordError.displayError != null ? errorText : null,
      ),
    );
  }
}

class _RepeatPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repeatPasswordError = context.select(
      (ProfileUpdatePasswordBloc bloc) => bloc.state.repeatPassword,
    );

    String? errorText;
    switch (repeatPasswordError.error) {
      case PasswordConfirmationValidationError.empty:
        errorText = 'Wachtwoord mag niet leeg zijn';
      case PasswordConfirmationValidationError.mismatch:
        errorText = 'Wachtwoorden komen niet overeen';
      default:
        errorText = 'Ongeldig wachtwoord';
    }

    return TextField(
      key: const Key('profileUpdatePasswordForm_repeatPasswordInput_textField'),
      onChanged: (repeatPassword) {
        context
            .read<ProfileUpdatePasswordBloc>()
            .add(ProfileUpdateRepeatPasswordChanged(repeatPassword));
      },
      obscureText: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Herhaal nieuw wachtwoord',
        errorText: repeatPasswordError.displayError != null ? errorText : null,
      ),
    );
  }
}

class _ProfileUpdatePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (ProfileUpdatePasswordBloc bloc) =>
          bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid =
        context.select((ProfileUpdatePasswordBloc bloc) => bloc.state.isValid);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('profileUpdatePasswordForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
        ),
        onPressed: isValid
            ? () => context
                .read<ProfileUpdatePasswordBloc>()
                .add(const ProfileUpdatePasswordSubmitted())
            : null,
        child: const Text('Wijzigen'),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('profileUpdatePasswordForm_back_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Terug'),
      ),
    );
  }
}
