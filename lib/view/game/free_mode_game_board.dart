import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import 'package:snake_game/core/helpers/game_helper.dart';
import 'package:snake_game/model/model/game_padding.dart';
import 'package:snake_game/view_model/game/free_mode_game_view_model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

class FreeModeGameBoard extends StatefulWidget {
  const FreeModeGameBoard({
    super.key,
    required this.height,
    required this.width,
    this.startIndex,
  });
  final double height;
  final double width;
  final int? startIndex;

  @override
  State<FreeModeGameBoard> createState() => _FreeModeGameBoardState();
}

class _FreeModeGameBoardState extends State<FreeModeGameBoard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late FreeModeGameViewModel gameViewModel;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _scoreController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

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

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    double availableWidth = widget.width - 40;
    double availableHeight = widget.height - 80;

    double cellWidth = availableWidth / 20;
    double cellHeight = availableHeight / 20;
    double cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight)
        .floorToDouble();

    if (cellSize < 15.0) cellSize = 15.0;
    if (cellSize > 30.0) cellSize = 30.0;

    double gridWidth = cellSize * 20;
    double gridHeight = cellSize * 20;

    double leftPadding = (widget.width - gridWidth) / 2;

    GamePadding gamePaddings = GamePadding(
      left: leftPadding,
      right: leftPadding,
      top: 100.0,
      height: gridHeight,
      width: widget.width,
    );

    gameViewModel = Provider.of<FreeModeGameViewModel>(context, listen: false);
    gameViewModel.bigScoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
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
    _particleController.dispose();
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

  Widget _buildAchievementButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.05,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.amber.shade800),
              label: Text(
                text,
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                elevation: 8,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    gameViewModel.onGameOver = _onGameOver;

    return Consumer<FreeModeGameViewModel>(
      builder: (context, provider, _) {
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
              children: [
                _buildGameArea(provider),
                _buildUI(provider),
                if (provider.showParticles) _buildParticleEffect(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(FreeModeGameViewModel provider) {
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

  Widget _buildGrid(FreeModeGameViewModel provider) {
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

  Widget _buildBarriers(FreeModeGameViewModel provider) {
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

  Widget _buildFood(FreeModeGameViewModel provider) {
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

  Widget _buildSnake(FreeModeGameViewModel provider) {
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
    FreeModeGameViewModel provider,
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

  Widget _buildSnakeHead(FreeModeGameViewModel provider) {
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

  Widget _buildSnakeTail(FreeModeGameViewModel provider) {
    double rotation = _getTailRotation(provider);

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: provider.cellSize,
        height: provider.cellSize,
        child: Image.asset(
          'assets/images/LorenzosNewSnakeAssets/tail/256px/tail_final00.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSnakeBody(
    FreeModeGameViewModel provider,
    int index,
    Offset segment,
  ) {
    // Check if this segment is a corner (direction change)
    String segmentType = _getSegmentType(provider, index, segment);
    String imagePath = _getBodyImagePath(segmentType, index, provider, segment);
    double rotation = _getBodyRotation(segmentType, provider, index, segment);

    // Adjust size and position based on segment type
    double segmentWidth = provider.cellSize;
    double segmentHeight = provider.cellSize;
    double offsetX = 0;
    double offsetY = 0;

    // No offsets; keep full scale for all segments
    // segmentWidth and segmentHeight remain equal to cellSize

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.rotate(
        angle: rotation,
        child: SizedBox(
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

  double _getTailRotation(FreeModeGameViewModel provider) {
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

  String _getSegmentType(
    FreeModeGameViewModel provider,
    int index,
    Offset segment,
  ) {
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
    FreeModeGameViewModel provider,
    Offset segment,
  ) {
    // Straight segments keep alternating images for wavy effect
    if (segmentType == 'horizontal') {
      return (provider.movementCounter + index) % 2 == 0
          ? 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal00.png'
          : 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal01.png';
    }
    if (segmentType == 'vertical') {
      return (provider.movementCounter + index) % 2 == 0
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

    // Fallback for straight segments
    return 'assets/images/LorenzosNewSnakeAssets/body/256px/snake_body256_horizontal00.png';
  }

  double _getBodyRotation(
    String segmentType,
    FreeModeGameViewModel provider,
    int index,
    Offset segment,
  ) {
    // Corner images are orientation-specific now; no rotation needed
    if (segmentType == 'left_corner' || segmentType == 'right_corner') {
      return 0;
    }
    return 0; // No rotation for straight segments
  }

  Widget _buildBigScoreCell(FreeModeGameViewModel provider) {
    return AnimatedBuilder(
      animation: provider.bigScoreAnimationController!,
      builder: (context, child) {
        double progress = provider.bigScoreAnimationController!.value;
        double scale = 1.0 + math.sin(progress * math.pi) * 0.5;
        return Positioned(
          left: provider.bigScoreCell.dx * provider.cellSize,
          top: provider.bigScoreCell.dy * provider.cellSize,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: provider.cellSize,
              height: provider.cellSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ColorHelper.instance.bigScoreGradient,
                boxShadow: [
                  BoxShadow(
                    color: ColorHelper.instance.bigScoreGlowColor.withOpacity(
                      0.8,
                    ),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUI(FreeModeGameViewModel provider) {
    return Positioned.fill(child: Column(children: [_buildScoreBar(provider)]));
  }

  Widget _buildScoreBar(FreeModeGameViewModel provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildScoreDisplay(context.tr('score'), provider.score),
          const SizedBox(width: 24),
          _buildScoreDisplay(
            context.tr('best_score'),
            provider.getFormattedHighScore(),
          ),
          const Spacer(), // Pushes the pause button to the right
          GestureDetector(
            onTap: () {
              if (provider.isPlaying && !provider.isPaused) {
                _pauseGame();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorHelper.instance.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorHelper.instance.primary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.pause,
                color: ColorHelper.instance.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: ParticlePainter(_particleController)),
      ),
    );
  }

  void _onGameOver() {
    if (gameViewModel.hasNewHighScore) {
      // Show animated new achievement dialog for new high score
      _showNewAchievementDialog();
    } else {
      // Show regular game over dialog for lower scores
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGameOverDialog(),
      );
    }
  }

  void _showNewAchievementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildNewAchievementDialog(),
    );
  }

  Widget _buildNewAchievementDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: CustomPaint(
              painter: AchievementParticlePainter(_particleController),
            ),
          ),
          // Main achievement dialog
          AnimatedBuilder(
            animation: _scoreController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_scoreController.value * 0.2),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.amber.shade100, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon with glow effect
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.3,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.yellow.shade200,
                                    Colors.amber.shade400,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.8),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                size: 60,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Achievement title with shimmer effect
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.amber.shade100,
                                  Colors.white,
                                ],
                                stops: [0.0, _glowAnimation.value, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              '🎉 NEW ACHIEVEMENT! 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      Text(
                        context.tr('new_high_score'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Score display with glow
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${context.tr('score')}:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      1.0 + (_pulseAnimation.value - 1.0) * 0.1,
                                  child: Text(
                                    gameViewModel.score,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.amber.withOpacity(0.8),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Action buttons with glow effects
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAchievementButton(
                            context.tr('try_again'),
                            Icons.refresh,
                            () {
                              Navigator.of(context).pop();
                              gameViewModel.restartGame();
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildAchievementButton(
                            context.tr('exit'),
                            Icons.exit_to_app,
                            () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop(); // Exit game screen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade800, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade400, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('you_lose'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${context.tr('score')}: ${gameViewModel.score}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton(context.tr('try_again'), Icons.refresh, () {
                  Navigator.of(context).pop();
                  gameViewModel.restartGame();
                }),
                _buildDialogButton(context.tr('exit'), Icons.exit_to_app, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Exit game screen
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
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(columns * cellSize, i * cellSize),
        paint,
      );
    }

    for (int i = 0; i <= columns; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, rows * cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles = [];
  final math.Random random = math.Random();

  ParticlePainter(this.animation) : super(repaint: animation) {
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(random));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorHelper.instance.primary.withOpacity(0.6);

    for (var particle in particles) {
      particle.update(animation.value, size);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  late Offset position;
  late double size;
  late Offset velocity;
  final math.Random random;

  Particle(this.random) {
    position = Offset(random.nextDouble(), random.nextDouble());
    velocity = Offset(
      (random.nextDouble() - 0.5) * 0.02,
      (random.nextDouble() - 0.5) * 0.02,
    );
    size = random.nextDouble() * 4 + 1;
  }

  void update(double progress, Size area) {
    position += velocity;
    if (position.dx < 0 || position.dx > area.width)
      velocity = Offset(-velocity.dx, velocity.dy);
    if (position.dy < 0 || position.dy > area.height)
      velocity = Offset(velocity.dx, -velocity.dy);
  }
}

class AchievementParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<AchievementParticle> particles = [];
  final math.Random random = math.Random();

  AchievementParticlePainter(this.animation) : super(repaint: animation) {
    // Create golden celebration particles
    for (int i = 0; i < 80; i++) {
      particles.add(AchievementParticle(random));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(animation.value, size);

      // Create gradient paint for each particle
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                particle.color.withOpacity(0.8),
                particle.color.withOpacity(0.3),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: particle.position, radius: particle.size),
            );

      canvas.drawCircle(particle.position, particle.size, paint);

      // Add sparkle effect
      if (particle.isSparkle) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 1;

        canvas.drawLine(
          particle.position + Offset(-particle.size * 0.7, 0),
          particle.position + Offset(particle.size * 0.7, 0),
          sparklePaint,
        );
        canvas.drawLine(
          particle.position + Offset(0, -particle.size * 0.7),
          particle.position + Offset(0, particle.size * 0.7),
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AchievementParticle {
  late Offset position;
  late double size;
  late Offset velocity;
  late Color color;
  late bool isSparkle;
  late double life;
  late double maxLife;
  final math.Random random;

  AchievementParticle(this.random) {
    // Start particles from random positions
    position = Offset(random.nextDouble() * 400, random.nextDouble() * 600);

    // Random velocity for floating effect
    velocity = Offset(
      (random.nextDouble() - 0.5) * 2,
      -random.nextDouble() * 3 - 1, // Generally upward movement
    );

    size = random.nextDouble() * 6 + 2;
    maxLife = random.nextDouble() * 3 + 2;
    life = maxLife;

    // Golden celebration colors
    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.yellow,
      Colors.deepOrange,
      const Color(0xFFFFD700), // Gold color
    ];
    color = colors[random.nextInt(colors.length)];

    // Some particles are sparkles
    isSparkle = random.nextBool() && random.nextDouble() > 0.7;
  }

  void update(double progress, Size area) {
    // Update position
    position += velocity;

    // Apply gravity and air resistance
    velocity = Offset(velocity.dx * 0.99, velocity.dy + 0.1);

    // Decrease life
    life -= 0.02;

    // Reset particle when it dies or goes off screen
    if (life <= 0 || position.dy > area.height + 50) {
      position = Offset(random.nextDouble() * area.width, -50);
      velocity = Offset(
        (random.nextDouble() - 0.5) * 2,
        -random.nextDouble() * 3 - 1,
      );
      life = maxLife;
    }

    // Keep particles within horizontal bounds
    if (position.dx < -50) {
      position = Offset(area.width + 50, position.dy);
    } else if (position.dx > area.width + 50) {
      position = Offset(-50, position.dy);
    }
  }
}

// Enhanced Particle Effects for Free Mode (Food Eating Effects)
class FreeModeParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final List<FreeModeParticle> particles = [];
  final math.Random random = math.Random();
  final double cellSize;
  final int rows;
  final int columns;

  FreeModeParticleEffectPainter(
    this.animation, {
    required this.cellSize,
    required this.rows,
    required this.columns,
  }) : super(repaint: animation) {
    // Create food eating particles
    for (int i = 0; i < 25; i++) {
      particles.add(FreeModeParticle(random, cellSize, rows, columns));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridWidth = columns * cellSize;
    final gridHeight = rows * cellSize;

    for (var particle in particles) {
      particle.update(animation.value, Size(gridWidth, gridHeight));

      // Create gradient paint for each particle
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                particle.color.withOpacity(particle.opacity * 0.9),
                particle.color.withOpacity(particle.opacity * 0.5),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: particle.position, radius: particle.size),
            );

      canvas.drawCircle(particle.position, particle.size, paint);

      // Add sparkle effect for some particles
      if (particle.isSparkle && particle.opacity > 0.4) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(particle.opacity * 0.8)
          ..strokeWidth = 1.5;

        canvas.drawLine(
          particle.position + Offset(-particle.size * 0.6, 0),
          particle.position + Offset(particle.size * 0.6, 0),
          sparklePaint,
        );
        canvas.drawLine(
          particle.position + Offset(0, -particle.size * 0.6),
          particle.position + Offset(0, particle.size * 0.6),
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FreeModeParticle {
  late Offset position;
  late double size;
  late Offset velocity;
  late Color color;
  late bool isSparkle;
  late double life;
  late double maxLife;
  late double opacity;
  final math.Random random;
  final double cellSize;
  final int rows;
  final int columns;

  FreeModeParticle(this.random, this.cellSize, this.rows, this.columns) {
    _reset();
  }

  void _reset() {
    // Start particles from random positions within the grid
    position = Offset(
      random.nextDouble() * (columns * cellSize),
      random.nextDouble() * (rows * cellSize),
    );

    // Random velocity for dynamic movement
    velocity = Offset(
      (random.nextDouble() - 0.5) * 2.5,
      -random.nextDouble() * 3.5 - 0.5, // Generally upward movement
    );

    size = random.nextDouble() * 3.5 + 1.5;
    maxLife = random.nextDouble() * 1.8 + 0.8;
    life = maxLife;
    opacity = 1.0;

    // Free mode vibrant colors
    final colors = [
      ColorHelper.instance.primary,
      ColorHelper.instance.foodColor,
      ColorHelper.instance.snakeHeadColor,
      Colors.cyan,
      Colors.yellow,
      Colors.orange,
    ];
    color = colors[random.nextInt(colors.length)];

    // Some particles are sparkles
    isSparkle = random.nextBool() && random.nextDouble() > 0.7;
  }

  void update(double progress, Size area) {
    // Update position
    position += velocity;

    // Apply physics
    velocity = Offset(
      velocity.dx * 0.97, // Air resistance
      velocity.dy + 0.12, // Gravity
    );

    // Decrease life and update opacity
    life -= 0.025;
    opacity = (life / maxLife).clamp(0.0, 1.0);

    // Reset particle when it dies or goes off screen
    if (life <= 0 ||
        position.dy > area.height + 15 ||
        position.dx < -15 ||
        position.dx > area.width + 15) {
      _reset();
    }
  }
}
