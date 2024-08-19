import 'dart:async';

import 'package:dierenasiel_android/timeslots/timeslots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';

class TimeslotsView extends StatefulWidget {
  const TimeslotsView({super.key});

  @override
  State<TimeslotsView> createState() => TimeslotsViewState();
}

class TimeslotsViewState extends State<TimeslotsView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: BlocBuilder<TimeslotBloc, TimeslotState>(
              builder: (context, state) {
                switch (state.status) {
                  case TimeslotStatus.failure:
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/empty.svg',
                                    height: 125,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    'Het ophalen van tijdsloten is mislukt...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  case TimeslotStatus.success:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mijn shiften bij...',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle,
                                  color: Theme.of(context).primaryColor),
                              iconSize: 26.0,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SheltersTimeslotPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: state.timeslots.length,
                            itemBuilder: (context, index) {
                              final timeslot = state.timeslots[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 16.0, 0, 0),
                                      child: Row(
                                        children: [
                                          Text(
                                            timeslot.shelter!.name,
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(timeslot.date),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        '${DateFormat('HH:mm').format(timeslot.startTime)} - ${DateFormat('HH:mm').format(timeslot.endTime)}',
                                      ),
                                      leading: const Icon(Icons.access_time,
                                          color: primaryColor),
                                      trailing: (timeslot.date.isToday)
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: primaryColor),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                      dialogContext) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: const Text(
                                                        'Bevestig uitschrijven',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      content: const Text(
                                                        'Bent u zeker dat u zich wilt uitschrijven voor deze shift?',
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                              'Annuleren'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                              'Uitschrijven'),
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    TimeslotBloc>()
                                                                .add(TimeslotUserDelete(
                                                                    timeslot));
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  case TimeslotStatus.initial:
                    return const Center(child: CircularProgressIndicator());
                  case TimeslotStatus.refresh:
                    return const Center(child: CircularProgressIndicator());
                  case TimeslotStatus.empty:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mijn shiften bij...',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle,
                                  color: Theme.of(context).primaryColor),
                              iconSize: 26.0,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SheltersTimeslotPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Flexible(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/empty.svg',
                                  height: 125,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'Oops! Nog geen shiften gevonden, begin met het toevoegen van een shift!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        ));
  }

  Future<void> _onRefresh() async {
    context.read<TimeslotBloc>().add(TimeslotRefreshed());
  }
}
