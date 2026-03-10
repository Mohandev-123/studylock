import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _androidProdBannerAdUnitId =
      'ca-app-pub-9772817981148270/3217511348';
  static const String _iosProdBannerAdUnitId =
      'ca-app-pub-9772817981148270/3217511348';

  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<InitializationStatus?> initialize() async {
    if (!isSupportedPlatform) return null;
    return MobileAds.instance.initialize();
  }

  static String get _bannerAdUnitId {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (kDebugMode) {
      return isIos ? _iosTestBannerAdUnitId : _androidTestBannerAdUnitId;
    }
    return isIos ? _iosProdBannerAdUnitId : _androidProdBannerAdUnitId;
  }

  static BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (!isSupportedPlatform) {
      throw StateError('Banner ads are only supported on Android and iOS.');
    }

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
