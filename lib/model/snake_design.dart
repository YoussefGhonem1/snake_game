import 'package:flutter/material.dart';

class SnakeDesign {
  final String name;
  final Color headColor;
  final Color bodyColor;
  final List<String> imgPaths;
  final int price;
  final int requiredLevel;
  final bool isDefault;

  SnakeDesign({
    required this.name,
    required this.headColor,
    required this.bodyColor,
    required this.price,
    required this.requiredLevel,
    required this.imgPaths,
    this.isDefault = false,
  });
}
