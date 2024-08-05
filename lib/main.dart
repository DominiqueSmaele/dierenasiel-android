import 'package:flutter/widgets.dart';
import 'package:dierenasiel_android/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  runApp(const App());
}


