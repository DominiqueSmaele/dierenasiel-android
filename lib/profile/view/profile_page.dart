import 'package:dierenasiel_android/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileView(),
    );
  }
}
