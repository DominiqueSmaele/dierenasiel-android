import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:dierenasiel_android/home/home.dart';
import 'package:dierenasiel_android/login/login.dart';
import 'package:dierenasiel_android/splash/splash.dart';
import 'package:user_repository/user_repository.dart';
import 'package:dierenasiel_android/helpers/theme.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:type_repository/type_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final AnimalRepository _animalRepository;
  late final ShelterRepository _shelterRepository;
  late final TimeslotRepository _timeslotRepository;
  late final TypeRepository _typeRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _animalRepository = AnimalRepository();
    _shelterRepository = ShelterRepository();
    _timeslotRepository = TimeslotRepository();
    _typeRepository = TypeRepository();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _animalRepository),
        RepositoryProvider.value(value: _shelterRepository),
        RepositoryProvider.value(value: _timeslotRepository),
        RepositoryProvider.value(value: _typeRepository),
      ],
      child: BlocProvider(
        lazy: false,
        create: (_) => AuthenticationBloc(
          authenticationRepository: _authenticationRepository,
          userRepository: _userRepository,
        )..add(AuthenticationSubscriptionRequested()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAuthentication();
    }
  }

  void _checkAuthentication() {
    context.read<AuthenticationBloc>().add(AuthenticationVerifyUser());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: customTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(),
                  (route) => false,
                );
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
              case AuthenticationStatus.unknown:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
