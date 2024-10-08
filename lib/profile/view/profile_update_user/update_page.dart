import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:user_repository/user_repository.dart';

class ProfileUpdatePage extends StatelessWidget {
  const ProfileUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final user =
              context.select((AuthenticationBloc bloc) => bloc.state.user);

          return BlocProvider(
            create: (context) => ProfileUpdateBloc(
              userRepository: context.read<UserRepository>(),
              authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
              user: user,
            ),
            child: const ProfileUpdateView(),
          );
        },
      ),
    );
  }
}
