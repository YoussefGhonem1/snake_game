import 'dart:ui';

class GameLevel{
  int levelNumber = 0;
  int maxScore = 0;
  List<Offset> snake = [];
  final Color? boardColor;
  final Color? gridColor;
  List<List<Offset>> levelBarriers = [];
  GameLevel({required this.levelNumber,required this.maxScore,required this.levelBarriers,required this.snake ,this.boardColor,  this.gridColor,});
}