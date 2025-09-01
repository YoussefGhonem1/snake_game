import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/game_colors.dart';

class PurchaseSuccessDialog extends StatelessWidget {
  final String snakeName;

  const PurchaseSuccessDialog({
    super.key,
    required this.snakeName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorHelper.instance.alertDialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: ColorHelper.instance.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            tr('purchase_successful'),
            style: TextStyle(
              color: ColorHelper.instance.alertTextColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        '${tr('you_have_successfully_purchased_and_equipped')} $snakeName!',
        style: TextStyle(
          color: ColorHelper.instance.alertTextColor.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            tr('awesome'),
            style: TextStyle(
              color: ColorHelper.instance.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
