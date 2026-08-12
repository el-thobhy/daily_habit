import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:daily_habit/core/utils/ad_helper.dart';

/// Widget Banner AdMob dengan Adaptive Banner Size & Error Handling
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) return;
    if (_bannerAd == null && !_isAdLoaded) {
      _loadAdaptiveBanner();
    }
  }

  Future<void> _loadAdaptiveBanner() async {
    if (kIsWeb) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final String adUnitId = AdHelper.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      debugPrint(
        'AdBannerWidget: Ad Unit ID kosong atau platform tidak didukung.',
      );
      return;
    }

    final int width = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    final AdSize bannerSize = adaptiveSize ?? AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: bannerSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
          debugPrint(
            'AdBannerWidget: Adaptive Banner (${bannerSize.width}x${bannerSize.height}) berhasil dimuat!',
          );
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint(
            'AdBannerWidget: Gagal memuat Banner Ad: ${error.message} (Code: ${error.code})',
          );
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
            if (_retryAttempts < _maxRetryAttempts) {
              _retryAttempts++;
              debugPrint(
                'AdBannerWidget: Mencoba memuat ulang (Percobaan $_retryAttempts/$_maxRetryAttempts)...',
              );
              Future.delayed(Duration(seconds: 2 * _retryAttempts), () {
                if (mounted && !_isAdLoaded) {
                  _loadAdaptiveBanner();
                }
              });
            }
          }
        },
      ),
    );

    return _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
