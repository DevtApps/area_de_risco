import 'package:area_de_risco/app/components/my_banner.dart';
import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/controllers/twitter_controller.dart';
import 'package:area_de_risco/app/controllers/user_controller.dart';
import 'package:area_de_risco/app/screens/add_area/new_area.dart';
import 'package:area_de_risco/app/screens/feed/feed_view.dart';
import 'package:area_de_risco/app/screens/home/home_screen.dart';
import 'package:area_de_risco/app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var pageController = PageController();
  var selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    Provider.of<UserController>(context, listen: false).init();
    Provider.of<AreaController>(context, listen: false).initListen();
    var twitter = Provider.of<TwitterController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                MyBanner(),
                Expanded(
                  child: HomeScreen(),
                ),
                MyBanner()
              ],
            ),
            FeedView(),
            NewAreaScreen(),
            ProfileScreen()
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  pageController.jumpToPage(0);
                  setState(() {
                    selectedIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.home,
                  color: selectedIndex == 0 ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(),
              IconButton(
                onPressed: () {
                  pageController.jumpToPage(1);
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                icon: Icon(
                  Icons.podcasts,
                  color: selectedIndex == 1 ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(),
              IconButton(
                onPressed: () {
                  pageController.jumpToPage(2);
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                icon: Icon(
                  Icons.new_label_outlined,
                  color: selectedIndex == 2 ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(),
              IconButton(
                onPressed: () {
                  pageController.jumpToPage(3);
                  setState(() {
                    selectedIndex = 3;
                  });
                },
                icon: Icon(
                  Icons.person,
                  color: selectedIndex == 3 ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
