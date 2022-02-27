import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyBanner extends StatefulWidget {
  const MyBanner({Key? key}) : super(key: key);

  @override
  _MyBannerState createState() => _MyBannerState();
}

class _MyBannerState extends State<MyBanner> {
  var bannerId = "ca-app-pub-6360962583684507/8603994157";
  BannerAd? myAd;

  buildBottomAd(context) {
    myAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: kReleaseMode ? bannerId : BannerAd.testAdUnitId,
        listener: BannerAdListener(onAdLoaded: (ad) {
          if (mounted) setState(() {});
        }),
        request: AdRequest());
    myAd!.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildBottomAd(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AdSize.fullBanner.height.toDouble(),
      child: myAd != null
          ? AdWidget(
              ad: myAd!,
            )
          : SizedBox(),
    );
  }
}
