import 'package:dierenasiel_android/timeslots/timeslots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:dierenasiel_android/navigation/navigation.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/profile/profile.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    AnimalsPage(),
    SheltersPage(),
    TimeslotsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return _widgetOptions.elementAt(state.index);
              },
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
              boxShadow: [
                BoxShadow(color: primaryColor, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32.0)),
              child: NavigationBar(
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(
                      Icons.pets,
                      color: primaryColor,
                    ),
                    selectedIcon: Icon(Icons.pets),
                    label: 'Dieren',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.business,
                      color: primaryColor,
                    ),
                    selectedIcon: Icon(Icons.business),
                    label: 'Asielen',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_month,
                      color: primaryColor,
                    ),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Agenda',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person,
                      color: primaryColor,
                    ),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profiel',
                  ),
                ],
                selectedIndex: state.index,
                indicatorColor: primaryColor,
                onDestinationSelected: (int index) {
                  context.read<NavigationBloc>().add(NavigationChanged(index));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
