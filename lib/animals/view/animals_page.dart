import 'package:animal_repository/animal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:type_repository/type_repository.dart';

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  AnimalsPageState createState() => AnimalsPageState();
}

class AnimalsPageState extends State<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AnimalBloc(
          animalRepository: context.read<AnimalRepository>(),
          typeRepository: context.read<TypeRepository>(),
        )..add(AnimalFetched()),
        child: const AnimalsList(),
      ),
    );
  }
}
