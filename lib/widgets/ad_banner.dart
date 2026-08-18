import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});
  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? ad;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    ad = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => loaded = true); },
        onAdFailedToLoad: (failedAd, _) { failedAd.dispose(); if (mounted) setState(() { ad = null; loaded = false; }); },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final current = ad;
    if (!loaded || current == null) return const SizedBox.shrink();
    return SizedBox(width: current.size.width.toDouble(), height: current.size.height.toDouble(), child: AdWidget(ad: current));
  }

  @override
  void dispose() { ad?.dispose(); super.dispose(); }
}
