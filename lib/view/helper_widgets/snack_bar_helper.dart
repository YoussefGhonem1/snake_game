import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/enum/snack_bar_type.dart';
import '../../core/constants/game_colors.dart';

class SnackBarHelper {
  SnackBarHelper({required this.snackBarType, required this.message});

  final SnackBarType snackBarType;
  final String message;
  ColorHelper colorHelper = ColorHelper.instance;

  SnackBar getSnackBar() {
    if (snackBarType == SnackBarType.error) {
      return SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorHelper.appOnErrorColor),
        ),
        backgroundColor: colorHelper.appErrorColor,
      );
    } else {
      return SnackBar(content: Text(message));
    }
  }

  static showSnackBar(BuildContext context, SnackBarHelper snackBarHelper) {
    ScaffoldMessenger.of(context).showSnackBar(snackBarHelper.getSnackBar());
  }
}
