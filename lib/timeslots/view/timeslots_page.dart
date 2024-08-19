import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:dierenasiel_android/timeslots/timeslots.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';

class TimeslotsPage extends StatefulWidget {
  const TimeslotsPage({super.key});

  @override
  TimeslotsPageState createState() => TimeslotsPageState();
}

class TimeslotsPageState extends State<TimeslotsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => TimeslotBloc(
          timeslotRepository: context.read<TimeslotRepository>(),
        )..add(TimeslotFetched()),
        child: const TimeslotsView(),
      ),
    );
  }
}
