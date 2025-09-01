import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snake_game/view/settings/privacy_policy/privacy_policy_arabic_screen.dart';
import 'package:snake_game/view/settings/privacy_policy/privacy_policy_english_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return context.locale.languageCode == "ar"
        ? const PrivacyPolicyArabicScreen()
        : const PrivacyPolicyEnglishScreen();
  }
}
