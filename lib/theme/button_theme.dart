import 'package:flutter/material.dart';

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: Colors.blue, // Primary color
    foregroundColor: Colors.white, // Text/icon color
    minimumSize: const Size(88, 36), // Minimum touch target size
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  ),
); 