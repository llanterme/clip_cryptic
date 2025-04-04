import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

/// Provider for the AdService
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// Service to manage mobile ads
class AdService {
  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    developer.log('Mobile Ads SDK initialized');
  }

  /// Create a banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          developer.log('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          developer.log('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (ad) => developer.log('Banner ad opened'),
        onAdClosed: (ad) => developer.log('Banner ad closed'),
      ),
    );
  }

  /// Get the appropriate ad unit ID based on platform
  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      // Test ad unit ID for Android
      return 'ca-app-pub-5183899333761387~7468172308';
    } else if (Platform.isIOS) {
      // Test ad unit ID for iOS
      return 'ca-app-pub-5183899333761387/7653733506';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

/// Widget to display a banner ad
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adService = ProviderContainer().read(adServiceProvider);
    _bannerAd = adService.createBannerAd()
      ..load().then((value) {
        setState(() {
          _isAdLoaded = true;
        });
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isAdLoaded) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Ad is loading...',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
