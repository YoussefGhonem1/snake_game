import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsHelper {
  static String androidAppId = '5892988';
  static String iosAppId = '5892989';

  static String bannerAndroidId = 'Banner_Android';
  static String interstitialAndroidId = 'Interstitial_Android';

  static String bannerIOSId = 'Banner_iOS';
  static String interstitialIOSId = 'Interstitial_iOS';

  static String testBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static String testInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static String get bannerId => UnityAdsHelper.getBannerId();
  static String get interstitialId => UnityAdsHelper.getInterstitialId();

  static getBannerId() {
    if (Platform.isIOS) {
      return bannerIOSId;
    } else {
      return bannerAndroidId;
    }
  }

  static getInterstitialId() {
    if (Platform.isIOS) {
      return interstitialIOSId;
    } else {
      return interstitialAndroidId;
    }
  }

  static get gameId => Platform.isIOS ? iosAppId : androidAppId;

  static Future<void> initUnityAds() async {
    await UnityAds.init(
      gameId: gameId,
      testMode: kDebugMode,
      onComplete: () {
        print("Unity ads initialized");
        // Preload an ad after initialization
        _preloadAd();
      },
    );
  }

  static Future<void> _preloadAd() async {
    if (!_isAdLoading && !_isAdLoaded) {
      print('Unity Ads: Preloading interstitial ad');
      await _loadInterstitialAd(autoShow: false);
    }
  }

  static bool _isAdLoading = false;
  static bool _isAdLoaded = false;
  static DateTime? _lastAdShown;
  static const int _minAdIntervalSeconds = 30; // Minimum 30 seconds between ads

  static Future<void> showInterstitialAd() async {
    try {
      // Check if ad was shown recently
      if (_lastAdShown != null) {
        final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
        if (timeSinceLastAd.inSeconds < _minAdIntervalSeconds) {
          print(
            'Unity Ads: Ad shown too recently, waiting ${_minAdIntervalSeconds - timeSinceLastAd.inSeconds} more seconds',
          );
          return;
        }
      }

      // Check if already loading an ad
      if (_isAdLoading) {
        print('Unity Ads: Ad is already loading, please wait');
        return;
      }

      // If ad is already loaded, show it
      if (_isAdLoaded) {
        await _showLoadedAd();
      } else {
        // Load ad first, then show it
        await _loadInterstitialAd();
      }
    } catch (e) {
      print('Unity Ads: Error in showInterstitialAd: $e');
      _isAdLoading = false;
    }
  }

  static Future<void> _loadInterstitialAd({bool autoShow = true}) async {
    if (_isAdLoading) return;

    _isAdLoading = true;
    _isAdLoaded = false;
    try {
      await UnityAds.load(
        placementId: interstitialId,
        onComplete: (placementId) async {
          print('Unity Ads: Interstitial ad loaded: $placementId');
          _isAdLoading = false;
          _isAdLoaded = true;
          // Only auto-show if requested
          if (autoShow) {
            await _showLoadedAd();
          }
        },
        onFailed: (placementId, error, message) {
          print(
            'Unity Ads: Failed to load interstitial ad: $placementId - $error: $message',
          );
          _isAdLoading = false;
          _isAdLoaded = false;
        },
      );
    } catch (e) {
      print('Unity Ads: Error loading interstitial ad: $e');
      _isAdLoading = false;
      _isAdLoaded = false;
    }
  }

  static Future<void> _showLoadedAd() async {
    try {
      // Check if ad is actually loaded before attempting to show
      if (!_isAdLoaded) {
        print('Unity Ads: Ad is not loaded, attempting to load first');
        await _loadInterstitialAd();
        return;
      }

      await UnityAds.showVideoAd(
        placementId: interstitialId,
        onComplete: (placementId) {
          _loadInterstitialAd(autoShow: false);
          print('Unity Ads: Interstitial ad completed: $placementId');
          _lastAdShown = DateTime.now();
          _isAdLoaded = false; // Mark as not loaded after showing
        },
        onFailed: (placementId, error, message) async {
          _loadInterstitialAd(autoShow: false);
          print(
            'Unity Ads: Interstitial ad failed: $placementId - $error: $message',
          );
          _isAdLoaded = false; // Mark as not loaded after failed show

          // If showing fails due to not being ready, try to load a new ad for next time
          if (message.contains('not ready') ||
              message.contains('Placement not ready') ||
              message.contains('must be Loaded before calling Show')) {
            print('Unity Ads: Ad not ready, will load new ad for next time');
            // Don't load immediately to avoid recursive calls
          }
        },
        onStart: (placementId) {
          print('Unity Ads: Interstitial ad started: $placementId');
        },
        onClick: (placementId) {
          print('Unity Ads: Interstitial ad clicked: $placementId');
        },
        onSkipped: (placementId) {
          print('Unity Ads: Interstitial ad skipped: $placementId');
          _lastAdShown = DateTime.now();
          _isAdLoaded = false; // Mark as not loaded after showing
        },
      );
    } catch (e) {
      print('Unity Ads: Error showing loaded ad: $e');
      _isAdLoaded = false; // Mark as not loaded after error
    }
  }
}
