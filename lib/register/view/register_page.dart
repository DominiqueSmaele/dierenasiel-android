import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/register/register.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocProvider(
            create: (context) => RegisterBloc(
                authenticationRepository:
                    context.read<AuthenticationRepository>()),
            child: const RegisterForm(),
          )),
    );
  }
}
