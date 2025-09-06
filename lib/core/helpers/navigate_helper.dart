import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/route_manager.dart';
import 'package:snake_game/view/game/free_mode_game_screen.dart';
import 'package:snake_game/view/game/open_game_levels.dart';
import 'package:snake_game/view/settings/language_settings.dart';
import 'package:snake_game/view/settings/privacy_policy/privacy_policy.dart';
import 'package:snake_game/view/snakes_store/snakes_store_screen.dart';
import '../../view/game/game_screen.dart';
import '../../view/home_screen/home_screen.dart';

class NavigatorHelper {
  static NavigatorHelper instance = NavigatorHelper._internal();
  NavigatorHelper._internal();

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RoutePath.gameScreen:
        int? index = (settings.arguments as Map?)?["index"];
        return MaterialPageRoute(
          builder: (_) => GameScreen(startLevelIndex: index),
        );
      case RoutePath.openGameLevels:
        return MaterialPageRoute(
          builder: (_) => OpenGameLevels(),
          settings: settings,
        );
      case RoutePath.languageScreen:
        return MaterialPageRoute(builder: (_) => const LanguageSettings());
      case RoutePath.privacyPolicyScreen:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case RoutePath.snakeGameScreen:
        return MaterialPageRoute(builder: (_) => const SnakesStoreScreen());
        case RoutePath.freeModeGameScreen:
  return MaterialPageRoute(builder: (context) => const FreeModeGameScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No route defined'))),
        );
    }
  }
}

navigateTo(BuildContext context, String path, {dynamic arguments}) {
  Navigator.pushNamed(context, path, arguments: arguments);
}

navigateBack(BuildContext context) {
  Navigator.of(context).pop();
}

navigateAndRemoveUntil(BuildContext context, String path, {dynamic arguments}) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    path,
    (route) => false,
    arguments: arguments,
  );
}
