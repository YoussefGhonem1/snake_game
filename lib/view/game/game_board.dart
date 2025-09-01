import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import 'package:snake_game/core/constants/route_manager.dart';
import 'package:snake_game/core/helpers/navigate_helper.dart';
import 'package:snake_game/core/helpers/game_helper.dart';
import 'package:snake_game/model/model/game_padding.dart';
import 'package:snake_game/view_model/game/game_view_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.height,
    required this.width,
    this.startIndex,
  });
  final double height;
  final double width;
  final int? startIndex;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late GameViewModel gameViewModel;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _scoreController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );

    // Calculate optimal grid size to fit green zone perfectly
    double availableWidth = widget.width - 40; // Minimal padding
    double availableHeight = widget.height - 80; // Account for score bar space

    // Calculate cell size to fit 20x20 grid perfectly
    double cellWidth = availableWidth / 20;
    double cellHeight = availableHeight / 20;
    double cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight)
        .floorToDouble();

    // Ensure reasonable cell size bounds
    if (cellSize < 15.0) cellSize = 15.0;
    if (cellSize > 30.0) cellSize = 30.0;

    // Calculate exact grid dimensions
    double gridWidth = cellSize * 20;
    double gridHeight = cellSize * 20;

    // Center the grid horizontally
    double leftPadding = (widget.width - gridWidth) / 2;

    GamePadding gamePaddings = GamePadding(
      left: leftPadding,
      right: leftPadding,
      top: 100.0, // Moved score bar higher up
      height: gridHeight, // Exact grid height
      width: widget.width,
    );

    gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    gameViewModel.bigScoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    gameViewModel.nextLevelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    gameViewModel.initializeGame(
      context,
      gamePaddings,
      startLevelIndex: widget.startIndex,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _scoreController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Show pause dialog when app goes to background or becomes inactive
        if (gameViewModel.isPlaying && !gameViewModel.isPaused) {
          _pauseGame(); // This will pause the game AND show the dialog
        }
        break;
      case AppLifecycleState.resumed:
        // Game remains paused when app resumes - user must manually resume via dialog
        // This prevents accidental game continuation when switching apps
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state (app is hidden but still running)
        if (gameViewModel.isPlaying && !gameViewModel.isPaused) {
          _pauseGame(); // This will pause the game AND show the dialog
        }
        break;
    }
  }

  void _pauseGame() {
    gameViewModel.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPauseDialog(),
    );
  }

  Widget _buildPauseDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: ColorHelper.instance.gameBackgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorHelper.instance.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: ColorHelper.instance.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_filled,
              size: 60,
              color: ColorHelper.instance.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('game_paused'),
              style: TextStyle(
                color: ColorHelper.instance.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(
                      context.tr('resume'),
                      Icons.play_arrow,
                      () {
                        Navigator.of(context).pop();
                        gameViewModel.resumeGame();
                      },
                    ),
                    _buildDialogButton(
                      context.tr('restart'),
                      Icons.refresh,
                      () {
                        Navigator.of(context).pop();
                        gameViewModel.restartGame();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildDialogButton(context.tr('exit'), Icons.exit_to_app, () {
                  Navigator.of(context).pop(); // Close pause dialog
                  Navigator.of(context).pop(); // Exit game screen
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: ColorHelper.instance.onPrimary),
      label: Text(
        text,
        style: TextStyle(color: ColorHelper.instance.onPrimary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorHelper.instance.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  gameViewModel.onGameOver = _onGameOver;
  gameViewModel.onGameCompleted = _onGameCompleted;

  return Consumer<GameViewModel>(
    builder: (context, provider, _) {
      // -->> التحقق من حالة التحميل <<--
      if (!provider.isGameInitialized) {
        // إذا لم تكن اللعبة جاهزة، اعرض علامة التحميل
        return const Center(child: CircularProgressIndicator());
      }

      // إذا كانت اللعبة جاهزة، اعرض لوحة اللعب
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          if (!GameHelper.instance.isSwipe) return;
          if (details.delta.dy > 0) {
            provider.changeDirection('down');
          } else if (details.delta.dy < 0) {
            provider.changeDirection('up');
          }
        },
        onHorizontalDragUpdate: (details) {
          if (!GameHelper.instance.isSwipe) return;
          if (details.delta.dx > 0) {
            provider.changeDirection('right');
          } else if (details.delta.dx < 0) {
            provider.changeDirection('left');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: ColorHelper.instance.gameBackgroundGradient,
          ),
          child: Stack(
            children: [_buildGameArea(provider), _buildUI(provider)],
          ),
        ),
      );
    },
  );
}
  Widget _buildGameArea(GameViewModel provider) {
    return Positioned(
      left: provider.gamePadding.left,
      right: provider.gamePadding.right,
      top:
          provider.gamePadding.top +
          25, // Minimal offset for maximum game space
      bottom: 65, // Final micro-adjustment to show complete snake
      child: Center(
        child: Container(
          width:
              provider.gamePadding.width -
              provider.gamePadding.left -
              provider.gamePadding.right,
          clipBehavior:
              Clip.none, // Allow content to extend beyond bounds if needed
          child: Stack(
            clipBehavior: Clip.none, // Prevent clipping of snake segments
            children: [
              _buildGrid(provider),
              _buildBarriers(provider),
              _buildFood(provider),
              _buildSnake(provider),
              if (provider.isBigScoreCellShouldAppear)
                _buildBigScoreCell(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(GameViewModel provider) {
    return CustomPaint(
      painter: GridPainter(
        cellSize: provider.cellSize,
        rows: provider.rows,
        columns: provider.columns,
      ),
      size: Size(
        math.max(0, provider.columns * provider.cellSize),
        math.max(0, provider.rows * provider.cellSize),
      ),
    );
  }

  Widget _buildBarriers(GameViewModel provider) {
    return Stack(
      children: provider.barriers.expand((barrierList) {
        return barrierList.map((barrier) {
          return AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Positioned(
                left: barrier.dx * provider.cellSize,
                top: barrier.dy * provider.cellSize,
                child: Container(
                  width: provider.cellSize,
                  height: provider.cellSize,
                  decoration: BoxDecoration(
                    color: ColorHelper.instance.barrierColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: ColorHelper.instance.barrierGlowColor
                            .withOpacity(
                              0.5 +
                                  0.3 *
                                      math.sin(
                                        _glowAnimation.value * 2 * math.pi,
                                      ),
                            ),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      }).toList(),
    );
  }

  Widget _buildFood(GameViewModel provider) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: provider.food.dx * provider.cellSize,
          top: provider.food.dy * provider.cellSize,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: provider.cellSize,
              height: provider.cellSize,
              decoration: BoxDecoration(
                gradient: ColorHelper.instance.foodGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorHelper.instance.foodGlowColor.withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: provider.cellSize * 0.6,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnake(GameViewModel provider) {
    return Stack(
      children: provider.snake.asMap().entries.map((entry) {
        int index = entry.key;
        Offset segment = entry.value;
        bool isHead = index == 0;
        bool isTail = index == provider.snake.length - 1;

        // Adjust positioning for larger head to center it
        double leftPos = segment.dx * provider.cellSize;
        double topPos = segment.dy * provider.cellSize;

        if (isHead) {
          // Center the larger head by offsetting position
          double headSize = provider.cellSize * 1.3;
          double offset = (headSize - provider.cellSize) / 2;
          leftPos -= offset;
          topPos -= offset;
        }

        return Positioned(
          left: leftPos,
          top: topPos,
          child: _buildSnakeSegment(provider, index, segment, isHead, isTail),
        );
      }).toList(),
    );
  }

  Widget _buildSnakeSegment(
    GameViewModel provider,
    int index,
    Offset segment,
    bool isHead,
    bool isTail,
  ) {
    if (isHead) {
      return _buildSnakeHead(provider);
    } else if (isTail) {
      return _buildSnakeTail(provider);
    } else {
      return _buildSnakeBody(provider, index, segment);
    }
  }

  Widget _buildSnakeHead(GameViewModel provider) {
    double rotation = _getHeadRotation(provider.direction);

    return Transform.rotate(
      angle: rotation,
      child: Center(
        child: Container(
          width: provider.cellSize * 1.3, // More reasonable size
          height: provider.cellSize * 1.3,
          child: Image.asset(
            'assets/images/LorenzosNewSnakeAssets/head/Head.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSnakeTail(GameViewModel provider) {
    double rotation = _getTailRotation(provider);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: provider.cellSize,
        height: provider.cellSize,
        child: Image.asset(
          'assets/images/LorenzosNewSnakeAssets/tail/256px/tail_final00.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSnakeBody(GameViewModel provider, int index, Offset segment) {
    // Check if this segment is a corner (direction change)
    String segmentType = _getSegmentType(provider, index, segment);
    String imagePath = _getBodyImagePath(segmentType, index, provider, segment);
    double rotation = _getBodyRotation(segmentType, provider, index, segment);

    // Adjust size and position based on segment type
    double segmentWidth = provider.cellSize;
    double segmentHeight = provider.cellSize;
    double offsetX = 0;
    double offsetY = 0;

    if (segmentType == 'left_corner' || segmentType == 'right_corner') {
      // Keep corners full size but add positioning offset for better alignment
      offsetX = provider.cellSize * 0.00; // Small offset for better connection
      offsetY = provider.cellSize * 0.00;
    } else {
      // Adjust width/height based on movement direction
      if (segmentType == 'horizontal') {
        // For horizontal movement, reduce HEIGHT to make it thinner
        segmentHeight *= 1;
      } else if (segmentType == 'vertical') {
        // For vertical movement, reduce WIDTH to make it thinner
        segmentWidth *= 1;
      }
    }

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: segmentWidth,
          height: segmentHeight,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  double _getHeadRotation(String direction) {
    switch (direction) {
      case 'up':
        return math.pi; // Face up (opposite of default)
      case 'right':
        return -math.pi / 2; // Face right
      case 'down':
        return 0; // Face down (default orientation)
      case 'left':
        return math.pi / 2; // Face left
      default:
        return 0;
    }
  }

  double _getTailRotation(GameViewModel provider) {
    if (provider.snake.length < 2) return 0;

    Offset tail = provider.snake.last;
    Offset beforeTail = provider.snake[provider.snake.length - 2];

    // Calculate direction from before-tail to tail
    double dx = tail.dx - beforeTail.dx;
    double dy = tail.dy - beforeTail.dy;

    if (dx > 0) return math.pi / 2; // Moving right
    if (dx < 0) return -math.pi / 2; // Moving left
    if (dy > 0) return math.pi; // Moving down
    if (dy < 0) return 0; // Moving up

    return 0;
  }

  String _getSegmentType(GameViewModel provider, int index, Offset segment) {
    if (index == 0 || index == provider.snake.length - 1) {
      return 'straight'; // Head and tail are handled separately
    }

    Offset prevSegment = provider.snake[index - 1];
    Offset nextSegment = provider.snake[index + 1];

    // Calculate directions
    double prevDx = segment.dx - prevSegment.dx;
    double prevDy = segment.dy - prevSegment.dy;
    double nextDx = nextSegment.dx - segment.dx;
    double nextDy = nextSegment.dy - segment.dy;

    // Check if it's a corner (direction change)
    if ((prevDx != 0 && nextDy != 0) || (prevDy != 0 && nextDx != 0)) {
      // Determine corner type
      if ((prevDx > 0 && nextDy > 0) || (prevDy < 0 && nextDx > 0)) {
        return 'right_corner';
      } else {
        return 'left_corner';
      }
    }

    // It's a straight segment
    if (prevDx != 0 || nextDx != 0) {
      return 'horizontal';
    } else {
      return 'vertical';
    }
  }

  String _getBodyImagePath(
    String segmentType,
    int index,
    GameViewModel provider,
    Offset segment,
  ) {
    // Straight segments keep alternating images for wavy effect
    if (segmentType == 'horizontal') {
      return (gameViewModel.movementCounter + index) % 2 == 0
          ? 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal00.png'
          : 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal01.png';
    }
    if (segmentType == 'vertical') {
      return (gameViewModel.movementCounter + index) % 2 == 0
          ? 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_vertical00.png'
          : 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_vertical01.png';
    }

    // Corners: use orientation-specific connector images based on turn direction
    if (index > 0 && index < provider.snake.length - 1) {
      Offset prevSegment = provider.snake[index - 1];
      Offset nextSegment = provider.snake[index + 1];

      double prevDx = segment.dx - prevSegment.dx;
      double prevDy = segment.dy - prevSegment.dy;
      double nextDx = nextSegment.dx - segment.dx;
      double nextDy = nextSegment.dy - segment.dy;

      // Updated mapping with new clearer image names
      // right2down: bottom-right corner (coming from left/up, going to right/down)
      if ((prevDx < 0 && nextDy > 0) || (prevDy < 0 && nextDx > 0))
        return 'assets/images/LorenzosNewSnakeAssets/body/256px/right2down_connector.png';

      // left2down: bottom-left corner (coming from right/up, going to left/down)
      if ((prevDx > 0 && nextDy > 0) || (prevDy < 0 && nextDx < 0))
        return 'assets/images/LorenzosNewSnakeAssets/body/256px/left2down_connector.png';

      // right2up: top-right corner (coming from left/down, going to right/up)
      if ((prevDx < 0 && nextDy < 0) || (prevDy > 0 && nextDx > 0))
        return 'assets/images/LorenzosNewSnakeAssets/body/256px/right2up_connector.png';

      // left2up: top-left corner (coming from right/down, going to left/up)
      if ((prevDx > 0 && nextDy < 0) || (prevDy > 0 && nextDx < 0))
        return 'assets/images/LorenzosNewSnakeAssets/body/256px/left2up_connector.png';
    }

    // Fallback
    return 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal00.png';
  }

  double _getBodyRotation(
    String segmentType,
    GameViewModel provider,
    int index,
    Offset segment,
  ) {
    // Corner images are orientation-specific now; no rotation needed
    if (segmentType == 'left_corner' || segmentType == 'right_corner') {
      return 0;
    }
    return 0; // No rotation for straight segments
  }

  Widget _buildBigScoreCell(GameViewModel provider) {
    return AnimatedBuilder(
      animation: _scoreController,
      builder: (context, child) {
        return Positioned(
          left: provider.bigScoreCell.dx * provider.cellSize,
          top: provider.bigScoreCell.dy * provider.cellSize,
          child: Transform.scale(
            scale: _scoreAnimation.value,
            child: Container(
              width: provider.cellSize * 1.5,
              height: provider.cellSize * 1.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    ColorHelper.instance.scoreColor,
                    ColorHelper.instance.scoreColor.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorHelper.instance.scoreColor.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '★',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: provider.cellSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUI(GameViewModel provider) {
    return Column(children: [_buildTopBar(provider), const Spacer()]);
  }

  Widget _buildTopBar(GameViewModel provider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorHelper.instance.secondary.withOpacity(0.9),
            ColorHelper.instance.secondary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: ColorHelper.instance.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorHelper.instance.primary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreDisplay(provider),
          _buildLevelDisplay(provider),
          _buildPauseButton(),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(GameViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('score').toUpperCase(),
          style: TextStyle(
            color: ColorHelper.instance.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          provider.score,
          style: TextStyle(
            color: ColorHelper.instance.scoreColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildLevelDisplay(GameViewModel provider) {
    return Column(
      children: [
        Text(
          'LEVEL ${provider.currentLevelIndex + 1}',
          style: TextStyle(
            color: ColorHelper.instance.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        LinearPercentIndicator(
          width: 100,
          lineHeight: 8,
          percent: provider.currentLevelProgressInPercentage,
          backgroundColor: ColorHelper.instance.secondary,
          progressColor: ColorHelper.instance.levelProgressColor,
          barRadius: const Radius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPauseButton() {
    return IconButton(
      onPressed: _pauseGame,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorHelper.instance.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.pause, color: ColorHelper.instance.primary, size: 24),
      ),
    );
  }

  void _onGameOver() async {
    // Save game progress and check for high score
    await gameViewModel.saveGameProgress();

    // Show appropriate dialog based on whether it's a new high score
    if (gameViewModel.hasNewHighScore) {
      _showNewHighScoreDialog();
    } else {
      _showGameOverDialog();
    }
  }

  void _onGameCompleted() {
    print(
      '_onGameCompleted called - currentGameMode: ${gameViewModel.currentGameMode}',
    );

    // In free mode, the game never completes - it's infinite
    if (gameViewModel.currentGameMode != GameMode.freeMode) {
      print('Showing victory dialog for level mode');
      _showVictoryDialog();
    } else {
      print('Free mode detected - NOT showing victory dialog');
    }
    // If it's free mode, do nothing - the game continues infinitely
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameOverDialog(),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildVictoryDialog(),
    );
  }

  Widget _buildGameOverDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorHelper.instance.gameOverColor.withOpacity(0.9),
              ColorHelper.instance.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorHelper.instance.gameOverColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: ColorHelper.instance.gameOverColor,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('you_lose'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${context.tr('score')}: ${gameViewModel.score}',
              style: TextStyle(
                color: ColorHelper.instance.scoreColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton(context.tr('restart'), Icons.refresh, () {
                  Navigator.of(context).pop();
                  gameViewModel.restartGame();
                }),
                _buildDialogButton(context.tr('main_menu'), Icons.home, () {
                  Navigator.of(context).pop();
                  navigateAndRemoveUntil(context, RoutePath.homeScreen);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewHighScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildNewHighScoreDialog(),
    );
  }

  Widget _buildNewHighScoreDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorHelper.instance.victoryColor.withOpacity(0.9),
              ColorHelper.instance.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorHelper.instance.victoryColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorHelper.instance.victoryColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated trophy icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseAnimation.value * 0.2),
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: ColorHelper.instance.victoryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 NEW HIGH SCORE! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              '${context.tr('score')}: ${gameViewModel.score}',
              style: TextStyle(
                color: ColorHelper.instance.scoreColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Previous Best: ${gameViewModel.getFormattedHighScore()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton('Play Again', Icons.refresh, () {
                  Navigator.of(context).pop();
                  gameViewModel.restartGame();
                }),
                _buildDialogButton('Menu', Icons.home, () {
                  Navigator.of(context).pop();
                  navigateAndRemoveUntil(context, RoutePath.homeScreen);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorHelper.instance.victoryColor.withOpacity(0.9),
              ColorHelper.instance.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorHelper.instance.victoryColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 60,
              color: ColorHelper.instance.victoryColor,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('you_won'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('level_complete'),
              style: TextStyle(
                color: ColorHelper.instance.victoryColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton(
                  context.tr('next_level'),
                  Icons.arrow_forward,
                  () {
                    Navigator.of(context).pop();
                    gameViewModel.nextLevel();
                  },
                ),
                _buildDialogButton(context.tr('main_menu'), Icons.home, () {
                  Navigator.of(context).pop();
                  navigateAndRemoveUntil(context, RoutePath.homeScreen);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  final int rows;
  final int columns;

  GridPainter({
    required this.cellSize,
    required this.rows,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Safety checks to prevent painting assertion errors
    if (!cellSize.isFinite || cellSize <= 0 || rows <= 0 || columns <= 0) {
      return; // Skip painting if dimensions are invalid
    }

    final paint = Paint()
      ..color = ColorHelper.instance.primary.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw vertical lines with bounds checking
    for (int i = 0; i <= columns; i++) {
      double x = i * cellSize;
      if (x.isFinite && x >= 0) {
        double endY = rows * cellSize;
        if (endY.isFinite && endY >= 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, endY), paint);
        }
      }
    }

    // Draw horizontal lines with bounds checking
    for (int i = 0; i <= rows; i++) {
      double y = i * cellSize;
      if (y.isFinite && y >= 0) {
        double endX = columns * cellSize;
        if (endX.isFinite && endX >= 0) {
          canvas.drawLine(Offset(0, y), Offset(endX, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! GridPainter ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.rows != rows ||
        oldDelegate.columns != columns;
  }
}
