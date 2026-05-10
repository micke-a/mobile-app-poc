import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Change this one value to shift the entire app palette.
const Color kSeedColor = Color(0xFF2563EB);
const Color kLightScaffoldBackground = Color(0xFFF8FAFC);

final _cardTheme = CardThemeData(
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  elevation: 0,
  surfaceTintColor: Colors.transparent,
);

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kLightScaffoldBackground,
    cardTheme: _cardTheme,
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    cardTheme: _cardTheme,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}
