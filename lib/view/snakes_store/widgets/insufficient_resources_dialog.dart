import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/game_colors.dart';
import '../../../model/snake_design.dart';

class InsufficientResourcesDialog extends StatelessWidget {
  final SnakeDesign snake;
  final int userCoins;
  final int userLevel;

  const InsufficientResourcesDialog({
    super.key,
    required this.snake,
    required this.userCoins,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    String message = _getMessage();

    return AlertDialog(
      backgroundColor: ColorHelper.instance.alertDialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.warning,
            color: ColorHelper.instance.appErrorColor,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Insufficient Resources',
            style: TextStyle(
              color: ColorHelper.instance.alertTextColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: ColorHelper.instance.alertTextColor.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            tr('ok'),
            style: TextStyle(
              color: ColorHelper.instance.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getMessage() {
    if (userCoins < snake.price && userLevel < snake.requiredLevel) {
      return '${tr('you_need')} ${snake.price - userCoins} ${tr('more_coins')} ${tr('and_level')} ${snake.requiredLevel} ${tr('to_purchase_this_snake')}';
    } else if (userCoins < snake.price) {
      return '${tr('you_need')} ${snake.price - userCoins} ${tr('more_coins')} ${tr('to_purchase_this_snake')}';
    } else {
      return '${tr('you_need')} ${tr('to_reach_level')} ${snake.requiredLevel} ${tr('to_purchase_this_snake')}';
    }
  }
}
