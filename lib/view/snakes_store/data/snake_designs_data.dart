import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../model/snake_design.dart';

class SnakeDesignsData {
  static final List<SnakeDesign> snakeDesigns = [
    SnakeDesign(
      //0
      name: 'classic_snake'.tr(),
      headColor: Color(0xFF58A6FF),
      bodyColor: Color(0xFF1F6FEB),
      price: 0,
      requiredLevel: 1,
      isDefault: true,
      imgPaths: ['assets/images/LorenzosNewSnakeAssets/head/Head.png'],
    ),
    SnakeDesign(
      //1
      name: 'second-snake'.tr(),
      headColor: Color(0xFFFF6B35),
      bodyColor: Color(0xFFFF8E53),
      price: 3000,
      requiredLevel: 2,
      imgPaths: [
        'assets/images/new/head.png',
        'assets/images/new/hor.png',
        'assets/images/new/hor.png',
        'assets/images/new/ver.png',
        'assets/images/new/ver.png',
        'assets/images/new/bottom-right.png',
        'assets/images/new/bottom-left.png',
        'assets/images/new/top-right.png',
        'assets/images/new/top-left.png',
      ],
    ),
    SnakeDesign(
      //2
      name: 'ice_snake'.tr(),
      headColor: Color(0xFF4ECDC4),
      bodyColor: Color(0xFF44A08D),
      price: 150,
      requiredLevel: 5,
      imgPaths: [
        'assets/images/snakeShapes/icy_snake/Head.png',
        'assets/images/snakeShapes/icy_snake/snake_body256_horizontal00.png',
        'assets/images/snakeShapes/icy_snake/snake_body256_horizontal01.png',
        'assets/images/snakeShapes/icy_snake/snake_body256_vertical00.png',
        'assets/images/snakeShapes/icy_snake/snake_body256_vertical01.png',
      ],
    ),
    SnakeDesign(
      //3
      name: 'golden_snake'.tr(),
      headColor: Color(0xFFFFD700),
      bodyColor: Color(0xFFDAA520),
      price: 200,
      requiredLevel: 7,
      imgPaths: [
        'assets/images/snakeShapes/golden_snake/Head.png',
        'assets/images/snakeShapes/golden_snake/snake_body256_horizontal00.png',
        'assets/images/snakeShapes/golden_snake/snake_body256_horizontal01.png',
        'assets/images/snakeShapes/golden_snake/snake_body256_vertical00.png',
        'assets/images/snakeShapes/golden_snake/snake_body256_vertical01.png',
        'assets/images/snakeShapes/golden_snake/bottom-right.png',
        'assets/images/snakeShapes/golden_snake/bottom-left.png',
        'assets/images/snakeShapes/golden_snake/top-right.png',
        'assets/images/snakeShapes/golden_snake/top-left.png',
      ],
    ),
    SnakeDesign(
      //4
      name: 'neon_snake'.tr(),
      headColor: Color(0xFF00FF41),
      bodyColor: Color(0xFF00CC33),
      price: 250,
      requiredLevel: 10,
      imgPaths: ['assets/images/snakeShapes/redSnake.jpg'],
    ),
    SnakeDesign(
      //5
      name: 'cosmic_snake'.tr(),
      headColor: Color(0xFF6A0572),
      bodyColor: Color(0xFFAB83A1),
      price: 500,
      requiredLevel: 20,
      imgPaths: [
        'assets/images/snakeShapes/cosmic_snake/Head.png',
        'assets/images/snakeShapes/cosmic_snake/h00.png',
        'assets/images/snakeShapes/cosmic_snake/h01.png',
        'assets/images/snakeShapes/cosmic_snake/f0.png',
        'assets/images/snakeShapes/cosmic_snake/f01.png',
        'assets/images/snakeShapes/cosmic_snake/farha.png',
        'assets/images/snakeShapes/cosmic_snake/bottom_left.png',
        'assets/images/snakeShapes/cosmic_snake/top-right.png',
        'assets/images/snakeShapes/cosmic_snake/top-left.png',
      ],
    ),
  ];
}
