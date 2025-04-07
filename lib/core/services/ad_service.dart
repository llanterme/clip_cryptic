import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:developer' as developer;

/// Provider for the AdService
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// Service to manage mobile ads
class AdService {
  /// Initialize the Mobile Ads SDK and request tracking permission
  Future<void> initialize() async {
    // First initialize Mobile Ads SDK
    await MobileAds.instance.initialize();
    developer.log('Mobile Ads SDK initialized');

    // Request tracking authorization (iOS only)
    if (Platform.isIOS) {
      await _requestTrackingAuthorization();
    }
  }

  /// Request tracking authorization for iOS
  Future<void> _requestTrackingAuthorization() async {
    try {
      // Check current status first
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      developer.log('Current tracking status: $status');

      // If not determined, request permission
      if (status == TrackingStatus.notDetermined) {
        // Wait for app to be fully visible before showing the dialog
        await Future.delayed(const Duration(milliseconds: 200));
        final TrackingStatus requestStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        developer.log('Tracking authorization request result: $requestStatus');
      }
    } catch (e) {
      developer.log('Error requesting tracking authorization: $e');
    }
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
      return 'ca-app-pub-5183899333761387/4842008966';
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
