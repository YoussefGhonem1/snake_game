import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import 'package:snake_game/core/helpers/navigate_helper.dart';
import '../../core/constants/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  ColorHelper colorHelper = ColorHelper.instance;
  late final AnimationController _lottieController;
  late final AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            navigateAndRemoveUntil(context, RoutePath.homeScreen);
          }
        });
      }
    });

    _lottieController.addListener(() {
      if (_lottieController.value > 0.7) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorHelper.appSecondBackgroundColor,
      body: Center(
        child: Stack(
          children: [
            Lottie.asset(
              'assets/lottie/snakesLottieSplash.json', // Ensure this path is correct
              controller: _lottieController,
              width: 400,
              height: 400,
              fit: BoxFit.contain,
              onWarning: (val) {
                print(val);
              },
              onLoaded: (composition) {
                _lottieController
                  ..duration = composition.duration
                  ..forward();
              },
            ),

            Positioned(
              left: width * 0.335,
              top: height * 0.10,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اللوجو
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      "Snake Game",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
