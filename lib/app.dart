import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/screens/reset_password.dart';
import 'package:icare/screens/splash.dart';
import 'package:icare/screens/verify_code.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Widget content = SplashScreen();

 @override
  void initState() {
    super.initState();
    splash();
  }

  void splash () async{
    await Future.delayed(const Duration(seconds: 6));

    if(!mounted) return;
    
    setState(() {
      content = CreateProfile(); 
    });
  }  

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: content,
    );
  }
}