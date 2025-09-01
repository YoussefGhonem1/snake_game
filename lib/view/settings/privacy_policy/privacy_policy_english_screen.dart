import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';

class PrivacyPolicyEnglishScreen extends StatelessWidget {
  const PrivacyPolicyEnglishScreen({super.key});

  ColorHelper get colorHelper => ColorHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            color: colorHelper.appTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorHelper.appBackgroundColor,
        iconTheme: IconThemeData(color: colorHelper.appIconColor),
      ),
      backgroundColor: colorHelper.appBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHelper.primary,
                ),
              ),
              Text(
                "Issue Date: July 4, 2025",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorHelper.appTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome to Snakes Game! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your data while playing the game.",
                style: TextStyle(fontSize: 16, color: colorHelper.appTextColor),
              ),
              const SizedBox(height: 20),
              _sectionTitle("1. Information We Collect"),
              _sectionContent(
                "• Personal Information: Your name, email, and password to create and manage your account.\n"
                "• Game Data: Scores and progress to track achievements and unlock levels.\n"
                "• Advertisement Data: From Unity Ads.",
              ),
              _sectionTitle("2. How We Use Your Information"),
              _sectionContent(
                "• Game Functions: Registration, login, personalization.\n"
                "• Progress Tracking: Save/restore progress and scores across devices.\n"
                "• Ads : Personalised ads.\n"
                "• Account Management: Edit or delete your account.",
              ),
              _sectionTitle("3. Data Storage and Security"),
              _sectionContent(
                "We use Firebase to securely store your data and restore progress on any device.",
              ),
              _sectionTitle("4. Third-Party Services"),
              _sectionContent(
                "• Firebase (for account and score storage).\n"
                "• Unity Ads (for ads).",
              ),
              _sectionTitle("5. User Rights"),
              _sectionContent(
                "• You can edit your name in Settings > Profile.\n"
                "• You can delete your account and all data by navigating to:\n"
                "  Home > Settings > Profile > Delete Account.\n"
                "• You may also email us for assistance.",
              ),
              _sectionTitle("6. Children's Privacy"),
              _sectionContent(
                "Our game is for children, teens, and adults. If a child submitted data without consent, contact us.",
              ),
              _sectionTitle("7. Privacy Policy Updates"),
              _sectionContent(
                "We may update this policy. You’ll be notified in-game.",
              ),
              _sectionTitle("8. Contact Us"),
              _sectionContent("Email: f1ale1h@gmail.com"),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorHelper.primary,
        ),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, color: colorHelper.appTextColor),
      ),
    );
  }
}
