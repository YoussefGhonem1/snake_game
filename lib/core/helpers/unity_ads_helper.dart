// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// class UnityAdsHelper{

//   static String androidAppId = '5892988';
//   static String iosAppId = '5892989';

//   static String bannerAndroidId = 'Banner_Android';
//   static String interstitialAndroidId = 'Interstitial_Android';

//   static String bannerIOSId = 'Banner_iOS';
//   static String interstitialIOSId = 'Interstitial_iOS';

//   static String testBannerId = 'ca-app-pub-3940256099942544/2934735716';
//   static String testInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

//   static String get bannerId => UnityAdsHelper.getBannerId();
//   static String get interstitialId => UnityAdsHelper.getInterstitialId();

//   static getBannerId(){

//     if(Platform.isIOS){
//       return bannerIOSId;
//     }else{
//       return bannerAndroidId;
//     }

//   }

//   static getInterstitialId(){
//     if(Platform.isIOS){
//       return interstitialIOSId;
//     }else{
//       return interstitialAndroidId;
//     }

//   }

//   static get gameId => Platform.isIOS ? iosAppId : androidAppId;

//   static Future<void> initUnityAds()async{
//     await UnityAds.init(gameId:gameId,testMode: kDebugMode,onComplete: (){
//       print("Unity ads initialized");
//     });
//   }

//   static bool _isAdLoading = false;
//   static DateTime? _lastAdShown;
//   static const int _minAdIntervalSeconds = 30; // Minimum 30 seconds between ads

//   static Future<void> showInterstitialAd() async {
//     try {
//       // Check if ad was shown recently
//       if (_lastAdShown != null) {
//         final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
//         if (timeSinceLastAd.inSeconds < _minAdIntervalSeconds) {
//           print('Unity Ads: Ad shown too recently, waiting ${_minAdIntervalSeconds - timeSinceLastAd.inSeconds} more seconds');
//           return;
//         }
//       }

//       // Check if already loading an ad
//       if (_isAdLoading) {
//         print('Unity Ads: Ad is already loading, please wait');
//         return;
//       }

//       // Try to show ad directly, load if it fails
//       await _showLoadedAd();
//     } catch (e) {
//       print('Unity Ads: Error in showInterstitialAd: $e');
//       _isAdLoading = false;
//     }
//   }

//   static Future<void> _loadInterstitialAd() async {
//     if (_isAdLoading) return;
    
//     _isAdLoading = true;
//     try {
//       await UnityAds.load(
//         placementId: interstitialId,
//         onComplete: (placementId) {
//           print('Unity Ads: Interstitial ad loaded: $placementId');
//           _isAdLoading = false;
//           // Auto-show the ad after loading
//           _showLoadedAd();
//         },
//         onFailed: (placementId, error, message) {
//           print('Unity Ads: Failed to load interstitial ad: $placementId - $error: $message');
//           _isAdLoading = false;
//         },
//       );
//     } catch (e) {
//       print('Unity Ads: Error loading interstitial ad: $e');
//       _isAdLoading = false;
//     }
//   }

//   static Future<void> _showLoadedAd() async {
//     try {
//       UnityAds.showVideoAd(
//         placementId: interstitialId,
//         onComplete: (placementId) {
//           print('Unity Ads: Interstitial ad completed: $placementId');
//           _lastAdShown = DateTime.now();
//         },
//         onFailed: (placementId, error, message) {
//           print('Unity Ads: Interstitial ad failed: $placementId - $error: $message');
//           // If showing fails, try to load a new ad for next time
//           if (message.contains('not ready') || message.contains('Placement not ready')) {
//             print('Unity Ads: Loading new ad for next time');
//             _loadInterstitialAd();
//           }
//         },
//         onStart: (placementId) {
//           print('Unity Ads: Interstitial ad started: $placementId');
//         },
//         onClick: (placementId) {
//           print('Unity Ads: Interstitial ad clicked: $placementId');
//         },
//         onSkipped: (placementId) {
//           print('Unity Ads: Interstitial ad skipped: $placementId');
//           _lastAdShown = DateTime.now();
//         },
//       );
//     } catch (e) {
//       print('Unity Ads: Error showing loaded ad: $e');
//       // Try to load a new ad if showing fails
//       _loadInterstitialAd();
//     }
//   }

// }