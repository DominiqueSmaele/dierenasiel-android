import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:user_repository/user_repository.dart';

class ProfileUpdatePasswordPage extends StatelessWidget {
  const ProfileUpdatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ProfileUpdatePasswordBloc(
          userRepository: context.read<UserRepository>(),
        ),
        child: const ProfileUpdatePasswordView(),
      ),
    );
  }
}
