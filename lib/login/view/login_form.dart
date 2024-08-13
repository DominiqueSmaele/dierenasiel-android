import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/login/login.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:dierenasiel_android/register/view/register_page.dart';
import 'package:formz/formz.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: errorColor,
                content: Text(state.error.isNotEmpty
                ? state.error
                : 'Authenticatie fout...'
              ),
                showCloseIcon: true,
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                _LogoAndAppNameField(),
                const SizedBox(height: 100),
                _EmailInput(),
                const Padding(padding: EdgeInsets.all(16)),
                _PasswordInput(),
                const Padding(padding: EdgeInsets.all(16)),
                _LoginButton(),
                _SignUpField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoAndAppNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'images/logo.png',
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

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailError = context.select(
      (LoginBloc bloc) => bloc.state.email,
    );

    String? errorText;
    switch (emailError.error) {
      case EmailValidationError.empty:
        errorText = 'E-mailadres mag niet leeg zijn';
      default:
        errorText = 'Ongeldig e-mailadres';
    }

    return TextField(
        key: const Key('loginForm_emailInput_textField'),
        onChanged: (email) {
          context.read<LoginBloc>().add(LoginEmailChanged(email));
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

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passwordError = context.select(
      (LoginBloc bloc) => bloc.state.password,
    );

    String? errorText;
    switch (passwordError.error) {
      case PasswordValidationError.empty:
        errorText = 'Wachtwoord mag niet leeg zijn';
      default:
        errorText = 'Ongeldig wachtwoord';
    }

    return TextField(
        key: const Key('loginForm_passwordInput_textField'),
        onChanged: (password) {
          context.read<LoginBloc>().add(LoginPasswordChanged(password));
        },
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Wachtwoord',
          hintText: '*********',
          errorText: passwordError.displayError != null ? errorText : null,
        ),
      );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (LoginBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid = context.select((LoginBloc bloc) => bloc.state.isValid);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        key: const Key('loginForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
        ),
        onPressed: isValid
            ? () => context.read<LoginBloc>().add(const LoginSubmitted())
            : null,
        child: const Text('Log In'),
      ),
    );
  }
}

class _SignUpField extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Nog geen account?'),
          TextButton(
            key: const Key('loginForm_signUp_textButton'),
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(5)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: const Text(
              'Meld aan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )
            ),
          ),
        ],
      );
    }
}