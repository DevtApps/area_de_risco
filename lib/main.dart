import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/controllers/location_controller.dart';
import 'package:area_de_risco/app/controllers/twitter_controller.dart';
import 'package:area_de_risco/app/controllers/user_controller.dart';
import 'package:area_de_risco/app/screens/add_area/new_area.dart';
import 'package:area_de_risco/app/screens/auth/login_screen.dart';
import 'package:area_de_risco/app/screens/auth/register_screen.dart';
import 'package:area_de_risco/app/screens/home/home_screen.dart';
import 'package:area_de_risco/app/screens/main/main_screen.dart';
import 'package:area_de_risco/app/screens/places/search_place_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserController()),
          ChangeNotifierProvider(
            create: (_) => LocationController(),
          ),
          ChangeNotifierProvider(
            create: (_) => AreaController(),
          ),
          ChangeNotifierProvider(
            create: (_) => TwitterController(),
          ),
        ],
        child: MaterialApp(
            title: 'Área de Risco',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Color(0xFF8D99AE),
                primarySwatch: Colors.red,
                backgroundColor: Colors.black,
              ),
              textTheme: GoogleFonts.robotoTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            routes: {
              "main": (c) => MainScreen(),
              "auth": (c) => LoginScreen(),
              "home": (c) => HomeScreen(),
              "search_place": (c) => SearchPlace(),
              "new_area": (c) => NewAreaScreen(),
              "register": (c) => RegisterScreen()
            },
            home: Landing()));
  }
}

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500), () async {
      var userController = Provider.of<UserController>(context, listen: false);
      if (userController.isLogged) {
        Navigator.of(context).pushReplacementNamed("main");
      } else {
        Navigator.of(context).pushReplacementNamed("auth");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Image.asset(
        "assets/icone.png",
        width: 60,
        height: 90,
      )),
    );
  }
}
