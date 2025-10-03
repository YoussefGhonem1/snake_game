// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io' show Platform;

// class AdMobHelper {
//   static InterstitialAd? _interstitialAd;
//   static bool isAdReady = false;

//   static String get interstitialAdUnitId {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/1033173712'; 
//     } else if (Platform.isIOS) {
//       return 'ca-app-pub-3940256099942544/4411468915'; 
//     }
//     throw UnsupportedError('Unsupported platform');
//   }

//   static void loadInterstitialAd() {
//     print("[AdMob] 1. Attempting to load interstitial ad...");
//     isAdReady = false; 

//     InterstitialAd.load(
//       adUnitId: interstitialAdUnitId,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           print("[AdMob] 2. SUCCESS: Ad loaded successfully!");
//           _interstitialAd = ad;
//           isAdReady = true;
//         },
//         onAdFailedToLoad: (error) {
//           print("[AdMob] 2. FAILED: Ad failed to load. Error: $error"); 
//           isAdReady = false;
//         },
//       ),
//     );
//   }

//   static void showInterstitialAd() {
//     if (isAdReady && _interstitialAd != null) {
//       print("[AdMob] 3. Showing ad now."); 
//       _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (ad) {
//           ad.dispose();
//           loadInterstitialAd();
//         },
//         onAdFailedToShowFullScreenContent: (ad, error) {
//           ad.dispose();
//           loadInterstitialAd();
//         },
//       );
//       _interstitialAd!.show();
//       isAdReady = false;
//     }
//   }
// }