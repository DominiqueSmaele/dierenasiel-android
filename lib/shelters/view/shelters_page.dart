import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';

class SheltersPage extends StatefulWidget {
  const SheltersPage({super.key});

  @override
  SheltersPageState createState() => SheltersPageState();
}

class SheltersPageState extends State<SheltersPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ShelterBloc(
          shelterRepository: context.read<ShelterRepository>(),
        )..add(ShelterFetched()),
        child: const SheltersList(),
      ),
    );
  }
}
