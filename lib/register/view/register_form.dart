import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/register/register.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:dierenasiel_android/login/view/login_page.dart';
import 'package:formz/formz.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  backgroundColor: errorColor,
                  content: Text(state.error.isNotEmpty
                      ? state.error
                      : 'Authenticatie fout...'),
                  showCloseIcon: true,
                ),
              );
          }
        },
        child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 25),
          _LogoAndAppNameField(),
          const SizedBox(height: 30),
          _FirstnameInput(),
          const Padding(padding: EdgeInsets.all(16)),
          _LastnameInput(),
          const Padding(padding: EdgeInsets.all(16)),
          _EmailInput(),
          const Padding(padding: EdgeInsets.all(16)),
          _PasswordInput(),
          const Padding(padding: EdgeInsets.all(16)),
          _RegisterButton(),
          _LoginField(),
        ])))));
  }
}

class _LogoAndAppNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 150,
          height: 150,
        ),
        Text(
          'Dierenasielen\nBelgië'.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

class _FirstnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firstNameError = context.select(
      (RegisterBloc bloc) => bloc.state.firstname,
    );

    String? errorText;
    switch (firstNameError.error) {
      case FirstnameValidationError.empty:
        errorText = 'Voornaam mag niet leeg zijn';
      default:
        errorText = 'Ongeldige voornaam';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextField(
        key: const Key('registerForm_firstnameInput_textField'),
        onChanged: (firstname) {
          context.read<RegisterBloc>().add(RegisterFirstnameChanged(firstname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Voornaam',
          errorText: firstNameError.displayError != null ? errorText : null,
        ),
      ),
    );
  }
}

class _LastnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lastNameError = context.select(
      (RegisterBloc bloc) => bloc.state.lastname,
    );

    String? errorText;
    switch (lastNameError.error) {
      case LastnameValidationError.empty:
        errorText = 'Achternaam mag niet leeg zijn';
      default:
        errorText = 'Ongeldige achternaam';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextField(
        key: const Key('registerForm_lastnameInput_textField'),
        onChanged: (lastname) {
          context.read<RegisterBloc>().add(RegisterLastnameChanged(lastname));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Achternaam',
          errorText: lastNameError.displayError != null ? errorText : null,
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailError = context.select(
      (RegisterBloc bloc) => bloc.state.email,
    );

    String? errorText;
    switch (emailError.error) {
      case EmailValidationError.empty:
        errorText = 'E-mailadres mag niet leeg zijn';
      default:
        errorText = 'Ongeldig e-mailadres';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextField(
        key: const Key('registerForm_emailInput_textField'),
        onChanged: (email) {
          context.read<RegisterBloc>().add(RegisterEmailChanged(email));
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'E-mailadres',
          hintText: 'voorbeeld@email.com',
          errorText: emailError.displayError != null ? errorText : null,
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passwordError = context.select(
      (RegisterBloc bloc) => bloc.state.password,
    );

    String? errorText;
    switch (passwordError.error) {
      case PasswordValidationError.empty:
        errorText = 'Wachtwoord mag niet leeg zijn';
      default:
        errorText = 'Ongeldig wachtwoord';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextField(
        key: const Key('registerForm_passwordInput_textField'),
        onChanged: (password) {
          context.read<RegisterBloc>().add(RegisterPasswordChanged(password));
        },
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Wachtwoord',
          hintText: '*********',
          errorText: passwordError.displayError != null ? errorText : null,
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (RegisterBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid = context.select((RegisterBloc bloc) => bloc.state.isValid);

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('registerForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
        ),
        onPressed: isValid
            ? () => context.read<RegisterBloc>().add(const RegisterSubmitted())
            : null,
        child: const Text('Meld aan'),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Heeft u al een account?'),
        TextButton(
          key: const Key('registerForm_login_textButton'),
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(5)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('Log in',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }
}
