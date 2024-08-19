import 'dart:async';

import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    return BlocBuilder<ShelterTimeslotBloc, ShelterTimeslotState>(
      builder: (context, state) {
        switch (state.status) {
          case ShelterTimeslotStatus.failure:
            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                                'Het ophalen van shiften voor dierenasielen is mislukt...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          16.0, // statusBarHeight + 16.0
                      left: 24.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: backgroundColor),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          case ShelterTimeslotStatus.empty:
            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                                'Oops, geen shiften gevonden voor dierenasielen!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          16.0, // statusBarHeight + 16.0
                      left: 24.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: backgroundColor),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          case ShelterTimeslotStatus.success:
            return SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: DropdownMenu<Shelter?>(
                        width: screenWidth - 32,
                        initialSelection: selectedShelter,
                        label: const Text('Dierenasiel'),
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          fillColor: backgroundColor,
                        ),
                        onSelected: (Shelter? shelter) async {
                          if (shelter == selectedShelter) return;

                          setState(() {
                            selectedShelter = shelter;
                            selectedTimeslot = null;
                            groupedTimeslots.clear();
                            _tabController?.dispose();
                            _tabController = null;
                          });

                          if (shelter != null && shelter.timeslots != null) {
                            groupedTimeslots =
                                groupTimeslots(shelter.timeslots!);
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
                    const SizedBox(height: 10),
                    if (selectedShelter != null && groupedTimeslots.isNotEmpty)
                      Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 32.0, 16.0, 24.0),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: Column(
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
                          ),
                          const SizedBox(height: 25),
                          if (_tabController != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: const Text(
                                    'Selecteer een shift...',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 21.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                                  color: white,
                                  child: TabBar(
                                    tabAlignment: TabAlignment.start,
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
                            SizedBox(
                              height: 250,
                              child: TabBarView(
                                controller: _tabController,
                                children: groupedTimeslots.keys.map((date) {
                                  List<Timeslot> timeslots =
                                      groupedTimeslots[date]!;
                                  return GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 16.0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 8.0,
                                      crossAxisSpacing: 8.0,
                                      mainAxisExtent: 60,
                                    ),
                                    itemCount: timeslots.length,
                                    itemBuilder: (context, index) {
                                      final timeslot = timeslots[index];
                                      final isSelected =
                                          timeslot == selectedTimeslot;

                                      return GestureDetector(
                                        onTap: () {
                                          if (isSelected) {
                                            setState(() {
                                              selectedTimeslot = null;
                                            });
                                          } else {
                                            setState(() {
                                              selectedTimeslot = timeslot;
                                            });
                                          }
                                        },
                                        child: Card(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: white,
                              ),
                              onPressed: selectedTimeslot != null
                                  ? () {
                                      context.read<ShelterTimeslotBloc>().add(
                                          ShelterTimeslotUserBook(
                                              selectedShelter!,
                                              selectedTimeslot!));
                                    }
                                  : null,
                              child: const Text('Inschrijven'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        key: const Key('profileUpdateForm_back_raisedButton'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Terug'),
                      ),
                    ),
                  ],
                ),
              ),
            ));
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
