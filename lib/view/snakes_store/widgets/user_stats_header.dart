import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/game_colors.dart';

class UserStatsHeader extends StatelessWidget {
  final int userCoins;
  final int userLevel;

  const UserStatsHeader({
    super.key,
    required this.userCoins,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorHelper.instance.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorHelper.instance.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorHelper.instance.primary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.monetization_on,
            context.tr('coins'),
            userCoins.toString(),
            ColorHelper.instance.scoreColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: ColorHelper.instance.primary.withOpacity(0.3),
          ),
          _buildStatItem(
            Icons.trending_up,
            context.tr('level'),
            userLevel.toString(),
            ColorHelper.instance.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: ColorHelper.instance.onSecondary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
