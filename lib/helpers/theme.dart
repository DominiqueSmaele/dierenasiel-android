import 'package:flutter/material.dart';
import 'package:dierenasiel_android/helpers/constants.dart';

final ThemeData customTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textColor),
    bodyMedium: TextStyle(color: textColor),
    bodySmall: TextStyle(color: textColor),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: textColor),
    ),
    labelStyle: TextStyle(color: textColor),
    hintStyle: TextStyle(
      color: textColor,
      fontWeight: FontWeight.normal,
    ),
    errorStyle: TextStyle(color: textColor),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryColor,
    secondary: primaryColor,
    surface: backgroundColor,
    onSurface: textColor,
  ),
);
