import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import 'package:snake_game/core/constants/route_manager.dart';
import 'package:snake_game/core/helpers/navigate_helper.dart';
import 'package:snake_game/core/helpers/language_helper.dart';
import 'package:snake_game/view_model/game/free_mode_game_view_model.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ColorHelper colorHelper = ColorHelper.instance;
  String gScore = "000000";
  bool screenLoading = true;

  late AnimationController _logoAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.linear,
      ),
    );

    getCurrentScore();

    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonAnimationController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh score when screen becomes visible (user returns from game)
    if (!screenLoading) {
      getCurrentScore();
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _buttonAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  getCurrentScore() async {
    try {
      // Load maximum score from Free Mode levels
      final maxFreeModeScore =
          await FreeModeGameViewModel.getMaxFreeModeScore();
      gScore = maxFreeModeScore.toString().padLeft(6, '0');

      setState(() {
        screenLoading = false;
      });
    } catch (e) {
      print("Error getting Free Mode max score: $e");
      setState(() {
        screenLoading = false;
        gScore = "000000";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorHelper.gameBackgroundColor,
                  colorHelper.appSecondBackgroundColor,
                  colorHelper.secondary,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background elements
                _buildAnimatedBackground(),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Top section with logo and title
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildLogo()],
                        ),
                      ),

                      // Middle section with score and buttons
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Score display
                            _buildScoreDisplay(),

                            // Game buttons
                            _buildGameButtons(),
                          ],
                        ),
                      ),

                      // Bottom section with settings
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBottomActions(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: AnimatedBackgroundPainter(_backgroundAnimation.value),
      size: Size.infinite,
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      colorHelper.snakeHeadColor,
                      colorHelper.snakeBodyColor,
                      colorHelper.snakeBodyGradientEnd,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorHelper.snakeHeadColor.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/snakesAr.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Game Title
              Text(
                context.tr('snake_game'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorHelper.primary,
                  shadows: [
                    Shadow(
                      color: colorHelper.primary.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorHelper.secondary.withOpacity(0.8),
            colorHelper.secondary.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colorHelper.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorHelper.primary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: colorHelper.scoreColor, size: 24),
          const SizedBox(width: 12),
          Text(
            context.tr('max_free_mode_score'),
            style: TextStyle(
              color: colorHelper.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            gScore,
            style: TextStyle(
              color: colorHelper.scoreColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonAnimation.value,
          child: Column(
            children: [
              // Level Mode button
              _buildMainButton(
                title: context.tr('level_mode').toUpperCase(),
                subtitle: context.tr('progressive_level_unlocking'),
                icon: Icons.trending_up,
                gradient: LinearGradient(
                  colors: [
                    colorHelper.snakeHeadColor,
                    colorHelper.snakeBodyColor,
                  ],
                ),
                onTap: () {
                  // Navigate to level selection for Level Mode
                  navigateTo(
                    context,
                    RoutePath.openGameLevels,
                    arguments: {'gameMode': 'level'},
                  );
                },
              ),

              const SizedBox(height: 20),

              // Free Mode button
              _buildMainButton(
                title: context.tr('free_mode').toUpperCase(),
                subtitle: context.tr('choose_level_play_infinitely'),
                icon: Icons.all_inclusive,
                gradient: LinearGradient(
                  colors: [colorHelper.primary, colorHelper.levelProgressColor],
                ),
                onTap: () {
                  // Navigate to level selection for Free Mode
                  navigateTo(
                    context,
                    RoutePath.openGameLevels,
                    arguments: {'gameMode': 'free'},
                  );
                },
              ),

              // SNakes Store button
              _buildMainButton(
                title: context.tr('snakes_store').toUpperCase(),
                subtitle: context.tr('buy_snakes_and_customize'),
                icon: Icons.store,
                gradient: LinearGradient(
                  colors: [colorHelper.primary, colorHelper.levelProgressColor],
                ),
                onTap: () {
                  navigateTo(context, RoutePath.snakeGameScreen);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        width: 280,
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLanguageToggle(),
        _buildActionButton(
          icon: Icons.info_outline,
          label: context.tr('about'),
          onTap: () => navigateTo(context, RoutePath.privacyPolicyScreen),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    bool isArabic = LanguageHelper.instance.isArabicLanguage(context);
    return GestureDetector(
      onTap: () {
        String newLang = isArabic ? 'en' : 'ar';
        LanguageHelper.instance.changeLanguage(newLang, context);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorHelper.secondary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorHelper.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: colorHelper.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              isArabic ? 'EN' : 'عر',
              style: TextStyle(
                color: colorHelper.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colorHelper.secondary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorHelper.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorHelper.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colorHelper.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw animated circles
    for (int i = 0; i < 8; i++) {
      final progress = (animationValue + i * 0.125) % 1.0;
      final x = (i % 4) * (size.width / 3) + (size.width / 6);
      final y = (i ~/ 4) * (size.height / 2) + (size.height / 4);
      final radius = 50 * progress;
      final opacity = (1.0 - progress) * 0.1;

      paint.color = ColorHelper.instance.primary.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw moving lines
    paint.strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final startY = size.height * progress;
      final opacity = (1.0 - (progress - 0.5).abs() * 2) * 0.15;

      paint.color = ColorHelper.instance.snakeHeadColor.withOpacity(opacity);
      canvas.drawLine(Offset(0, startY), Offset(size.width, startY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
