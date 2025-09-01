import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/core/helpers/language_helper.dart';
import '../../core/constants/game_colors.dart';
import '../../core/helpers/navigate_helper.dart';

class LanguageSettings extends StatelessWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    LanguageHelper languageHelper = LanguageHelper.instance;
    ColorHelper colorHelper = ColorHelper.instance;
    bool isAr = languageHelper.isArabicLanguage(context);

    return Scaffold(
      backgroundColor: colorHelper.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorHelper.appBackgroundColor,
        leading: IconButton(
          onPressed: () {
            navigateBack(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: colorHelper.appIconColor,
          ),
        ),
        title: Text(
          "language".tr(),
          style: TextStyle(color: colorHelper.appTextColor),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 45),
            InkWell(
              onTap: isAr
                  ? () {}
                  : () {
                      languageHelper.changeLanguage("ar", context);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 60,
                  child: Card(
                    color: colorHelper.appButtonSecondColor,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "العربية",
                          style: TextStyle(
                            color: colorHelper.appOnButtonSecondColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Spacer(),
                        if (isAr)
                          Icon(
                            Icons.check_circle,
                            color: colorHelper.appOnButtonSecondColor,
                            size: 25,
                          ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: !isAr
                  ? () {}
                  : () {
                      languageHelper.changeLanguage("en", context);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 60,
                  child: Card(
                    color: colorHelper.appButtonSecondColor,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "english",
                          style: TextStyle(
                            color: colorHelper.appOnButtonSecondColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Spacer(),
                        if (!isAr)
                          Icon(
                            Icons.check_circle,
                            color: colorHelper.appOnButtonSecondColor,
                            size: 25,
                          ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
