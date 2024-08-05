import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/login/login.dart';
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
              const SnackBar(
                backgroundColor: Color(0xFFD32f2f),
                content: Text('Authentication Failure'),
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
                SizedBox(height: 50),
                _LogoAndAppNameField(),
                SizedBox(height: 100),
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
          style: TextStyle( 
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF736ACC),
          ),
        ),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginBloc bloc) => bloc.state.email.displayError,
    );

    return SizedBox(
      width: 350,
      child: TextField(
        key: const Key('loginForm_emailInput_textField'),
        onChanged: (email) {
          context.read<LoginBloc>().add(LoginEmailChanged(email));
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'E-mailadres',
          hintText: 'voorbeeld@email.com',
          errorText: displayError != null ? 'Ongeldig e-mailadres' : null,
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginBloc bloc) => bloc.state.password.displayError,
    );

    return SizedBox(
      width: 350,
      child: TextField(
        key: const Key('loginForm_passwordInput_textField'),
        onChanged: (password) {
          context.read<LoginBloc>().add(LoginPasswordChanged(password));
        },
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Wachtwoord',
          hintText: '*********',
          errorText: displayError != null ? 'Ongeldig wachtwoord' : null,
        ),
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

    return Container(
      width: 350,
      height: 40,
      child: ElevatedButton(
        key: const Key('loginForm_continue_raisedButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF736ACC),
          foregroundColor: Colors.white;
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
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(5)),
            ),
            onPressed: () {

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