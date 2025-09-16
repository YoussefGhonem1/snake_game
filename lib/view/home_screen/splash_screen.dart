import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import '../../core/helpers/navigate_helper.dart';
import '../../core/constants/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  ColorHelper colorHelper = ColorHelper.instance;
  late final AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // مدة أطول للحركة الطبيعية
    );

    // Scale من 0.1 (صغيرة جدًا) لـ 1 (الحجم النهائي)
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            navigateAndRemoveUntil(context, RoutePath.homeScreen);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorHelper.appSecondBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: 600,
                height: 600,
                child: Image.asset("assets/images/splash-logo.png"),
              ),
            );
          },
        ),
      ),
    );
  }
}
