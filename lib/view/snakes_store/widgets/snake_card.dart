import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/game_colors.dart';
import '../../../model/snake_design.dart';

class SnakeCard extends StatelessWidget {
  final SnakeDesign snake;
  final int index;
  final bool isOwned;
  final bool isSelected;
  final bool canBuy;
  final bool isLocked;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  const SnakeCard({
    super.key,
    required this.snake,
    required this.index,
    required this.isOwned,
    required this.isSelected,
    required this.canBuy,
    required this.isLocked,
    required this.glowAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: ColorHelper.instance.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? ColorHelper.instance.primary
                    : isLocked
                    ? ColorHelper.instance.appErrorColor.withOpacity(0.3)
                    : ColorHelper.instance.primary.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: ColorHelper.instance.primary.withOpacity(
                      glowAnimation.value * 0.5,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSnakePreview(),
                const SizedBox(height: 12),
                _buildSnakeName(),
                const SizedBox(height: 8),
                if (!snake.isDefault) _buildRequirements(),
                const SizedBox(height: 12),
                _buildActionButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnakePreview() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [snake.headColor, snake.bodyColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: snake.headColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Snake body segments
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: snake.headColor,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: snake.bodyColor,
              ),
            ),
          ),
          if (isLocked)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.7),
              ),
              child: Icon(
                Icons.lock,
                color: ColorHelper.instance.appErrorColor,
                size: 30,
              ),
            ),
          if (isSelected && isOwned)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorHelper.instance.primary.withOpacity(0.2),
              ),
              child: Icon(
                Icons.check_circle,
                color: ColorHelper.instance.primary,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSnakeName() {
    return Text(
      snake.name,
      style: TextStyle(
        color: ColorHelper.instance.onSecondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRequirements() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on,
              color: ColorHelper.instance.scoreColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${snake.price}',
              style: TextStyle(
                color: ColorHelper.instance.scoreColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: ColorHelper.instance.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${tr('level')} ${snake.requiredLevel}',
              style: TextStyle(
                color: ColorHelper.instance.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getButtonColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getButtonText(),
        style: TextStyle(
          color: ColorHelper.instance.onSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getButtonColor() {
    if (isSelected) return ColorHelper.instance.primary;
    if (isOwned) return ColorHelper.instance.appButtonColor;
    if (canBuy) return ColorHelper.instance.scoreColor;
    return ColorHelper.instance.appErrorColor;
  }

  String _getButtonText() {
    if (snake.isDefault) return tr('default');
    if (isSelected) return tr('selected');
    if (isOwned) return tr('select');
    if (canBuy) return tr('buy');
    return tr('locked');
  }
}
