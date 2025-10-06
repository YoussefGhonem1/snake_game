import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsHelper {
  // App/game IDs
  static const String _gameId = '5959903';

  // Placement IDs
  static const String _bannerAndroidId = 'Banner_Android';
  static const String _interstitialAndroidId = 'Interstitial_Android';
  static const String _bannerIOSId = 'Banner_iOS';
  static const String _interstitialIOSId = 'Interstitial_iOS';

  // Ad state
  static bool _isAdLoading = false;
  static bool _isAdLoaded = false;
  static DateTime? _lastAdShown;
  static const int _minAdIntervalSeconds = 30;

  // Public getters for placement IDs
  static String get bannerId => _isIOS ? _bannerIOSId : _bannerAndroidId;
  static String get interstitialId =>
      _isIOS ? _interstitialIOSId : _interstitialAndroidId;
  static String get gameId => _gameId;

  static bool get _isIOS => Platform.isIOS;

  /// Initializes Unity Ads and preloads an interstitial ad.
  static Future<void> initUnityAds() async {
    await UnityAds.init(
      gameId: _gameId,
      testMode: kDebugMode,
      onComplete: () {
        print("Unity ads initialized");
        _preloadAd();
      },
    );
  }

  /// Preloads an interstitial ad if not already loaded or loading.
  static Future<void> _preloadAd() async {
    if (!_isAdLoading && !_isAdLoaded) {
      print('Unity Ads: Preloading interstitial ad');
      await _loadInterstitialAd(autoShow: false);
    }
  }

  /// Shows an interstitial ad if available and not shown too recently.
  static Future<void> showInterstitialAd() async {
    try {
      if (_recentlyShown()) {
        final wait =
            _minAdIntervalSeconds -
            DateTime.now().difference(_lastAdShown!).inSeconds;
        print('Unity Ads: Ad shown too recently, waiting $wait more seconds');
        return;
      }
      if (_isAdLoading) {
        print('Unity Ads: Ad is already loading, please wait');
        return;
      }
      if (_isAdLoaded) {
        await _showLoadedAd();
      } else {
        await _loadInterstitialAd();
      }
    } catch (e) {
      print('Unity Ads: Error in showInterstitialAd: $e');
      _isAdLoading = false;
    }
  }

  /// Loads an interstitial ad. Optionally auto-shows when loaded.
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
          if (autoShow) await _showLoadedAd();
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

  /// Shows the loaded interstitial ad.
  static Future<void> _showLoadedAd() async {
    try {
      if (!_isAdLoaded) {
        print('Unity Ads: Ad is not loaded, attempting to load first');
        await _loadInterstitialAd();
        return;
      }
      await UnityAds.showVideoAd(
        placementId: interstitialId,
        onComplete: (placementId) {
          _onAdClosed(placementId, completed: true);
        },
        onFailed: (placementId, error, message) async {
          _onAdFailed(placementId, error, message);
        },
        onStart: (placementId) {
          print('Unity Ads: Interstitial ad started: $placementId');
        },
        onClick: (placementId) {
          print('Unity Ads: Interstitial ad clicked: $placementId');
        },
        onSkipped: (placementId) {
          _onAdClosed(placementId, completed: false);
        },
      );
    } catch (e) {
      print('Unity Ads: Error showing loaded ad: $e');
      _isAdLoaded = false;
    }
  }

  /// Handles ad closed (completed or skipped).
  static void _onAdClosed(String placementId, {required bool completed}) {
    print(
      'Unity Ads: Interstitial ad ${completed ? "completed" : "skipped"}: $placementId',
    );
    _lastAdShown = DateTime.now();
    _isAdLoaded = false;
    _loadInterstitialAd(autoShow: false);
  }

  /// Handles ad failed to show.
  static void _onAdFailed(String placementId, dynamic error, String message) {
    print('Unity Ads: Interstitial ad failed: $placementId - $error: $message');
    _isAdLoaded = false;
    _loadInterstitialAd(autoShow: false);
    if (message.contains('not ready') ||
        message.contains('Placement not ready') ||
        message.contains('must be Loaded before calling Show')) {
      print('Unity Ads: Ad not ready, will load new ad for next time');
    }
  }

  /// Checks if an ad was shown too recently.
  static bool _recentlyShown() {
    if (_lastAdShown == null) return false;
    final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
    return timeSinceLastAd.inSeconds < _minAdIntervalSeconds;
  }
}
