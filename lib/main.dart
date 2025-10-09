import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/route_manager.dart';
import 'package:snake_game/core/helpers/game_helper.dart';
import 'package:snake_game/core/helpers/language_helper.dart';
import 'package:snake_game/view_model/game/game_view_model.dart';
import 'package:provider/provider.dart';
import 'core/helpers/navigate_helper.dart';
import 'core/helpers/unity_ads_helper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    EasyLocalization.ensureInitialized();

    await UnityAdsHelper.initUnityAds();
    await GameHelper.instance.initGameHelper();
    Locale savedLocale = await LanguageHelper.instance.getSavedLocale();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: savedLocale,
        child: const GameApp(),
      ),
    );
  } catch (e) {
    // App initialization error - handled gracefully
    // Run app with error handling
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App initialization failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameViewModel())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RoutePath.splashScreen,
        onGenerateRoute: NavigatorHelper.instance.generateRoute,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Snakes Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
