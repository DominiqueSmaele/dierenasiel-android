import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:dierenasiel_android/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

Future main() async {
  await dotenv.load(fileName: '.env');

  await init();

  runApp(const App());
}
