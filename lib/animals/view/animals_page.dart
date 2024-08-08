import 'package:animal_repository/animal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/animals/animals.dart';

class AnimalsPage extends StatelessWidget {
  const AnimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => AnimalBloc(
          animalRepository: context.read<AnimalRepository>(),
        )..add(AnimalFetched()),
        child: const AnimalsList(),
      ),
    );
  }
}