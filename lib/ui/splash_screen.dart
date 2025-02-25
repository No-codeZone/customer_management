import 'dart:async';
import 'package:employee_management/ui/login_screen.dart';
import 'package:employee_management/ui/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/color_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                isLoggedIn ? const DashboardScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              // child: Lottie.asset("assets/animations/sunny_rainy_weather.json"),
              child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/images/logo_max_mobility.png")),
            ),
            // Text(
            //   "Max Mobility",
            //   style: TextStyle(
            //     fontFamily: "TimesRoman",
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blueGrey,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
