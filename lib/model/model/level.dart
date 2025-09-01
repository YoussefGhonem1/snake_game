import 'dart:ui';

class GameLevel{
  int levelNumber = 0;
  int maxScore = 0;
  List<Offset> snake = [];
  List<List<Offset>> levelBarriers = [];
  GameLevel({required this.levelNumber,required this.maxScore,required this.levelBarriers,required this.snake});
}