import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class AdBanner extends StatefulWidget { const AdBanner({super.key}); @override State<AdBanner> createState()=>_AdBannerState(); }
class _AdBannerState extends State<AdBanner>{BannerAd? ad;@override void initState(){super.initState();ad=BannerAd(adUnitId:'ca-app-pub-3940256099942544/6300978111',size:AdSize.banner,request:const AdRequest(),listener:BannerAdListener(onAdLoaded:(_){if(mounted)setState((){});}));ad!.load();}@override Widget build(BuildContext context)=>ad==null?const SizedBox.shrink():SizedBox(width:ad!.size.width.toDouble(),height:ad!.size.height.toDouble(),child:AdWidget(ad:ad!));@override void dispose(){ad?.dispose();super.dispose();}}
