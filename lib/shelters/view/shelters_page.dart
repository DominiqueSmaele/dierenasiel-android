import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';

class SheltersPage extends StatelessWidget {
  const SheltersPage({super.key});

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
