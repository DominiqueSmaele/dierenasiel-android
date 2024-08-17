import 'dart:async';

import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SheltersTimeslotsView extends StatefulWidget {
  const SheltersTimeslotsView({super.key});

  @override
  State<SheltersTimeslotsView> createState() => SheltersTimeslotListState();
}

class SheltersTimeslotListState extends State<SheltersTimeslotsView>
    with TickerProviderStateMixin {
  Shelter? selectedShelter;
  Timeslot? selectedTimeslot; // Track the selected timeslot
  TabController? _tabController;
  Map<DateTime, List<Timeslot>> groupedTimeslots = {};

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ShelterTimeslotBloc, ShelterTimeslotState>(
      builder: (context, state) {
        switch (state.status) {
          case ShelterTimeslotStatus.failure:
            return const Center(
                child: Text('Het ophalen van dierenasielen is mislukt...'));
          case ShelterTimeslotStatus.success:
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 64),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: DropdownMenu<Shelter?>(
                      width: screenWidth - 32,
                      initialSelection: selectedShelter,
                      label: const Text('Dierenasiel'),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        fillColor: backgroundColor,
                      ),
                      onSelected: (Shelter? newValue) async {
                        if (newValue == selectedShelter) return;

                        setState(() {
                          selectedShelter = newValue;
                          selectedTimeslot =
                              null; // Reset selected timeslot when shelter changes
                          groupedTimeslots.clear();
                          _tabController?.dispose();
                          _tabController = null;
                        });

                        if (newValue != null && newValue.timeslots != null) {
                          groupedTimeslots =
                              groupTimeslots(newValue.timeslots!);
                          await Future.delayed(
                              const Duration(milliseconds: 200));

                          if (mounted) {
                            setState(() {
                              _tabController = TabController(
                                length: groupedTimeslots.keys.length,
                                vsync: this,
                              );
                            });
                          }
                        }
                      },
                      dropdownMenuEntries:
                          state.shelters.map((Shelter shelter) {
                        return DropdownMenuEntry<Shelter>(
                          value: shelter,
                          label: shelter.name,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (selectedShelter != null && groupedTimeslots.isNotEmpty)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                32.0, 32.0, 32.0, 24.0),
                            decoration: const BoxDecoration(
                              color: white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      selectedShelter!.image!.original.url,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.fitHeight,
                                  height: 100.0,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 15.0),
                                Text(
                                  selectedShelter!.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          if (_tabController != null)
                            Column(
                              children: [
                                const Text(
                                  'Kies een tijdslot...',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                                  decoration: const BoxDecoration(
                                    color: white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16.0)),
                                  ),
                                  child: TabBar(
                                    tabAlignment: TabAlignment.center,
                                    controller: _tabController,
                                    isScrollable: true,
                                    dividerColor: Colors.transparent,
                                    tabs: groupedTimeslots.keys.map((date) {
                                      return Tab(
                                        text:
                                            DateFormat('E, dd/MM').format(date),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          if (_tabController != null)
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: groupedTimeslots.keys.map((date) {
                                  List<Timeslot> timeslots =
                                      groupedTimeslots[date]!;
                                  return GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 8.0,
                                      mainAxisExtent: 60,
                                    ),
                                    itemCount: timeslots.length,
                                    itemBuilder: (context, index) {
                                      final timeslot = timeslots[index];
                                      final isSelected =
                                          timeslot == selectedTimeslot;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTimeslot = timeslot;
                                          });
                                        },
                                        child: Card(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${DateFormat('HH:mm').format(timeslot.startTime)} - ${DateFormat('HH:mm').format(timeslot.endTime)}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedTimeslot != null
                                  ? () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Timeslot ${DateFormat('HH:mm').format(selectedTimeslot!.startTime)} - ${DateFormat('HH:mm').format(selectedTimeslot!.endTime)} booked. ID: ${selectedTimeslot!.id}')),
                                      );
                                    }
                                  : null, // Disable button if no timeslot is selected
                              child: const Text('Book'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          case ShelterTimeslotStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Map<DateTime, List<Timeslot>> groupTimeslots(List<Timeslot> timeslots) {
    Map<DateTime, List<Timeslot>> groupedTimeslots = {};

    for (var timeslot in timeslots) {
      DateTime date = timeslot.date;
      if (groupedTimeslots[date] == null) {
        groupedTimeslots[date] = [];
      }
      groupedTimeslots[date]!.add(timeslot);
    }

    return groupedTimeslots;
  }
}
