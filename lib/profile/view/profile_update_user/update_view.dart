import 'package:dierenasiel_android/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:formz/formz.dart';

class ProfileUpdateView extends StatelessWidget {
  const ProfileUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
      listener: (context, state) {
      if (state.status.isSuccess) {
        Navigator.of(context).pop(); 
      } else if (state.status.isFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: errorColor,
              content: Text(state.error.isNotEmpty
                ? state.error
                : 'Fout bij het wijzigen van profiel gegevens...'
              ),
              showCloseIcon: true,
            ),
      );
    }
      },
      child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _UserProfileHeader(),
                Padding( 
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _FirstnameInput(),
                      const Padding(padding: EdgeInsets.all(16)),
                      _LastnameInput(),
                      const Padding(padding: EdgeInsets.all(16)),
                      _EmailInput(),
                      const Padding(padding: EdgeInsets.all(16)),
                      _ProfileUpdateButton(),
                      const Padding(padding: EdgeInsets.all(8)),
                      _BackButton()
                    ],
                  ),
                ),

              ]
            )
          )
      )
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  const _UserProfileHeader();

  @override
  Widget build(BuildContext context) {
    final firstName = context.select((AuthenticationBloc bloc) => bloc.state.user.firstname);
    final lastName = context.select((AuthenticationBloc bloc) => bloc.state.user.lastname);

    String initials = '';

    initials += firstName.isNotEmpty ? firstName[0] : '';
    initials += lastName.isNotEmpty ? lastName[0] : '';

    return SizedBox(
      height: 300,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: primaryColor,
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
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text('$firstName $lastName', 
                    style: const TextStyle(
                      fontSize: 30, 
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class _FirstnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firstName = context.select((AuthenticationBloc bloc) => bloc.state.user.firstname);

    final firstNameError = context.select(
      (ProfileUpdateBloc bloc) => bloc.state.firstname,
    );

    String? errorText;
    switch (firstNameError.error) {
      case FirstnameValidationError.empty:
        errorText = 'Voornaam mag niet leeg zijn';
      default:
        errorText = 'Ongeldige voornaam';
    }

    return TextFormField(
        key: const Key('profileUpdateForm_firstnameInput_textField'),
        initialValue: firstName,
        onChanged: (firstname) {
          context.read<ProfileUpdateBloc>().add(ProfileUpdateFirstnameChanged(firstname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Voornaam',
          errorText: firstNameError.displayError != null ? errorText : null,
        ),
      );
  }
}

class _LastnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lastName = context.select((AuthenticationBloc bloc) => bloc.state.user.lastname);

    final lastNameError = context.select(
      (ProfileUpdateBloc bloc) => bloc.state.lastname,
    );

    String? errorText;
    switch (lastNameError.error) {
      case LastnameValidationError.empty:
        errorText = 'Achternaam mag niet leeg zijn';
      default:
        errorText = 'Ongeldige achternaam';
    }

    return TextFormField(
        key: const Key('profileUpdateForm_lastnameInput_textField'),
        initialValue: lastName,
        onChanged: (lastname) {
          context.read<ProfileUpdateBloc>().add(ProfileUpdateLastnameChanged(lastname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Achternaam',
          errorText: lastNameError.displayError != null ? errorText : null,
        ),
      );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthenticationBloc bloc) => bloc.state.user.email);

    final emailError = context.select(
      (ProfileUpdateBloc bloc) => bloc.state.email,
    );

    String? errorText;
    switch (emailError.error) {
      case EmailValidationError.empty:
        errorText = 'E-mailadres mag niet leeg zijn';
      default:
        errorText = 'Ongeldig e-mailadres';
    }

    return TextFormField(
        key: const Key('profileUpdateForm_emailInput_textField'),
        initialValue: email,
        onChanged: (email) {
          context.read<ProfileUpdateBloc>().add(ProfileUpdateEmailChanged(email));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'E-mailadres',
          hintText: 'voorbeeld@email.com',
          errorText: emailError.displayError != null ? errorText : null,
        ),
      );
  }
}

class _ProfileUpdateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (ProfileUpdateBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid = context.select((ProfileUpdateBloc bloc) => bloc.state.isValid);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('profileUpdateForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
        ),
        onPressed: isValid
          ? () => context.read<ProfileUpdateBloc>().add(const ProfileUpdateSubmitted())
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
        key: const Key('profileUpdateForm_back_raisedButton'),
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