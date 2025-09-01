import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/helpers/sound_helper.dart';
import 'package:snake_game/model/model/level.dart';
import '../../model/model/game_padding.dart';

class FreeModeGameViewModel extends ChangeNotifier {
  int _rows = 20;
  int _columns = 20;
  double _cellSize = 20.0;

  // Game state management
  int highScore = 0;
  bool hasNewHighScore = false;
  Map<int, int> levelHighScores = {}; // Store high scores per level

  // Visual effects and animations
  bool isFoodSmall = true;
  bool isBigScoreCellSmall = true;
  bool isBigScoreCellShouldAppear = false;
  int eatFoodCounterToShowBigCell = 0;
  bool showParticles = false;

  AnimationController? bigScoreAnimationController;

  final Duration _baseDuration = const Duration(milliseconds: 150);

  String score = "000000";
  int _numericScore = 0;
  late List<Offset> _snake;
  late Offset _food;
  late Offset _bigScoreCell;
  String _direction = 'right';
  String _nextDirection = 'right';
  bool _isPlaying = true;
  bool _isPaused = false;
  Timer? _timer;
  int _movementCounter = 0; // Counter for body image alternation

  late GamePadding _gamePadding;
  List<List<Offset>> barriers = [];
  List<GameLevel> gameLevels = [];
  int currentLevelIndex = 0;

  Function onGameOver = () {};

  // Getters
  int get rows => _rows;
  int get columns => _columns;
  double get cellSize => _cellSize;
  List<Offset> get snake => _snake;
  Offset get food => _food;
  Offset get bigScoreCell => _bigScoreCell;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  Timer? get timer => _timer;
  GamePadding get gamePadding => _gamePadding;
  String get direction => _direction;
  int get movementCounter => _movementCounter;

  void _calculateGridDimensions(Size availableSize) {
    _columns = 20;
    _rows = 20;

    double cellWidth = availableSize.width / _columns;
    double cellHeight = availableSize.height / _rows;
    _cellSize = min(cellWidth, cellHeight).floorToDouble();
  }

  void initializeGame(
    BuildContext context,
    GamePadding gamePaddings, {
    int? startLevelIndex,
  }) {
    _gamePadding = gamePaddings;
    _calculateGridDimensions(Size(gamePaddings.width, gamePaddings.height));
    currentLevelIndex = startLevelIndex ?? 0;

    // Define the base levels for map layouts
    List<GameLevel> baseLevels = [
      GameLevel(
        levelNumber: 1,
        levelBarriers: [getBarriersLevelOne()],
        maxScore: 999999999999999999,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 2,
        levelBarriers: [getBarriersLevelTwo()],
        maxScore: 999999999999999999,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 3,
        levelBarriers: [getBarriersLevelThree()],
        maxScore: 999999999999999999,
        snake: List.generate(4, (index) => Offset(2, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 4,
        levelBarriers: [getBarriersLevelFour()],
        maxScore: 999999999999999999,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 5,
        levelBarriers: [getBarriersLevelFive()],
        maxScore: 999999999999999999,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
    ];
    gameLevels = baseLevels;

    loadGameProgress().then((_) {
      _initializeLevel();
      startGame();
    });
  }

  void _initializeLevel() {
    if (currentLevelIndex >= gameLevels.length) {
      currentLevelIndex = gameLevels.length - 1;
    }
    GameLevel currentLevel = gameLevels[currentLevelIndex];
    _snake = List.from(currentLevel.snake);
    barriers = currentLevel.levelBarriers;
    _numericScore = 0;
    score = "000000";
    _direction = 'right';
    _nextDirection = 'right';
    hasNewHighScore = false;
    _generateFood();
    _generateBigScoreCell();
    eatFoodCounterToShowBigCell = 0;
    isBigScoreCellShouldAppear = false;
    showParticles = false;
    notifyListeners();
  }

  void startGame() {
    _timer?.cancel();
    _isPlaying = true;
    _isPaused = false;
    _timer = Timer.periodic(_baseDuration, (timer) {
      if (!_isPaused) _moveSnake();
    });
  }

  void pauseGame() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeGame() {
    _isPaused = false;
    notifyListeners();
  }

  void restartGame() {
    _initializeLevel();
    startGame();
  }

  void changeDirection(String newDirection) {
    if ((_direction == 'up' && newDirection == 'down') ||
        (_direction == 'down' && newDirection == 'up') ||
        (_direction == 'left' && newDirection == 'right') ||
        (_direction == 'right' && newDirection == 'left')) {
      return;
    }
    _nextDirection = newDirection;
  }

  void _moveSnake() {
    if (!_isPlaying || _isPaused) return;
    _direction = _nextDirection;
    List<Offset> newSnake = List.from(_snake);
    Offset head = newSnake.first;
    Offset newHead;
    switch (_direction) {
      case 'up':
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case 'down':
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case 'left':
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case 'right':
        newHead = Offset(head.dx + 1, head.dy);
        break;
      default:
        newHead = head;
        break;
    }

    newHead = Offset(
      newHead.dx.roundToDouble() % _columns,
      newHead.dy.roundToDouble() % _rows,
    );
    if (newHead.dx < 0) newHead = Offset(_columns - 1, newHead.dy);
    if (newHead.dy < 0) newHead = Offset(newHead.dx, _rows - 1);

    if (newSnake.contains(newHead) || _isBarrierCollision(newHead)) {
      _gameOver();
      return;
    }

    newSnake.insert(0, newHead);

    if (newHead == _food) {
      _eatFood();
    } else if (isBigScoreCellShouldAppear && newHead == _bigScoreCell) {
      _eatBigScoreCell();
    } else {
      newSnake.removeLast();
    }
    _snake = newSnake;
    _movementCounter++; // Increment counter for body image alternation
    notifyListeners();
  }

  bool _isBarrierCollision(Offset position) {
    return barriers.any((barrierList) => barrierList.contains(position));
  }

  void _eatFood() {
    _addScore(10);
    _generateFood();
    showParticles = true;
    _playEatSound();
    if (++eatFoodCounterToShowBigCell == 5) {
      isBigScoreCellShouldAppear = true;
      eatFoodCounterToShowBigCell = 0;
    }
    notifyListeners();
  }

  void _eatBigScoreCell() {
    _addScore(30);
    isBigScoreCellShouldAppear = false;
    _generateBigScoreCell();
    _playEatSound();
    notifyListeners();
  }

  void _addScore(int points) {
    _numericScore += points;
    score = _numericScore.toString().padLeft(6, '0');
  }

  void _gameOver() {
    if (!_isPlaying) return;
    _timer?.cancel();
    _isPlaying = false;

    // Check for level-specific high score first
    int currentLevelHighScore = levelHighScores[currentLevelIndex] ?? 0;
    if (_numericScore > currentLevelHighScore) {
      levelHighScores[currentLevelIndex] = _numericScore;
      hasNewHighScore =
          true; // Set achievement flag for level-specific high score
    } else {
      hasNewHighScore = false; // No new achievement for this level
    }

    // Update overall high score if needed (but don't use for achievement dialog)
    if (_numericScore > highScore) {
      highScore = _numericScore;
    }

    saveGameProgress().then((_) {
      _playGameOverSound();
      onGameOver();
      notifyListeners();
    });
  }

  void _generateFood() {
    Random random = Random();
    do {
      _food = Offset(
        random.nextInt(_columns).toDouble(),
        random.nextInt(_rows).toDouble(),
      );
    } while (_snake.contains(_food) || _isBarrierCollision(_food));
  }

  void _generateBigScoreCell() {
    Random random = Random();
    do {
      _bigScoreCell = Offset(
        random.nextInt(_columns).toDouble(),
        random.nextInt(_rows).toDouble(),
      );
    } while (_snake.contains(_bigScoreCell) ||
        _isBarrierCollision(_bigScoreCell) ||
        _food == _bigScoreCell);
  }

  List<Offset> getBarriersLevelOne() => [];
  List<Offset> getBarriersLevelTwo() {
    List<Offset> barriers = [];
    for (int i = 0; i < 10; i++) {
      barriers.add(Offset(5, i.toDouble()));
      barriers.add(Offset(14, (_rows - 1 - i).toDouble()));
    }
    return barriers;
  }

  List<Offset> getBarriersLevelThree() {
    List<Offset> barriers = [];
    for (int i = 0; i < _columns; i++) {
      if (i < 5 || i > _columns - 6) {
        barriers.add(Offset(i.toDouble(), 4));
        barriers.add(Offset(i.toDouble(), _rows - 5));
      }
    }
    return barriers;
  }

  List<Offset> getBarriersLevelFour() {
    List<Offset> barriers = [];
    for (int i = 0; i < 7; i++) {
      barriers.add(Offset(i.toDouble(), 5));
      barriers.add(Offset((_columns - 1 - i).toDouble(), 5));
      barriers.add(Offset(i.toDouble(), _rows - 6));
      barriers.add(Offset((_columns - 1 - i).toDouble(), _rows - 6));
    }
    return barriers;
  }

  List<Offset> getBarriersLevelFive() {
    List<Offset> barriers = [];
    for (int i = 0; i < _columns; i++) {
      barriers.add(Offset(i.toDouble(), 0));
      barriers.add(Offset(i.toDouble(), _rows - 1));
    }
    for (int i = 1; i < _rows - 1; i++) {
      barriers.add(Offset(0, i.toDouble()));
      barriers.add(Offset(_columns - 1, i.toDouble()));
    }
    return barriers;
  }

  Future<void> loadGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;

    // Load level-specific high scores for all 20 levels
    for (int i = 0; i < 20; i++) {
      levelHighScores[i] = prefs.getInt('levelHighScore_$i') ?? 0;
    }

    notifyListeners();
  }

  Future<void> saveGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);

    // Save level-specific high scores
    for (int levelIndex in levelHighScores.keys) {
      await prefs.setInt(
        'levelHighScore_$levelIndex',
        levelHighScores[levelIndex]!,
      );
    }
  }

  String getFormattedHighScore() {
    return highScore.toString().padLeft(6, '0');
  }

  // Get high score for a specific level
  int getLevelHighScore(int levelIndex) {
    return levelHighScores[levelIndex] ?? 0;
  }

  // Get formatted high score for a specific level
  String getFormattedLevelHighScore(int levelIndex) {
    int score = getLevelHighScore(levelIndex);
    return score > 0 ? score.toString() : "0";
  }

  // Static method to get level high score from SharedPreferences
  static Future<int> getStaticLevelHighScore(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('levelHighScore_$levelIndex') ?? 0;
  }

  // Static method to get the maximum score across all Free Mode levels
  static Future<int> getMaxFreeModeScore() async {
    final prefs = await SharedPreferences.getInstance();
    int maxScore = 0;

    // Check scores for all 20 levels (0-19)
    for (int i = 0; i < 20; i++) {
      int levelScore = prefs.getInt('levelHighScore_$i') ?? 0;
      if (levelScore > maxScore) {
        maxScore = levelScore;
      }
    }

    return maxScore;
  }

  // Sound Methods
  void _playEatSound() {
    SoundHelper.instance.playEatSound();
  }

  void _playGameOverSound() {
    SoundHelper.instance.playGameOverSound();
  }
}
