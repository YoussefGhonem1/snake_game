import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_game/core/constants/route_manager.dart';
import 'package:snake_game/core/helpers/game_helper.dart';
import 'package:snake_game/core/helpers/language_helper.dart';
import 'package:snake_game/view_model/game/game_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'core/helpers/navigate_helper.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
     await prefs.clear();
    EasyLocalization.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // await MobileAds.instance.initialize(); // Initialize AdMob
    // await UnityAdsHelper.initUnityAds();

    await GameHelper.instance.initGameHelper();
    Locale savedLocale = await LanguageHelper.instance.getSavedLocale();

    await requestNotificationPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!Platform.isIOS) {
      try {
        await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print("Firebase messaging error: $e");
      }
    }

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: savedLocale,
        child: const GameApp(),
      ),
    );
  } catch (e, stackTrace) {
    print("App initialization error: $e");
    print("Stack trace: $stackTrace");
    // Run app with error handling
    runApp(
      MaterialApp(
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

Future<void> requestNotificationPermission() async {
  final messaging = FirebaseMessaging.instance;

  if (Platform.isIOS) {
    await _requestIOSPermission(messaging);
  } else if (Platform.isAndroid) {
    await _requestAndroidPermission();
  }
}

Future<void> _requestIOSPermission(FirebaseMessaging messaging) async {
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  switch (settings.authorizationStatus) {
    case AuthorizationStatus.authorized:
      break;
    case AuthorizationStatus.provisional:
      break;
    default:
      print('Permission denied');
  }
}

Future<void> _requestAndroidPermission() async {
  if (await Permission.notification.request().isGranted) {
    print('Permission granted');
  } else {
    print('Permission denied');
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
        initialRoute: RoutePath.homeScreen,
        onGenerateRoute: NavigatorHelper.instance.generateRoute,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Snake Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
