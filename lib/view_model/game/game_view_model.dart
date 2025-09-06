import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/helpers/sound_helper.dart';
import 'package:snake_game/model/model/level.dart';
import '../../model/model/game_padding.dart';

// Game mode enumeration
enum GameMode {
  levelMode, // Progressive level unlocking
  freeMode, // Infinite play with high score tracking
}

class GameViewModel extends ChangeNotifier {
  GameViewModel() {
    loadGameProgress();
    _initializeLevelsData();
  }
  int _rows = 20;
  int _columns = 20;
  double _cellSize = 20.0;

  // Game mode and state management
  GameMode currentGameMode = GameMode.levelMode;
  int maxUnlockedLevel = 1;
  int highScore = 0;
  bool hasNewHighScore = false;
  bool isGameInitialized = false;
  // Visual effects and animations
  bool isFoodSmall = true;
  bool isBigScoreCellSmall = true;
  bool isBigScoreCellShouldAppear = false;
  int eatFoodCounterToShowBigCell = 0;
  bool showParticles = false;
  Color? customGridColor;
  AnimationController? bigScoreAnimationController;
  AnimationController? nextLevelAnimationController;

  final Duration _baseDuration = const Duration(milliseconds: 200);
  Duration get _currentDuration {
    int dynamicReduction = (currentLevelIndex * 3);

    return Duration(
      milliseconds: max(75, _baseDuration.inMilliseconds - dynamicReduction),
    );
  }

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
  int maxLevels = 0;
  double currentLevelProgressInPercentage = 0.0;
  int currentLevelProgress = 0;
  int currentLevelMaxScore = 0;
  Function onGameCompleted = () {};
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

  void setGameMode(GameMode mode, {int? selectedLevel}) {
    currentGameMode = mode;
    if (mode == GameMode.freeMode) {
      currentLevelIndex = selectedLevel ?? 0;
    } else {
      currentLevelIndex = 0;
    }
    notifyListeners();
  }

  void _calculateGridDimensions(Size availableSize) {
    _columns = 20;
    _rows = 20;

    double cellWidth = availableSize.width / _columns;
    double cellHeight = availableSize.height / _rows;
    _cellSize = min(cellWidth, cellHeight).floorToDouble();
  }

  void _initializeLevelsData() {
    List<GameLevel> generatedLevels = generateLevels(150);
    gameLevels = generatedLevels;
    maxLevels = gameLevels.length;
  }

  void initializeGame(
    BuildContext context,
    GamePadding gamePaddings, {
    int? startLevelIndex,
  }) {
    isGameInitialized = false;
    notifyListeners();

    _gamePadding = gamePaddings;
    _calculateGridDimensions(Size(gamePaddings.width, gamePaddings.height));

    currentLevelIndex = startLevelIndex ?? 0;
    maxLevels = gameLevels.length;

    _initializeLevel();

    startGame();

    isGameInitialized = true;
    notifyListeners();
  }

  void _initializeLevel() {
    if (currentLevelIndex >= gameLevels.length) {
      currentLevelIndex = gameLevels.length - 1;
    }
    GameLevel currentLevel = gameLevels[currentLevelIndex];
    _snake = List.from(currentLevel.snake);
    barriers = currentLevel.levelBarriers;
    currentLevelMaxScore = currentLevel.maxScore;
    currentLevelProgress = 0;
    currentLevelProgressInPercentage = 0.0;
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
    _timer = Timer.periodic(_currentDuration, (timer) {
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

  void nextLevel() {
    if (currentGameMode == GameMode.levelMode &&
        currentLevelIndex < maxLevels - 1) {
      currentLevelIndex++;
      restartGame();
    }
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
    _updateProgress();
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

  void _updateProgress() {
    // In free mode, there's no progress to update, the game is endless.
    if (currentGameMode == GameMode.freeMode) return;

    // Only update progress in level mode.
    currentLevelProgress = _numericScore;
    currentLevelProgressInPercentage =
        currentLevelProgress / currentLevelMaxScore;
    if (currentLevelProgressInPercentage >= 1.0) {
      currentLevelProgressInPercentage = 1.0;
      _levelCompleted();
    }
  }

  void _levelCompleted() {
    if (!_isPlaying) return;
    _timer?.cancel();
    _isPlaying = false;
    saveGameProgress().then((_) {
      _playLevelCompleteSound();
      // UnityAdsHelper.showInterstitialAd();
      onGameCompleted();
      notifyListeners();
    });
  }

  void _gameOver() {
    if (!_isPlaying) return;
    _timer?.cancel();
    _isPlaying = false;
    if (_numericScore > highScore) {
      highScore = _numericScore;
      hasNewHighScore = true;
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


Offset _findSafeStartingPosition(List<Offset> barriers, int initialSnakeLength) {
  List<Offset> allPossiblePositions = [];
  for (int y = initialSnakeLength; y < _rows - 2; y++) {
    for (int x = 2; x < _columns - 2; x++) {
      allPossiblePositions.add(Offset(x.toDouble(), y.toDouble()));
    }
  }

  allPossiblePositions.shuffle(Random());

  for (Offset potentialHeadPos in allPossiblePositions) {
    bool isCompletelySafe = true;

    List<Offset> potentialSnake = List.generate(
        initialSnakeLength, (index) => Offset(potentialHeadPos.dx, potentialHeadPos.dy - index));

    for (Offset segment in potentialSnake) {
      if (barriers.contains(segment)) {
        isCompletelySafe = false;
        break;
      }
    }

    if (!isCompletelySafe) {
      continue; 
    }

    Offset rightOfHead = Offset(potentialHeadPos.dx + 1, potentialHeadPos.dy);
    Offset leftOfHead = Offset(potentialHeadPos.dx - 1, potentialHeadPos.dy);
    Offset aboveHead = Offset(potentialHeadPos.dx, potentialHeadPos.dy - 1);
    Offset belowHead = Offset(potentialHeadPos.dx, potentialHeadPos.dy + 1);

    if (barriers.contains(rightOfHead) &&
        barriers.contains(leftOfHead) &&
        barriers.contains(aboveHead) &&
        barriers.contains(belowHead)) {
      isCompletelySafe = false;
    }

    if (isCompletelySafe) {
      if (!barriers.contains(rightOfHead)) {
        _direction = 'right';
        _nextDirection = 'right';
      } else if (!barriers.contains(leftOfHead)) {
        _direction = 'left';
        _nextDirection = 'left';
      } else if (!barriers.contains(belowHead)) {
        _direction = 'down';
        _nextDirection = 'down';
      } else {
        _direction = 'up';
        _nextDirection = 'up';
      }
      return potentialHeadPos;
    }
  }

  // في أسوأ الحالات، نعود لمكان آمن معروف ومضمون
  return const Offset(10, 10);
}

  List<Offset> _getCornerClustersPattern() {
    List<Offset> barriers = [];
    for (int i = 2; i < 6; i++) {
      for (int j = 2; j < 6; j++) {
        barriers.add(Offset(i.toDouble(), j.toDouble())); // Top-Left
        barriers.add(
          Offset((_columns - 1 - i).toDouble(), j.toDouble()),
        ); // Top-Right
        barriers.add(
          Offset(i.toDouble(), (_rows - 1 - j).toDouble()),
        ); // Bottom-Left
        barriers.add(
          Offset((_columns - 1 - i).toDouble(), (_rows - 1 - j).toDouble()),
        ); // Bottom-Right
      }
    }
    return barriers;
  }

  List<Offset> _getMazePattern() {
    List<Offset> barriers = [];
    for (int i = 0; i < 14; i++) {
      barriers.add(Offset(4, i.toDouble()));
      barriers.add(Offset(15, (_rows - 1 - i).toDouble()));
    }
    for (int i = 9; i < _columns; i++) {
      barriers.add(Offset(i.toDouble(), 7));
    }
    return barriers;
  }

  List<Offset> _getParallelLinesPattern() {
    List<Offset> barriers = [];
    for (int i = 4; i < _rows - 4; i++) {
      barriers.add(Offset(6, i.toDouble()));
      barriers.add(Offset(13, i.toDouble()));
    }
    return barriers;
  }

  List<Offset> _getCrossPattern() {
    List<Offset> barriers = [];
    for (int i = 5; i < _columns - 5; i++) {
      barriers.add(Offset(i.toDouble(), 9));
    }
    for (int i = 5; i < _rows - 5; i++) {
      barriers.add(Offset(9, i.toDouble()));
    }
    return barriers;
  }

  List<Offset> _getCentralBoxPattern() {
    List<Offset> barriers = [];
    for (int i = 6; i < _columns - 6; i++) {
      barriers.add(Offset(i.toDouble(), 6));
    }
    for (int i = 7; i < _rows - 7; i++) {
      if (i < (_rows / 2) - 2 || i > (_rows / 2) + 1) {
        barriers.add(Offset(6, i.toDouble()));
        barriers.add(Offset(_columns - 7, i.toDouble()));
      }
    }
    return barriers;
  }

  List<Offset> _getDiagonalLinesPattern() {
    List<Offset> barriers = [];
    for (int i = 4; i < 16; i++) {
      barriers.add(Offset(i.toDouble(), i.toDouble()));
      barriers.add(Offset((_columns - 1 - i).toDouble(), i.toDouble()));
    }
    return barriers;
  }

  List<GameLevel> generateLevels(int count) {
    List<GameLevel> generatedLevels = [];
    final basePatterns = [
      _getParallelLinesPattern,
      _getCornerClustersPattern,
      _getMazePattern,
      _getCentralBoxPattern,
    ];

    for (int i = 0; i < count; i++) {
      int levelNumber = i + 1;
      List<Offset> barriers;
      Color? customBoardColor;
      Color? customGridColor;

      if (levelNumber <= 10) {
        barriers = [];
      } else if (levelNumber <= 30) {
        barriers = basePatterns[(levelNumber - 11) % basePatterns.length]();
      } else if (levelNumber <= 60) {
        barriers = basePatterns[(levelNumber - 31) % basePatterns.length]();
        barriers.addAll(_getCrossPattern());
      } else if (levelNumber <= 90) {
        barriers = basePatterns[(levelNumber - 61) % basePatterns.length]();
        barriers.addAll(_getCrossPattern());
      } else if (levelNumber <= 120) {
        barriers = basePatterns[(levelNumber - 91) % basePatterns.length]();
        barriers.addAll(_getCrossPattern());
      } else {
        barriers = basePatterns[(levelNumber - 121) % basePatterns.length]();
        barriers.addAll(_getDiagonalLinesPattern());
      }

      if (levelNumber > 100) {
        customBoardColor = const Color(0xFF1A1A2E).withOpacity(0.5);
        customGridColor = customBoardColor;
      }

      int initialSnakeLength = 4 + (i ~/ 20);
      Offset startPosition = _findSafeStartingPosition(
        barriers,
        initialSnakeLength,
      );

      generatedLevels.add(
        GameLevel(
          levelNumber: levelNumber,
          levelBarriers: [barriers],
          maxScore: 250 + (i * 10),
          snake: List.generate(
            initialSnakeLength,
            (index) => Offset(startPosition.dx, startPosition.dy - index),
          ),
          boardColor: customBoardColor,
          gridColor: customGridColor,
        ),
      );
    }
    return generatedLevels;
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
    maxUnlockedLevel = prefs.getInt('maxUnlockedLevel') ?? 1;
    notifyListeners();
  }

  Future<void> saveGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
    if (currentGameMode == GameMode.levelMode) {
      if (currentLevelProgressInPercentage >= 1.0 &&
          currentLevelIndex + 2 > maxUnlockedLevel) {
        maxUnlockedLevel = (currentLevelIndex + 2).clamp(1, maxLevels + 1);
        await prefs.setInt('maxUnlockedLevel', maxUnlockedLevel);
      }
    }
  }

  String getFormattedHighScore() {
    return highScore.toString().padLeft(6, '0');
  }

  // Sound Methods
  void _playEatSound() {
    SoundHelper.instance.playEatSound();
  }

  void _playGameOverSound() {
    SoundHelper.instance.playGameOverSound();
  }

  void _playLevelCompleteSound() {
    SoundHelper.instance.playLevelCompleteSound();
  }

  List<Offset> getRandomizedBarriers(int level) {
    List<Offset> barriers = [];
    Random random = Random(level);
    int barrierCount = 5 + (level ~/ 5);
    for (int i = 0; i < barrierCount; i++) {
      int x = 4 + random.nextInt(_columns - 8);
      int y = 4 + random.nextInt(_rows - 8);
      barriers.add(Offset(x.toDouble(), y.toDouble()));
    }
    return barriers;
  }

  List<Offset> getVerticalPassagesBarriers(int level) {
    List<Offset> barriers = [];
    int passageGap = max(3, 6 - (level ~/ 20));
    for (int i = 0; i < _rows; i++) {
      if (i % passageGap != 0 && i % passageGap != 1) {
        barriers.add(Offset(6, i.toDouble()));
        barriers.add(Offset(13, i.toDouble()));
      }
    }
    return barriers;
  }

  List<Offset> getSimpleMazeBarriers() {
    List<Offset> barriers = [];
    for (int i = 0; i < 15; i++) {
      barriers.add(Offset(4, i.toDouble()));
      barriers.add(Offset(15, (_rows - 1 - i).toDouble()));
    }
    for (int i = 4; i < 10; i++) {
      barriers.add(Offset(i.toDouble(), 14));
    }
    return barriers;
  }

  @override
  void dispose() {
    _timer?.cancel();
    bigScoreAnimationController?.dispose();
    nextLevelAnimationController?.dispose();
    super.dispose();
  }
}
