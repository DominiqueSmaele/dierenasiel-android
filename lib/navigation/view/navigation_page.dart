import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:dierenasiel_android/navigation/navigation.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/profile/profile.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    AnimalsPage(),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)), 
              child: NavigationBar(
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outlined),
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