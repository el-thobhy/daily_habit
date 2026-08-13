import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Test Ad Unit ID resmi dari Google
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iOSTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  // Test Ad Unit ID resmi dari Google untuk Rewarded Ad
  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iOSTestRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  // ID Production dari AdMob Console
  static const String _androidProductionBannerId =
      'ca-app-pub-9084606382966168/9740401408';
  static const String _iOSProductionBannerId =
      'ca-app-pub-9084606382966168/9740401408';

  static const String _androidProductionRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iOSProductionRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  /// Mengembalikan Banner Ad Unit ID sesuai mode (Debug vs Release) dan Platform (Android vs iOS)
  static String get bannerAdUnitId {
    if (kIsWeb) {
      return '';
    }
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return _androidTestBannerId;
      } else if (Platform.isIOS) {
        return _iOSTestBannerId;
      }
    } else {
      if (Platform.isAndroid) {
        return _androidProductionBannerId;
      } else if (Platform.isIOS) {
        return _iOSProductionBannerId;
      }
    }
    return '';
  }

  /// Mengembalikan Rewarded Ad Unit ID sesuai mode (Debug vs Release) dan Platform
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return _androidTestRewardedId;
      } else if (Platform.isIOS) {
        return _iOSTestRewardedId;
      }
    } else {
      if (Platform.isAndroid) {
        return _androidProductionRewardedId;
      } else if (Platform.isIOS) {
        return _iOSProductionRewardedId;
      }
    }
    return '';
  }
}
