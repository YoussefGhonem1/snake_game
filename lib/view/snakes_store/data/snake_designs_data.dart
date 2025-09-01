import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../model/snake_design.dart';

class SnakeDesignsData {
  static final List<SnakeDesign> snakeDesigns = [
    SnakeDesign(
      name: 'classic_snake'.tr(),
      headColor: Color(0xFF58A6FF),
      bodyColor: Color(0xFF1F6FEB),
      price: 0,
      requiredLevel: 1,
      isDefault: true,
    ),
    SnakeDesign(
      name: 'fire_snake'.tr(),
      headColor: Color(0xFFFF6B35),
      bodyColor: Color(0xFFFF8E53),
      price: 100,
      requiredLevel: 3,
    ),
    SnakeDesign(
      name: 'ice_snake'.tr(),
      headColor: Color(0xFF4ECDC4),
      bodyColor: Color(0xFF44A08D),
      price: 150,
      requiredLevel: 5,
    ),
    SnakeDesign(
      name: 'golden_snake'.tr(),
      headColor: Color(0xFFFFD700),
      bodyColor: Color(0xFFDAA520),
      price: 200,
      requiredLevel: 7,
    ),
    SnakeDesign(
      name: 'neon_snake'.tr(),
      headColor: Color(0xFF00FF41),
      bodyColor: Color(0xFF00CC33),
      price: 250,
      requiredLevel: 10,
    ),
    SnakeDesign(
      name: 'shadow_snake'.tr(),
      headColor: Color(0xFF2D1B69),
      bodyColor: Color(0xFF11998E),
      price: 300,
      requiredLevel: 12,
    ),
    SnakeDesign(
      name: 'rainbow_snake'.tr(),
      headColor: Color(0xFFFF006E),
      bodyColor: Color(0xFF8338EC),
      price: 400,
      requiredLevel: 15,
    ),
    SnakeDesign(
      name: 'cosmic_snake'.tr(),
      headColor: Color(0xFF6A0572),
      bodyColor: Color(0xFFAB83A1),
      price: 500,
      requiredLevel: 20,
    ),
  ];
}
