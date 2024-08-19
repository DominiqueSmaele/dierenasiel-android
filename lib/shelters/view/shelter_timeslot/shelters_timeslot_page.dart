import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:timeslot_repository/timeslot_repository.dart';

class SheltersTimeslotPage extends StatefulWidget {
  const SheltersTimeslotPage({super.key});

  @override
  SheltersTimeslotPageState createState() => SheltersTimeslotPageState();
}

class SheltersTimeslotPageState extends State<SheltersTimeslotPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ShelterTimeslotBloc(
          shelterRepository: context.read<ShelterRepository>(),
          timeslotRepository: context.read<TimeslotRepository>(),
        )..add(ShelterTimeslotFetched()),
        child: const SheltersTimeslotsView(),
      ),
    );
  }
}
