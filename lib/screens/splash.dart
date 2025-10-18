import 'package:flutter/material.dart';
import 'package:icare/utils/utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/splash.jpg",
        width: Utils.windowWidth(context),
        height: Utils.windowHeight(context),
        ) ,
      ),
    );
  }
}