import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageHelper {
  static LanguageHelper instance = LanguageHelper._();
  LanguageHelper._();

  isArabicLanguage(BuildContext context) {
    return context.locale.languageCode == "ar";
  }

  Future<Locale> getSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString(AppStrings.selectedLanguageKey) ?? 'en';
    return Locale(langCode);
  }

  void changeLanguage(String langCode, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.selectedLanguageKey, langCode);
    Locale newLocale = Locale(langCode);
    context.setLocale(newLocale);
  }
}
