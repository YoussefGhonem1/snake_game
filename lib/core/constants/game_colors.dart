import 'package:flutter/material.dart';

class ColorHelper {
  static final ColorHelper _singleton = ColorHelper._internal();
  static ColorHelper get instance => _singleton;

  ColorHelper._internal();

  //app colors
  Color appBackgroundColor = const Color(0xFF0A0A0A); // Dark modern background
  Color appSecondBackgroundColor = const Color(0xFF1A1A2E); // Deep purple-blue
  Color appTextColor = const Color(0xFFE0E0E0); // Light gray text
  Color appTextSecondColor = Colors.white;
  Color appIconColor = const Color(0xFF00F5FF); // Cyan accent
  Color appButtonColor = const Color(0xFF16213E); // Dark blue button
  Color appOnButtonColor = const Color(0xFF00F5FF); // Cyan text on button
  Color appButtonSecondColor = const Color(0xFF0F3460); // Darker blue
  Color appOnButtonSecondColor = Colors.white;
  Color appTextFieldFillColor = const Color(0xFF1A1A2E);
  Color appTextFieldBorderColor = const Color(0xFF00F5FF);
  Color appErrorColor = const Color(0xFFFF6B6B); // Modern red
  Color appOnErrorColor = Colors.white;
  Color alertDialogBackgroundColor = const Color(0xFF1A1A2E);
  Color alertTextColor = Colors.white;
  Color alertIconTextColor = const Color(0xFF00F5FF);
  Color danger = const Color(0xFFFF6B6B);

  //game colors - Enhanced modern theme with better contrast
  Color gameBackgroundColor = const Color(0xFF0D1117); // GitHub dark background
  Color primary = const Color(0xFF58A6FF); // GitHub blue
  Color onPrimary = const Color(0xFF0D1117); // Dark text on blue
  Color secondary = const Color(0xFF21262D); // GitHub secondary dark
  Color onSecondary = const Color(0xFFF0F6FC); // Light text on dark

  // Enhanced snake colors for better visibility
  Color snakeHeadColor = const Color(0xFF58A6FF); // GitHub blue
  Color snakeBodyColor = const Color(0xFF1F6FEB); // Darker GitHub blue
  Color snakeBodyGradientEnd = const Color(0xFF0969DA); // Even darker blue
  Color snakeHeadGlowColor = const Color(0xFF79C0FF);

  // Improved food colors for better contrast
  Color foodColor = const Color(0xFFFF7B72); // GitHub red
  Color foodGlowColor = const Color(0xFFFFB3BA); // Light red glow

  // Better barrier colors
  Color barrierColor = const Color(0xFF79C0FF); // Light blue barriers
  Color barrierGlowColor = const Color(0xFFA5D6FF); // Blue glow

  // Enhanced UI colors
  Color scoreColor = const Color(0xFFE3B341); // Warm gold
  Color levelProgressColor = const Color(0xFF58A6FF); // GitHub blue progress
  Color gameOverColor = const Color(0xFFFF7B72); // GitHub red
  Color victoryColor = const Color(0xFF3FB950); // GitHub green victory

  // Enhanced gradient colors
  LinearGradient gameBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1117),
      Color(0xFF161B22),
      Color(0xFF21262D),
    ],
  );

  LinearGradient snakeGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3FB950),
      Color(0xFF238636),
      Color(0xFF196C2E),
    ],
  );

  LinearGradient foodGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7B72),
      Color(0xFFFFB3BA),
    ],
  );

  // Big Score Cell Colors
  final Gradient bigScoreGradient = const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final Color bigScoreGlowColor = const Color(0xFFFFECB3);
}
