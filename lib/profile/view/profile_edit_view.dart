import 'package:dierenasiel_android/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:formz/formz.dart';

class ProfileEditView extends StatelessWidget {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileEditBloc, ProfileEditState>(
      listener: (context, state) {
      if (state.status.isSuccess) {
        Navigator.of(context).pop(); 
      } else if (state.status.isFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              backgroundColor: errorColor,
              content: Text('Profile Update Failure'),
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
                      _ProfileEditButton(),
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

    final displayError = context.select(
      (ProfileEditBloc bloc) => bloc.state.firstname.displayError,
    );

    return TextFormField(
        key: const Key('profileEditForm_firstnameInput_textField'),
        initialValue: firstName,
        onChanged: (firstname) {
          context.read<ProfileEditBloc>().add(ProfileEditFirstnameChanged(firstname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Voornaam',
          errorText: displayError != null ? 'Ongeldige voornaam' : null,
        ),
      );
  }
}

class _LastnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lastName = context.select((AuthenticationBloc bloc) => bloc.state.user.lastname);

    final displayError = context.select(
      (ProfileEditBloc bloc) => bloc.state.lastname.displayError,
    );

    return TextFormField(
        key: const Key('profileEditForm_lastnameInput_textField'),
        initialValue: lastName,
        onChanged: (lastname) {
          context.read<ProfileEditBloc>().add(ProfileEditLastnameChanged(lastname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Achternaam',
          errorText: displayError != null ? 'Ongeldige achternaam' : null,
        ),
      );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthenticationBloc bloc) => bloc.state.user.email);

    final displayError = context.select(
      (ProfileEditBloc bloc) => bloc.state.email.displayError,
    );

    return TextFormField(
        key: const Key('profileEditForm_emailInput_textField'),
        initialValue: email,
        onChanged: (email) {
          context.read<ProfileEditBloc>().add(ProfileEditEmailChanged(email));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'E-mailadres',
          hintText: 'voorbeeld@email.com',
          errorText: displayError != null ? 'Ongeldig e-mailadres' : null,
        ),
      );
  }
}

class _ProfileEditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (ProfileEditBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid = context.select((ProfileEditBloc bloc) => bloc.state.isValid);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('profileEditForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
        ),
        onPressed: isValid
          ? () => context.read<ProfileEditBloc>().add(const ProfileEditSubmitted())
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
        key: const Key('profileEditForm_back_raisedButton'),
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